#!/bin/bash

# Script de benchmark básico para comparar performance entre bancos
# Executa queries simples e mede tempo de resposta

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏁 Benchmark Básico dos Bancos de Dados${NC}"
echo "=========================================="
echo "Executando queries simples para comparar performance..."
echo ""

# Função para medir tempo de execução
measure_time() {
    local start_time=$(date +%s.%N)
    eval "$1" >/dev/null 2>&1
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc -l)
    printf "%.3f" $duration
}

# Test queries
SIMPLE_SELECT="SELECT COUNT(*) FROM clientes"
JOIN_QUERY="SELECT c.nome, COUNT(p.id) FROM clientes c LEFT JOIN pedidos p ON c.id = p.cliente_id GROUP BY c.id, c.nome"

echo -e "${YELLOW}📊 Teste 1: SELECT simples (COUNT)${NC}"

# MySQL
echo -n "MySQL: "
mysql_time=$(measure_time "docker exec mysql_db mysql -u$(grep '^DB_USER' .env | cut -d '=' -f2) -p$(grep '^DB_PASSWORD' .env | cut -d '=' -f2) $(grep '^DB_NAME' .env | cut -d '=' -f2) -e \"$SIMPLE_SELECT\"")
echo -e "${GREEN}${mysql_time}s${NC}"

# PostgreSQL
echo -n "PostgreSQL: "
postgres_time=$(measure_time "docker exec postgres_db psql -U $(grep '^POSTGRES_USER' .env | cut -d '=' -f2) -d $(grep '^POSTGRES_DB' .env | cut -d '=' -f2) -c \"$SIMPLE_SELECT\"")
echo -e "${GREEN}${postgres_time}s${NC}"

# SQL Server
echo -n "SQL Server: "
sqlserver_time=$(measure_time "docker exec sqlserver_db /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P \"$(grep '^SA_PASSWORD' .env | cut -d '=' -f2)\" -C -Q \"$SIMPLE_SELECT\"")
echo -e "${GREEN}${sqlserver_time}s${NC}"

echo ""
echo -e "${YELLOW}📊 Teste 2: JOIN e GROUP BY${NC}"

# MySQL
echo -n "MySQL: "
mysql_join_time=$(measure_time "docker exec mysql_db mysql -u$(grep '^DB_USER' .env | cut -d '=' -f2) -p$(grep '^DB_PASSWORD' .env | cut -d '=' -f2) $(grep '^DB_NAME' .env | cut -d '=' -f2) -e \"$JOIN_QUERY\"")
echo -e "${GREEN}${mysql_join_time}s${NC}"

# PostgreSQL
echo -n "PostgreSQL: "
postgres_join_time=$(measure_time "docker exec postgres_db psql -U $(grep '^POSTGRES_USER' .env | cut -d '=' -f2) -d $(grep '^POSTGRES_DB' .env | cut -d '=' -f2) -c \"$JOIN_QUERY\"")
echo -e "${GREEN}${postgres_join_time}s${NC}"

# SQL Server
echo -n "SQL Server: "
sqlserver_join_time=$(measure_time "docker exec sqlserver_db /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P \"$(grep '^SA_PASSWORD' .env | cut -d '=' -f2)\" -C -Q \"$JOIN_QUERY\"")
echo -e "${GREEN}${sqlserver_join_time}s${NC}"

echo ""
echo -e "${BLUE}📈 Resumo do Benchmark:${NC}"
echo "========================"
echo -e "SELECT simples:"
echo -e "  MySQL:      ${mysql_time}s"
echo -e "  PostgreSQL: ${postgres_time}s"
echo -e "  SQL Server: ${sqlserver_time}s"
echo ""
echo -e "JOIN complexo:"
echo -e "  MySQL:      ${mysql_join_time}s"
echo -e "  PostgreSQL: ${postgres_join_time}s"
echo -e "  SQL Server: ${sqlserver_join_time}s"

echo ""
echo -e "${YELLOW}⚠️  Nota:${NC} Este é um benchmark básico para referência."
echo -e "Para testes de performance detalhados, use ferramentas especializadas."