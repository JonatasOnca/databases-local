#!/bin/bash

# Script de health check avançado para bancos de dados
# Verifica saúde, performance e estado crítico dos bancos

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="${PROJECT_DIR}/logs/health-check.log"
ALERT_THRESHOLD_CPU=80
ALERT_THRESHOLD_MEMORY=80
ALERT_THRESHOLD_RESPONSE_TIME=1.0

# Criar diretório de logs se não existir
mkdir -p "${PROJECT_DIR}/logs"

# Função de logging
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Função para verificar dependências
check_dependencies() {
    local missing_deps=()
    
    for cmd in docker bc jq; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${RED}❌ Dependências faltando: ${missing_deps[*]}${NC}"
        echo -e "${YELLOW}💡 Para instalar no macOS: brew install ${missing_deps[*]}${NC}"
        exit 1
    fi
}

# Função para obter métricas de container
get_container_metrics() {
    local container_name=$1
    
    if ! docker ps --format "table {{.Names}}" | grep -q "^${container_name}$"; then
        echo "null"
        return
    fi
    
    # Obter estatísticas do container
    local stats=$(docker stats --no-stream --format "{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}}" "$container_name" 2>/dev/null)
    
    if [ -n "$stats" ]; then
        echo "$stats"
    else
        echo "null"
    fi
}

# Função para testar resposta de banco
test_database_response() {
    local db_type=$1
    local start_time end_time duration
    
    start_time=$(date +%s.%N)
    
    case $db_type in
        "mysql")
            docker exec mysql_db mysql -u$(grep '^DB_USER' .env | cut -d '=' -f2) -p$(grep '^DB_PASSWORD' .env | cut -d '=' -f2) -e "SELECT 1;" &>/dev/null
            ;;
        "postgres")
            docker exec postgres_db psql -U $(grep '^POSTGRES_USER' .env | cut -d '=' -f2) -d $(grep '^POSTGRES_DB' .env | cut -d '=' -f2) -c "SELECT 1;" &>/dev/null
            ;;
        "sqlserver")
            docker exec sqlserver_db /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "$(grep '^SA_PASSWORD' .env | cut -d '=' -f2)" -C -Q "SELECT 1;" &>/dev/null
            ;;
    esac
    
    local exit_code=$?
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc -l)
    
    if [ $exit_code -eq 0 ]; then
        printf "%.3f" $duration
    else
        echo "error"
    fi
}

# Função para verificar saúde de um banco
check_database_health() {
    local db_name=$1
    local container_name=$2
    local db_type=$3
    
    echo -e "\n${BLUE}🔍 $db_name Health Check${NC}"
    echo "================================"
    
    # Verificar se container está rodando
    if ! docker ps --format "table {{.Names}}" | grep -q "^${container_name}$"; then
        echo -e "📦 Status: ${RED}PARADO${NC}"
        log_message "ERROR" "$db_name container is not running"
        return 1
    fi
    
    echo -e "📦 Status: ${GREEN}RODANDO${NC}"
    
    # Obter métricas do container
    local metrics=$(get_container_metrics "$container_name")
    
    if [ "$metrics" != "null" ]; then
        local cpu_perc=$(echo "$metrics" | cut -d ',' -f1 | sed 's/%//')
        local mem_usage=$(echo "$metrics" | cut -d ',' -f2)
        local mem_perc=$(echo "$metrics" | cut -d ',' -f3 | sed 's/%//')
        
        echo -e "💾 CPU: ${cpu_perc}%"
        echo -e "🧠 Memória: $mem_usage (${mem_perc}%)"
        
        # Alertas de recursos
        if [ $(echo "$cpu_perc > $ALERT_THRESHOLD_CPU" | bc -l) -eq 1 ]; then
            echo -e "⚠️  ${YELLOW}ALERTA: CPU alta (${cpu_perc}%)${NC}"
            log_message "WARN" "$db_name high CPU usage: ${cpu_perc}%"
        fi
        
        if [ $(echo "$mem_perc > $ALERT_THRESHOLD_MEMORY" | bc -l) -eq 1 ]; then
            echo -e "⚠️  ${YELLOW}ALERTA: Memória alta (${mem_perc}%)${NC}"
            log_message "WARN" "$db_name high memory usage: ${mem_perc}%"
        fi
    fi
    
    # Testar conectividade e tempo de resposta
    echo -n "🔌 Conectividade: "
    local response_time=$(test_database_response "$db_type")
    
    if [ "$response_time" = "error" ]; then
        echo -e "${RED}FALHOU${NC}"
        log_message "ERROR" "$db_name connectivity test failed"
        return 1
    else
        echo -e "${GREEN}OK${NC} (${response_time}s)"
        log_message "INFO" "$db_name connectivity OK - response time: ${response_time}s"
        
        # Alerta de tempo de resposta
        if [ $(echo "$response_time > $ALERT_THRESHOLD_RESPONSE_TIME" | bc -l) -eq 1 ]; then
            echo -e "⚠️  ${YELLOW}ALERTA: Tempo de resposta alto (${response_time}s)${NC}"
            log_message "WARN" "$db_name slow response time: ${response_time}s"
        fi
    fi
    
    # Verificar uptime
    local uptime=$(docker inspect --format='{{.State.StartedAt}}' "$container_name" 2>/dev/null)
    if [ -n "$uptime" ]; then
        # Converter formato de data para compatibilidade macOS/Linux
        local uptime_formatted=""
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            uptime_formatted=$(echo "$uptime" | sed 's/T/ /' | sed 's/\..*//')
        else
            # Linux
            uptime_formatted=$(date -d "$uptime" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "$uptime")
        fi
        echo -e "⏱️  Uptime: Desde $uptime_formatted"
    fi
    
    return 0
}

# Função para verificar uso de disco
check_disk_usage() {
    echo -e "\n${BLUE}💾 Uso de Volumes Docker${NC}"
    echo "================================"
    
    local volume_info=$(docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}\t{{.Reclaimable}}" | grep -E "(VOLUME|Local)")
    
    if [ -n "$volume_info" ]; then
        echo "$volume_info"
    else
        echo "Nenhuma informação de volume disponível"
    fi
    
    # Verificar espaço disponível no sistema
    local disk_usage=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')
    echo -e "\n💽 Disco Sistema: ${disk_usage}% usado"
    
    if [ "$disk_usage" -gt 85 ]; then
        echo -e "⚠️  ${YELLOW}ALERTA: Pouco espaço em disco (${disk_usage}% usado)${NC}"
        log_message "WARN" "Low disk space: ${disk_usage}% used"
    fi
}

# Função para verificar rede
check_network_health() {
    echo -e "\n${BLUE}🌐 Saúde da Rede${NC}"
    echo "================================"
    
    # Verificar rede docker
    local network_name=$(docker network ls --format "table {{.Name}}" | grep databases-local || echo "default")
    echo -e "🔗 Rede: $network_name"
    
    # Verificar portas
    echo -e "🔌 Portas:"
    local ports=("3306:MySQL" "5432:PostgreSQL" "1433:SQL Server")
    
    for port_info in "${ports[@]}"; do
        local port=$(echo "$port_info" | cut -d ':' -f1)
        local service=$(echo "$port_info" | cut -d ':' -f2)
        
        # Compatibilidade macOS/Linux para verificação de portas
        local port_open=false
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            if lsof -i ":$port" &>/dev/null; then
                port_open=true
            fi
        else
            # Linux
            if netstat -ln 2>/dev/null | grep -q ":$port "; then
                port_open=true
            fi
        fi
        
        if [ "$port_open" = true ]; then
            echo -e "  ✅ $port ($service): ${GREEN}ABERTA${NC}"
        else
            echo -e "  ❌ $port ($service): ${RED}FECHADA${NC}"
        fi
    done
}

# Função para gerar relatório resumido
generate_summary() {
    echo -e "\n${PURPLE}📊 RESUMO DO HEALTH CHECK${NC}"
    echo "=========================================="
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "🕐 Executado em: $timestamp"
    
    # Contar erros no log das últimas 24h
    local recent_errors=$(grep "ERROR" "$LOG_FILE" | wc -l)
    local recent_warnings=$(grep "WARN" "$LOG_FILE" | wc -l)
    
    echo -e "🔴 Erros nas últimas 24h: $recent_errors"
    echo -e "🟡 Alertas nas últimas 24h: $recent_warnings"
    
    # Status geral
    if [ "$recent_errors" -eq 0 ] && [ "$recent_warnings" -lt 5 ]; then
        echo -e "✅ Status Geral: ${GREEN}SAUDÁVEL${NC}"
    elif [ "$recent_errors" -eq 0 ]; then
        echo -e "⚠️  Status Geral: ${YELLOW}ATENÇÃO${NC}"
    else
        echo -e "❌ Status Geral: ${RED}CRÍTICO${NC}"
    fi
    
    echo -e "\n${BLUE}💡 Recomendações:${NC}"
    echo "• Execute health check regularmente: make health-check"
    echo "• Monitore logs: tail -f logs/health-check.log"
    echo "• Para problemas críticos: make restart"
    echo "• Para limpeza: make clean && make up"
}

# Função principal
main() {
    echo -e "${GREEN}🏥 HEALTH CHECK AVANÇADO - Database Environment${NC}"
    echo "=================================================="
    
    # Verificar dependências
    check_dependencies
    
    # Carregar variáveis de ambiente
    if [ -f ".env" ]; then
        export $(grep -v '^#' .env | xargs)
    else
        echo -e "${RED}❌ Arquivo .env não encontrado${NC}"
        exit 1
    fi
    
    log_message "INFO" "Starting advanced health check"
    
    # Verificar cada banco de dados
    local mysql_status=0
    local postgres_status=0
    local sqlserver_status=0
    
    check_database_health "MySQL" "mysql_db" "mysql" || mysql_status=1
    check_database_health "PostgreSQL" "postgres_db" "postgres" || postgres_status=1
    check_database_health "SQL Server" "sqlserver_db" "sqlserver" || sqlserver_status=1
    
    # Verificações adicionais
    check_disk_usage
    check_network_health
    generate_summary
    
    log_message "INFO" "Health check completed"
    
    # Exit code baseado no status geral
    local total_failures=$((mysql_status + postgres_status + sqlserver_status))
    exit $total_failures
}

# Executar apenas se chamado diretamente
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi