#!/bin/bash

# Script de validação do ambiente
# Este script verifica se todos os containers estão funcionando corretamente

set -e

echo "🔍 Validando ambiente de bancos de dados..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para imprimir status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

# Função para verificar se container está rodando
check_container() {
    local container_name=$1
    local service_name=$2
    
    if docker ps --format "table {{.Names}}" | grep -q "^${container_name}$"; then
        print_status 0 "${service_name} container está rodando"
        return 0
    else
        print_status 1 "${service_name} container não está rodando"
        return 1
    fi
}

# Função para verificar conectividade
check_connectivity() {
    local container_name=$1
    local service_name=$2
    local command=$3
    
    if docker exec ${container_name} ${command} &>/dev/null; then
        print_status 0 "${service_name} está respondendo"
        return 0
    else
        print_status 1 "${service_name} não está respondendo"
        return 1
    fi
}

echo ""
echo "📦 Verificando containers..."

# Verificar se containers estão rodando
check_container "mysql_db" "MySQL"
mysql_running=$?

check_container "postgres_db" "PostgreSQL"
postgres_running=$?

check_container "sqlserver_db" "SQL Server"
sqlserver_running=$?

echo ""
echo "🔌 Verificando conectividade..."

# Verificar conectividade MySQL
if [ $mysql_running -eq 0 ]; then
    check_connectivity "mysql_db" "MySQL" "mysqladmin ping -h localhost --silent"
fi

# Verificar conectividade PostgreSQL
if [ $postgres_running -eq 0 ]; then
    check_connectivity "postgres_db" "PostgreSQL" "pg_isready -h localhost"
fi

# Verificar conectividade SQL Server
if [ $sqlserver_running -eq 0 ]; then
    check_connectivity "sqlserver_db" "SQL Server" "/opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P '${SA_PASSWORD}' -C -Q 'SELECT 1' -h -1"
fi

echo ""
echo "🗄️ Verificando estrutura de bancos..."

# Verificar se as tabelas foram criadas
if [ $mysql_running -eq 0 ]; then
    if docker exec mysql_db mysql -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SHOW TABLES;" &>/dev/null; then
        table_count=$(docker exec mysql_db mysql -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SHOW TABLES;" 2>/dev/null | wc -l)
        if [ $table_count -gt 1 ]; then
            print_status 0 "MySQL: Tabelas criadas ($((table_count-1)) tabelas)"
        else
            print_status 1 "MySQL: Nenhuma tabela encontrada"
        fi
    fi
fi

if [ $postgres_running -eq 0 ]; then
    if docker exec postgres_db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "\dt" &>/dev/null; then
        table_count=$(docker exec postgres_db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "\dt" 2>/dev/null | grep "public" | wc -l)
        if [ $table_count -gt 0 ]; then
            print_status 0 "PostgreSQL: Tabelas criadas ($table_count tabelas)"
        else
            print_status 1 "PostgreSQL: Nenhuma tabela encontrada"
        fi
    fi
fi

echo ""
echo "📊 Resumo do Health Check:"
docker-compose ps

echo ""
echo -e "${YELLOW}💡 Dicas:${NC}"
echo "• Para reconectar a um banco: make <banco>-cli"
echo "• Para carregar dados de exemplo: make load-sample-data"  
echo "• Para ver logs: make logs"
echo "• Para resetar tudo: make clean && make up"

echo ""
echo "✅ Validação concluída!"