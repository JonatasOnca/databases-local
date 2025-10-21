#!/bin/bash

# Sistema avançado de coleta de métricas e observabilidade
# Coleta métricas detalhadas de performance, uso de recursos e KPIs

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
METRICS_DIR="${PROJECT_DIR}/metrics"
LOG_FILE="${METRICS_DIR}/metrics.log"
JSON_OUTPUT="${METRICS_DIR}/metrics.json"

# Criar estrutura de diretórios
mkdir -p "${METRICS_DIR}"/{prometheus,grafana,alerts}

# Função de logging com timestamp
log_metric() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# Função para coletar métricas de container
collect_container_metrics() {
    local container_name=$1
    local service_type=$2
    
    if ! docker ps --format "table {{.Names}}" | grep -q "^${container_name}$"; then
        echo "null"
        return
    fi
    
    # Obter estatísticas do container
    local stats_raw=$(docker stats --no-stream --format "{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}},{{.NetIO}},{{.BlockIO}}" "$container_name" 2>/dev/null)
    
    if [ -n "$stats_raw" ]; then
        local cpu_perc=$(echo "$stats_raw" | cut -d ',' -f1 | sed 's/%//')
        local mem_usage=$(echo "$stats_raw" | cut -d ',' -f2)
        local mem_perc=$(echo "$stats_raw" | cut -d ',' -f3 | sed 's/%//')
        local net_io=$(echo "$stats_raw" | cut -d ',' -f4)
        local block_io=$(echo "$stats_raw" | cut -d ',' -f5)
        
        # Obter informações adicionais
        local container_info=$(docker inspect "$container_name" --format '{{.State.StartedAt}},{{.State.Status}},{{.Config.Image}}')
        local started_at=$(echo "$container_info" | cut -d ',' -f1)
        local status=$(echo "$container_info" | cut -d ',' -f2)
        local image=$(echo "$container_info" | cut -d ',' -f3)
        
        # Calcular uptime
        local uptime_seconds=$(( $(date +%s) - $(date -d "$started_at" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "${started_at%.*}" +%s 2>/dev/null || echo "0") ))
        
        # Criar objeto JSON
        cat << EOF
{
  "container_name": "$container_name",
  "service_type": "$service_type",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "$status",
  "image": "$image",
  "uptime_seconds": $uptime_seconds,
  "cpu_percent": ${cpu_perc:-0},
  "memory_usage": "$mem_usage",
  "memory_percent": ${mem_perc:-0},
  "network_io": "$net_io",
  "block_io": "$block_io"
}
EOF
    else
        echo "null"
    fi
}

# Função para coletar métricas de banco de dados
collect_database_metrics() {
    local db_type=$1
    local container_name=$2
    
    case $db_type in
        "mysql")
            collect_mysql_metrics "$container_name"
            ;;
        "postgres")
            collect_postgres_metrics "$container_name"
            ;;
        "sqlserver")
            collect_sqlserver_metrics "$container_name"
            ;;
    esac
}

# Métricas específicas do MySQL
collect_mysql_metrics() {
    local container_name=$1
    
    if ! docker ps --format "table {{.Names}}" | grep -q "^${container_name}$"; then
        echo "null"
        return
    fi
    
    # Coletar estatísticas do MySQL
    local mysql_stats=$(docker exec "$container_name" mysql -u"${DB_USER}" -p"${DB_PASSWORD}" -e "
        SELECT 
            VARIABLE_NAME, VARIABLE_VALUE 
        FROM performance_schema.global_status 
        WHERE VARIABLE_NAME IN (
            'Connections', 'Threads_connected', 'Threads_running',
            'Queries', 'Com_select', 'Com_insert', 'Com_update', 'Com_delete',
            'Bytes_received', 'Bytes_sent', 'Innodb_buffer_pool_reads',
            'Innodb_buffer_pool_read_requests', 'Slow_queries'
        );
    " 2>/dev/null) || echo ""
    
    if [ -n "$mysql_stats" ]; then
        # Processar estatísticas e criar JSON
        local connections=$(echo "$mysql_stats" | grep "Connections" | awk '{print $2}' || echo "0")
        local threads_connected=$(echo "$mysql_stats" | grep "Threads_connected" | awk '{print $2}' || echo "0")
        local queries=$(echo "$mysql_stats" | grep -w "Queries" | awk '{print $2}' || echo "0")
        local slow_queries=$(echo "$mysql_stats" | grep "Slow_queries" | awk '{print $2}' || echo "0")
        
        cat << EOF
{
  "database_type": "mysql",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "connections_total": $connections,
  "connections_current": $threads_connected,
  "queries_total": $queries,
  "slow_queries": $slow_queries
}
EOF
    else
        echo "null"
    fi
}

# Métricas específicas do PostgreSQL
collect_postgres_metrics() {
    local container_name=$1
    
    if ! docker ps --format "table {{.Names}}" | grep -q "^${container_name}$"; then
        echo "null"
        return
    fi
    
    # Coletar estatísticas do PostgreSQL
    local pg_stats=$(docker exec "$container_name" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c "
        SELECT 
            (SELECT count(*) FROM pg_stat_activity) as total_connections,
            (SELECT count(*) FROM pg_stat_activity WHERE state = 'active') as active_connections,
            (SELECT sum(numbackends) FROM pg_stat_database) as backends,
            (SELECT sum(xact_commit) FROM pg_stat_database) as transactions_committed,
            (SELECT sum(xact_rollback) FROM pg_stat_database) as transactions_rolled_back;
    " -t 2>/dev/null) || echo ""
    
    if [ -n "$pg_stats" ]; then
        # Processar estatísticas
        local total_connections=$(echo "$pg_stats" | awk '{print $1}' | head -1 || echo "0")
        local active_connections=$(echo "$pg_stats" | awk '{print $2}' | head -1 || echo "0")
        
        cat << EOF
{
  "database_type": "postgresql",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "connections_total": ${total_connections:-0},
  "connections_active": ${active_connections:-0}
}
EOF
    else
        echo "null"
    fi
}

# Métricas específicas do SQL Server
collect_sqlserver_metrics() {
    local container_name=$1
    
    if ! docker ps --format "table {{.Names}}" | grep -q "^${container_name}$"; then
        echo "null"
        return
    fi
    
    # Coletar estatísticas básicas do SQL Server
    local sqlserver_connections=$(docker exec "$container_name" /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "${SA_PASSWORD}" -C -Q "SELECT @@CONNECTIONS" -h-1 2>/dev/null | tr -d ' \n\r' || echo "0")
    
    cat << EOF
{
  "database_type": "sqlserver",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "connections_total": ${sqlserver_connections:-0}
}
EOF
}

# Função para coletar métricas do sistema
collect_system_metrics() {
    # Métricas do Docker
    local docker_info=$(docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}\t{{.Reclaimable}}" | grep -v "TYPE")
    
    # Uso de disco
    local disk_usage=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')
    
    # Memória do sistema
    local memory_info=""
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        local total_memory=$(( $(sysctl -n hw.memsize) / 1024 / 1024 ))
        local used_memory=$(( $(vm_stat | grep "Pages active" | awk '{print $3}' | sed 's/\.//' || echo "0") * 4096 / 1024 / 1024 ))
    else
        # Linux
        local memory_stats=$(free -m | awk 'NR==2{print $2,$3}')
        local total_memory=$(echo "$memory_stats" | awk '{print $1}')
        local used_memory=$(echo "$memory_stats" | awk '{print $2}')
    fi
    
    cat << EOF
{
  "system_metrics": {
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "disk_usage_percent": ${disk_usage:-0},
    "memory_total_mb": ${total_memory:-0},
    "memory_used_mb": ${used_memory:-0},
    "docker_containers": $(docker ps -q | wc -l | tr -d ' '),
    "docker_images": $(docker images -q | wc -l | tr -d ' '),
    "docker_volumes": $(docker volume ls -q | wc -l | tr -d ' ')
  }
}
EOF
}

# Função para gerar alertas
generate_alerts() {
    local metrics_file=$1
    local alerts=()
    
    # Verificar métricas críticas
    if [ -f "$metrics_file" ]; then
        # CPU alto (>80%)
        local high_cpu=$(jq -r '.containers[] | select(.cpu_percent > 80) | .container_name' "$metrics_file" 2>/dev/null || echo "")
        if [ -n "$high_cpu" ]; then
            alerts+=("HIGH_CPU: $high_cpu")
        fi
        
        # Memória alta (>80%)
        local high_memory=$(jq -r '.containers[] | select(.memory_percent > 80) | .container_name' "$metrics_file" 2>/dev/null || echo "")
        if [ -n "$high_memory" ]; then
            alerts+=("HIGH_MEMORY: $high_memory")
        fi
        
        # Disco cheio (>90%)
        local disk_usage=$(jq -r '.system_metrics.disk_usage_percent' "$metrics_file" 2>/dev/null || echo "0")
        if [ "$disk_usage" -gt 90 ]; then
            alerts+=("HIGH_DISK_USAGE: ${disk_usage}%")
        fi
    fi
    
    # Salvar alertas
    if [ ${#alerts[@]} -gt 0 ]; then
        local alert_file="${METRICS_DIR}/alerts/alerts_$(date +%Y%m%d_%H%M%S).json"
        printf '%s\n' "${alerts[@]}" | jq -R -s 'split("\n") | map(select(length > 0))' > "$alert_file"
        echo -e "${RED}🚨 Alertas gerados: $alert_file${NC}"
    fi
}

# Função para gerar métricas Prometheus
generate_prometheus_metrics() {
    local metrics_file=$1
    local prometheus_file="${METRICS_DIR}/prometheus/metrics.txt"
    
    if [ ! -f "$metrics_file" ]; then
        return
    fi
    
    # Cabeçalho Prometheus
    cat > "$prometheus_file" << EOF
# HELP database_container_cpu_percent CPU usage percentage
# TYPE database_container_cpu_percent gauge
# HELP database_container_memory_percent Memory usage percentage  
# TYPE database_container_memory_percent gauge
# HELP database_container_uptime_seconds Container uptime in seconds
# TYPE database_container_uptime_seconds counter
# HELP database_connections_total Total database connections
# TYPE database_connections_total counter

EOF
    
    # Processar métricas dos containers
    jq -r '.containers[] | "database_container_cpu_percent{container=\"\(.container_name)\",service=\"\(.service_type)\"} \(.cpu_percent // 0)"' "$metrics_file" >> "$prometheus_file"
    jq -r '.containers[] | "database_container_memory_percent{container=\"\(.container_name)\",service=\"\(.service_type)\"} \(.memory_percent // 0)"' "$metrics_file" >> "$prometheus_file"
    jq -r '.containers[] | "database_container_uptime_seconds{container=\"\(.container_name)\",service=\"\(.service_type)\"} \(.uptime_seconds // 0)"' "$metrics_file" >> "$prometheus_file"
    
    echo -e "${GREEN}📊 Métricas Prometheus geradas: $prometheus_file${NC}"
}

# Função principal de coleta
collect_all_metrics() {
    log_metric "Iniciando coleta de métricas"
    
    # Carregar variáveis de ambiente
    if [ -f ".env" ]; then
        export $(grep -v '^#' .env | xargs)
    fi
    
    # Inicializar estrutura JSON
    local json_start='{"timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","containers":['
    local containers_json=""
    local databases_json=""
    
    # Coletar métricas de containers
    local containers=("mysql_db:mysql" "postgres_db:postgres" "sqlserver_db:sqlserver")
    for container_info in "${containers[@]}"; do
        local container_name=$(echo "$container_info" | cut -d ':' -f1)
        local service_type=$(echo "$container_info" | cut -d ':' -f2)
        
        local container_metrics=$(collect_container_metrics "$container_name" "$service_type")
        if [ "$container_metrics" != "null" ]; then
            if [ -n "$containers_json" ]; then
                containers_json+=","
            fi
            containers_json+="$container_metrics"
        fi
        
        # Coletar métricas específicas do banco
        local db_metrics=$(collect_database_metrics "$service_type" "$container_name")
        if [ "$db_metrics" != "null" ]; then
            if [ -n "$databases_json" ]; then
                databases_json+=","
            fi
            databases_json+="$db_metrics"
        fi
    done
    
    # Coletar métricas do sistema
    local system_metrics=$(collect_system_metrics)
    
    # Montar JSON final
    local final_json="${json_start}${containers_json}],\"databases\":[${databases_json}],${system_metrics#\{}"
    
    # Salvar métricas
    echo "$final_json" | jq '.' > "$JSON_OUTPUT" 2>/dev/null || echo "$final_json" > "$JSON_OUTPUT"
    
    log_metric "Métricas coletadas e salvas em $JSON_OUTPUT"
    
    # Gerar alertas
    generate_alerts "$JSON_OUTPUT"
    
    # Gerar métricas Prometheus
    generate_prometheus_metrics "$JSON_OUTPUT"
    
    return 0
}

# Função para exibir relatório em tempo real
show_realtime_metrics() {
    echo -e "${PURPLE}📊 MÉTRICAS EM TEMPO REAL${NC}"
    echo "=========================="
    
    while true; do
        clear
        collect_all_metrics > /dev/null 2>&1
        
        if [ -f "$JSON_OUTPUT" ]; then
            echo -e "${BLUE}🕐 Última atualização: $(date)${NC}"
            echo ""
            
            # Mostrar containers
            echo -e "${YELLOW}📦 Containers:${NC}"
            jq -r '.containers[] | "  \(.service_type | ascii_upcase): CPU \(.cpu_percent)%, MEM \(.memory_percent)%, UP \(.uptime_seconds)s"' "$JSON_OUTPUT" 2>/dev/null || echo "  Sem dados disponíveis"
            
            echo ""
            
            # Mostrar métricas de banco
            echo -e "${YELLOW}🗄️ Bancos de Dados:${NC}"
            jq -r '.databases[] | "  \(.database_type | ascii_upcase): Conexões \(.connections_total // .connections_current // 0)"' "$JSON_OUTPUT" 2>/dev/null || echo "  Sem dados disponíveis"
            
            echo ""
            
            # Mostrar métricas do sistema
            echo -e "${YELLOW}💻 Sistema:${NC}"
            jq -r '.system_metrics | "  Disco: \(.disk_usage_percent)%, Memória: \(.memory_used_mb)MB/\(.memory_total_mb)MB"' "$JSON_OUTPUT" 2>/dev/null || echo "  Sem dados disponíveis"
        fi
        
        echo ""
        echo -e "${CYAN}Pressione Ctrl+C para sair${NC}"
        sleep 5
    done
}

# Função para mostrar ajuda
show_help() {
    echo "Sistema de Métricas e Observabilidade"
    echo "======================================"
    echo ""
    echo "Uso: $0 [opções]"
    echo ""
    echo "Opções:"
    echo "  --collect         Coleta métricas uma vez"
    echo "  --realtime        Monitora métricas em tempo real"
    echo "  --prometheus      Gera apenas métricas Prometheus"
    echo "  --alerts          Verifica e gera alertas"
    echo "  --json            Mostra últimas métricas em JSON"
    echo "  --help, -h        Mostra esta ajuda"
    echo ""
    echo "Arquivos gerados:"
    echo "  metrics/metrics.json              - Métricas em JSON"
    echo "  metrics/prometheus/metrics.txt    - Métricas formato Prometheus"
    echo "  metrics/alerts/                   - Alertas gerados"
    echo "  metrics/metrics.log               - Log de atividades"
}

# Função principal
main() {
    case "${1:-collect}" in
        --collect)
            collect_all_metrics
            ;;
        --realtime)
            show_realtime_metrics
            ;;
        --prometheus)
            collect_all_metrics > /dev/null 2>&1
            generate_prometheus_metrics "$JSON_OUTPUT"
            ;;
        --alerts)
            if [ -f "$JSON_OUTPUT" ]; then
                generate_alerts "$JSON_OUTPUT"
            else
                echo "Nenhuma métrica encontrada. Execute --collect primeiro."
            fi
            ;;
        --json)
            if [ -f "$JSON_OUTPUT" ]; then
                jq '.' "$JSON_OUTPUT"
            else
                echo "Nenhuma métrica encontrada. Execute --collect primeiro."
            fi
            ;;
        --help|-h)
            show_help
            ;;
        *)
            echo "Opção inválida: $1"
            show_help
            exit 1
            ;;
    esac
}

# Executar se chamado diretamente
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi