#!/bin/bash

# Script de monitoramento básico para os bancos de dados
# Executa verificações de saúde e coleta métricas básicas

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📊 Monitor de Bancos de Dados - $(date)${NC}"
echo "=============================================="

# Função para verificar se container está rodando
check_container() {
    local container_name=$1
    if docker ps --format "table {{.Names}}" | grep -q "^${container_name}$"; then
        echo -e "✅ ${container_name}: ${GREEN}Rodando${NC}"
        return 0
    else
        echo -e "❌ ${container_name}: ${RED}Parado${NC}"
        return 1
    fi
}

# Função para obter estatísticas de container
get_container_stats() {
    local container_name=$1
    local stats=$(docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" | grep $container_name)
    if [ -n "$stats" ]; then
        echo -e "   ${BLUE}Stats:${NC} $stats"
    fi
}

# Verificar containers
echo -e "\n${YELLOW}🐳 Status dos Containers:${NC}"
check_container "mysql_db" && get_container_stats "mysql_db"
check_container "postgres_db" && get_container_stats "postgres_db"
check_container "sqlserver_db" && get_container_stats "sqlserver_db"

# Verificar conectividade
echo -e "\n${YELLOW}🔌 Testes de Conectividade:${NC}"

# MySQL
echo -n "MySQL (3306): "
if docker exec mysql_db mysql -u$(grep '^DB_USER' .env | cut -d '=' -f2) -p$(grep '^DB_PASSWORD' .env | cut -d '=' -f2) -e "SELECT 1;" &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FALHOU${NC}"
fi

# PostgreSQL
echo -n "PostgreSQL (5432): "
if docker exec postgres_db psql -U $(grep '^POSTGRES_USER' .env | cut -d '=' -f2) -d $(grep '^POSTGRES_DB' .env | cut -d '=' -f2) -c "SELECT 1;" &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FALHOU${NC}"
fi

# SQL Server
echo -n "SQL Server (1433): "
if docker exec sqlserver_db /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "$(grep '^SA_PASSWORD' .env | cut -d '=' -f2)" -C -Q "SELECT 1;" &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FALHOU${NC}"
fi

# Verificar logs recentes (últimas 5 linhas de cada container)
echo -e "\n${YELLOW}📝 Logs Recentes:${NC}"

containers=("mysql_db" "postgres_db" "sqlserver_db")
for container in "${containers[@]}"; do
    if docker ps --format "table {{.Names}}" | grep -q "^${container}$"; then
        echo -e "\n${BLUE}${container}:${NC}"
        docker logs --tail 3 $container 2>/dev/null | head -3 || echo "  Sem logs disponíveis"
    fi
done

# Verificar uso de disco dos volumes
echo -e "\n${YELLOW}💾 Uso de Volumes:${NC}"
docker system df --format "table {{.Type}}\t{{.Size}}\t{{.Reclaimable}}" | grep -E "(VOLUME|Local)" || echo "Informações de volume não disponíveis"

echo -e "\n${GREEN}✅ Monitoramento concluído!${NC}"
echo "Para relatório detalhado, execute: make info"