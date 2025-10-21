#!/bin/bash

# Script de testes automatizados para o ambiente de bancos de dados
# Executa testes de integração, performance e segurança

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
TEST_LOG="${PROJECT_DIR}/logs/test-results.log"
TEST_DATA_DIR="${PROJECT_DIR}/tests/data"

# Criar diretórios necessários
mkdir -p "${PROJECT_DIR}/logs" "${PROJECT_DIR}/tests/data"

# Função de logging
log_test() {
    local level=$1
    local test_name=$2
    local result=$3
    local details=$4
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $test_name: $result - $details" >> "$TEST_LOG"
}

# Função para executar teste
run_test() {
    local test_name=$1
    local test_command=$2
    local expected_exit_code=${3:-0}
    
    echo -n "🧪 $test_name: "
    
    local start_time=$(date +%s.%N)
    if eval "$test_command" &>/dev/null; then
        local exit_code=0
    else
        local exit_code=$?
    fi
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc -l)
    
    if [ $exit_code -eq $expected_exit_code ]; then
        echo -e "${GREEN}PASSOU${NC} ($(printf "%.3f" $duration)s)"
        log_test "PASS" "$test_name" "SUCCESS" "Duration: ${duration}s"
        return 0
    else
        echo -e "${RED}FALHOU${NC} (exit code: $exit_code)"
        log_test "FAIL" "$test_name" "FAILED" "Exit code: $exit_code, Duration: ${duration}s"
        return 1
    fi
}

# Função para executar teste de performance
run_performance_test() {
    local test_name=$1
    local test_command=$2
    local max_time=$3
    
    echo -n "⚡ $test_name: "
    
    local start_time=$(date +%s.%N)
    eval "$test_command" &>/dev/null
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc -l)
    
    if [ $(echo "$duration < $max_time" | bc -l) -eq 1 ]; then
        echo -e "${GREEN}PASSOU${NC} ($(printf "%.3f" $duration)s < ${max_time}s)"
        log_test "PERF" "$test_name" "SUCCESS" "Duration: ${duration}s, Limit: ${max_time}s"
        return 0
    else
        echo -e "${YELLOW}LENTO${NC} ($(printf "%.3f" $duration)s > ${max_time}s)"
        log_test "PERF" "$test_name" "SLOW" "Duration: ${duration}s, Limit: ${max_time}s"
        return 1
    fi
}

# Carregar variáveis de ambiente
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo -e "${RED}❌ Arquivo .env não encontrado${NC}"
    exit 1
fi

echo -e "${PURPLE}🧪 SUITE DE TESTES AUTOMATIZADOS${NC}"
echo "=================================="

# Inicializar contadores
total_tests=0
passed_tests=0
failed_tests=0

# Função para contar teste
count_test() {
    ((total_tests++))
    if [ $1 -eq 0 ]; then
        ((passed_tests++))
    else
        ((failed_tests++))
    fi
}

echo -e "\n${BLUE}📦 Testes de Containers${NC}"
echo "========================"

run_test "MySQL container está rodando" "docker ps | grep -q mysql_db"
count_test $?

run_test "PostgreSQL container está rodando" "docker ps | grep -q postgres_db"
count_test $?

run_test "SQL Server container está rodando" "docker ps | grep -q sqlserver_db"
count_test $?

echo -e "\n${BLUE}🔌 Testes de Conectividade${NC}"
echo "============================"

run_test "MySQL aceita conexões" "docker exec mysql_db mysql -u${DB_USER} -p${DB_PASSWORD} -e 'SELECT 1;'"
count_test $?

run_test "PostgreSQL aceita conexões" "docker exec postgres_db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c 'SELECT 1;'"
count_test $?

run_test "SQL Server aceita conexões" "docker exec sqlserver_db /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P '${SA_PASSWORD}' -C -Q 'SELECT 1;'"
count_test $?

echo -e "\n${BLUE}🗄️ Testes de Estrutura de Dados${NC}"
echo "=================================="

run_test "MySQL: Tabelas existem" "docker exec mysql_db mysql -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e 'SHOW TABLES;' | grep -q clientes"
count_test $?

run_test "PostgreSQL: Tabelas existem" "docker exec postgres_db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c '\\dt' | grep -q clientes"
count_test $?

run_test "SQL Server: Tabelas existem" "docker exec sqlserver_db /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P '${SA_PASSWORD}' -C -Q 'SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = \'clientes\';' | grep -q '1'"
count_test $?

echo -e "\n${BLUE}📊 Testes de Dados${NC}"
echo "==================="

run_test "MySQL: Inserir dados" "docker exec mysql_db mysql -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e \"INSERT INTO clientes (nome, email) VALUES ('Teste User', 'teste@test.com');\""
count_test $?

run_test "PostgreSQL: Inserir dados" "docker exec postgres_db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c \"INSERT INTO clientes (nome, email) VALUES ('Teste User PG', 'teste.pg@test.com');\""
count_test $?

run_test "MySQL: Consultar dados" "docker exec mysql_db mysql -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e 'SELECT COUNT(*) FROM clientes;' | grep -E '[0-9]+'"
count_test $?

run_test "PostgreSQL: Consultar dados" "docker exec postgres_db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c 'SELECT COUNT(*) FROM clientes;' | grep -E '[0-9]+'"
count_test $?

echo -e "\n${BLUE}⚡ Testes de Performance${NC}"
echo "=========================="

run_performance_test "MySQL: SELECT rápido" "docker exec mysql_db mysql -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e 'SELECT COUNT(*) FROM clientes;'" 2.0
count_test $?

run_performance_test "PostgreSQL: SELECT rápido" "docker exec postgres_db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c 'SELECT COUNT(*) FROM clientes;'" 2.0
count_test $?

echo -e "\n${BLUE}🔒 Testes de Segurança Básicos${NC}"
echo "==============================="

run_test "MySQL: Conexão sem senha falha" "docker exec mysql_db mysql -u${DB_USER} -e 'SELECT 1;'" 1
count_test $?

run_test "PostgreSQL: Usuário inválido falha" "docker exec postgres_db psql -U invalid_user -d ${POSTGRES_DB} -c 'SELECT 1;'" 1
count_test $?

echo -e "\n${BLUE}🕒 Testes de Campos de Auditoria${NC}"
echo "=================================="

run_test "MySQL: Campo created_at existe" "docker exec mysql_db mysql -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e 'SELECT created_at FROM clientes LIMIT 1;'"
count_test $?

run_test "PostgreSQL: Campo updated_at existe" "docker exec postgres_db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c 'SELECT updated_at FROM clientes LIMIT 1;'"
count_test $?

run_test "MySQL: Trigger de updated_at funciona" "docker exec mysql_db mysql -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e \"UPDATE clientes SET nome='Updated Name' WHERE id=1; SELECT updated_at > created_at FROM clientes WHERE id=1;\" | grep -q '1'"
count_test $?

echo -e "\n${BLUE}💾 Testes de Backup e Restauração${NC}"
echo "=================================="

run_test "MySQL: Backup funciona" "docker exec mysql_db mysqldump -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} > /tmp/test_backup_mysql.sql"
count_test $?

run_test "PostgreSQL: Backup funciona" "docker exec postgres_db pg_dump -U ${POSTGRES_USER} ${POSTGRES_DB} > /tmp/test_backup_postgres.sql"
count_test $?

run_test "Arquivo de backup MySQL não está vazio" "[ -s /tmp/test_backup_mysql.sql ]"
count_test $?

run_test "Arquivo de backup PostgreSQL não está vazio" "[ -s /tmp/test_backup_postgres.sql ]"
count_test $?

echo -e "\n${BLUE}🌐 Testes de Rede${NC}"
echo "=================="

run_test "Porta MySQL (3306) está aberta" "nc -z localhost 3306"
count_test $?

run_test "Porta PostgreSQL (5432) está aberta" "nc -z localhost 5432"
count_test $?

run_test "Porta SQL Server (1433) está aberta" "nc -z localhost 1433"
count_test $?

echo -e "\n${BLUE}📈 Testes de Monitoramento${NC}"
echo "=========================="

run_test "Health check script executa sem erro" "./scripts/health-check.sh"
count_test $?

run_test "Backup automático executa sem erro" "./scripts/backup-auto.sh --mysql"
count_test $?

run_test "Validação do ambiente passa" "./scripts/validate.sh"
count_test $?

# Limpeza de arquivos de teste
rm -f /tmp/test_backup_*.sql

# Relatório final
echo -e "\n${PURPLE}📊 RELATÓRIO FINAL${NC}"
echo "=================="
echo -e "Total de testes: $total_tests"
echo -e "✅ Passou: ${GREEN}$passed_tests${NC}"
echo -e "❌ Falhou: ${RED}$failed_tests${NC}"

# Calcular percentual de sucesso
success_rate=$(echo "scale=1; $passed_tests * 100 / $total_tests" | bc -l)
echo -e "📈 Taxa de sucesso: ${success_rate}%"

# Gerar relatório detalhado
echo -e "\n${BLUE}📄 Relatório salvo em: $TEST_LOG${NC}"

# Status de saída baseado nos resultados
if [ $failed_tests -eq 0 ]; then
    echo -e "\n${GREEN}🎉 Todos os testes passaram!${NC}"
    exit 0
elif [ $failed_tests -le 2 ]; then
    echo -e "\n${YELLOW}⚠️ Alguns testes falharam, mas o sistema está funcional${NC}"
    exit 1
else
    echo -e "\n${RED}❌ Muitos testes falharam - verifique o ambiente${NC}"
    exit 2
fi