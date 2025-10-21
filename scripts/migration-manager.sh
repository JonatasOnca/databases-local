#!/bin/bash

# Sistema de migração de dados entre bancos de dados
# Permite transferir dados entre MySQL, PostgreSQL e SQL Server

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
MIGRATION_DIR="${PROJECT_DIR}/migrations"
LOG_FILE="${MIGRATION_DIR}/migration.log"

# Criar estrutura de diretórios
mkdir -p "${MIGRATION_DIR}"/{export,import,schema,data}

# Função de logging
log_migration() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Função para validar parâmetros
validate_database_type() {
    local db_type=$1
    case $db_type in
        mysql|postgres|sqlserver)
            return 0
            ;;
        *)
            echo -e "${RED}❌ Tipo de banco inválido: $db_type${NC}"
            echo "Tipos suportados: mysql, postgres, sqlserver"
            return 1
            ;;
    esac
}

# Função para testar conectividade
test_connection() {
    local db_type=$1
    
    case $db_type in
        mysql)
            docker exec mysql_db mysql -u"${DB_USER}" -p"${DB_PASSWORD}" -e "SELECT 1;" &>/dev/null
            ;;
        postgres)
            docker exec postgres_db psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c "SELECT 1;" &>/dev/null
            ;;
        sqlserver)
            docker exec sqlserver_db /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "${SA_PASSWORD}" -C -Q "SELECT 1;" &>/dev/null
            ;;
    esac
}

# Função para exportar esquema
export_schema() {
    local db_type=$1
    local output_file="${MIGRATION_DIR}/schema/schema_${db_type}_$(date +%Y%m%d_%H%M%S).sql"
    
    echo -e "${BLUE}📋 Exportando esquema do $db_type...${NC}"
    
    case $db_type in
        mysql)
            docker exec mysql_db mysqldump \
                -u"${DB_USER}" -p"${DB_PASSWORD}" \
                --no-data \
                --routines \
                --triggers \
                --events \
                "${DB_NAME}" > "$output_file"
            ;;
        postgres)
            docker exec postgres_db pg_dump \
                -U "${POSTGRES_USER}" \
                --schema-only \
                --no-owner \
                --no-privileges \
                "${POSTGRES_DB}" > "$output_file"
            ;;
        sqlserver)
            # SQL Server schema export (simplificado)
            docker exec sqlserver_db /opt/mssql-tools18/bin/sqlcmd \
                -S localhost -U SA -P "${SA_PASSWORD}" -C \
                -Q "SELECT 
                    'CREATE TABLE ' + TABLE_NAME + ' (' +
                    STUFF((
                        SELECT ', ' + COLUMN_NAME + ' ' + DATA_TYPE +
                        CASE 
                            WHEN CHARACTER_MAXIMUM_LENGTH IS NOT NULL 
                            THEN '(' + CAST(CHARACTER_MAXIMUM_LENGTH AS varchar) + ')'
                            ELSE ''
                        END
                        FROM INFORMATION_SCHEMA.COLUMNS c2
                        WHERE c2.TABLE_NAME = c1.TABLE_NAME
                        FOR XML PATH('')
                    ), 1, 2, '') + ');'
                    FROM INFORMATION_SCHEMA.TABLES c1
                    WHERE TABLE_TYPE = 'BASE TABLE';" > "$output_file"
            ;;
    esac
    
    if [ -s "$output_file" ]; then
        echo -e "${GREEN}✅ Esquema exportado: $output_file${NC}"
        log_migration "INFO" "Schema exported for $db_type to $output_file"
        echo "$output_file"
    else
        echo -e "${RED}❌ Falha ao exportar esquema${NC}"
        log_migration "ERROR" "Failed to export schema for $db_type"
        return 1
    fi
}

# Função para exportar dados
export_data() {
    local db_type=$1
    local tables=${2:-"all"}
    local output_file="${MIGRATION_DIR}/export/data_${db_type}_$(date +%Y%m%d_%H%M%S).sql"
    
    echo -e "${BLUE}📊 Exportando dados do $db_type...${NC}"
    
    case $db_type in
        mysql)
            if [ "$tables" = "all" ]; then
                docker exec mysql_db mysqldump \
                    -u"${DB_USER}" -p"${DB_PASSWORD}" \
                    --no-create-info \
                    --single-transaction \
                    --hex-blob \
                    --default-character-set=utf8mb4 \
                    "${DB_NAME}" > "$output_file"
            else
                docker exec mysql_db mysqldump \
                    -u"${DB_USER}" -p"${DB_PASSWORD}" \
                    --no-create-info \
                    --single-transaction \
                    --hex-blob \
                    --default-character-set=utf8mb4 \
                    "${DB_NAME}" $tables > "$output_file"
            fi
            ;;
        postgres)
            if [ "$tables" = "all" ]; then
                docker exec postgres_db pg_dump \
                    -U "${POSTGRES_USER}" \
                    --data-only \
                    --no-owner \
                    --no-privileges \
                    --column-inserts \
                    "${POSTGRES_DB}" > "$output_file"
            else
                for table in $tables; do
                    docker exec postgres_db pg_dump \
                        -U "${POSTGRES_USER}" \
                        --data-only \
                        --no-owner \
                        --no-privileges \
                        --column-inserts \
                        --table="$table" \
                        "${POSTGRES_DB}" >> "$output_file"
                done
            fi
            ;;
        sqlserver)
            # SQL Server data export usando BCP (simplificado)
            echo -e "${YELLOW}⚠️ Exportação de dados do SQL Server em formato básico${NC}"
            docker exec sqlserver_db /opt/mssql-tools18/bin/sqlcmd \
                -S localhost -U SA -P "${SA_PASSWORD}" -C \
                -Q "SELECT 'INSERT INTO clientes VALUES (' + 
                    CAST(id AS varchar) + ', ''' + nome + ''', ''' + email + ''');'
                    FROM clientes;" > "$output_file"
            ;;
    esac
    
    if [ -s "$output_file" ]; then
        echo -e "${GREEN}✅ Dados exportados: $output_file${NC}"
        log_migration "INFO" "Data exported for $db_type to $output_file"
        echo "$output_file"
    else
        echo -e "${RED}❌ Falha ao exportar dados${NC}"
        log_migration "ERROR" "Failed to export data for $db_type"
        return 1
    fi
}

# Função para converter esquema entre bancos
convert_schema() {
    local source_type=$1
    local target_type=$2
    local input_file=$3
    local output_file="${MIGRATION_DIR}/schema/converted_${source_type}_to_${target_type}_$(date +%Y%m%d_%H%M%S).sql"
    
    echo -e "${BLUE}🔄 Convertendo esquema de $source_type para $target_type...${NC}"
    
    # Conversões básicas (expandir conforme necessário)
    case "${source_type}_to_${target_type}" in
        mysql_to_postgres)
            # Conversões MySQL -> PostgreSQL
            sed -e 's/AUTO_INCREMENT/SERIAL/g' \
                -e 's/INT PRIMARY KEY AUTO_INCREMENT/SERIAL PRIMARY KEY/g' \
                -e 's/VARCHAR(/TEXT CHECK (char_length(/g' \
                -e 's/TIMESTAMP DEFAULT CURRENT_TIMESTAMP/TIMESTAMP DEFAULT CURRENT_TIMESTAMP/g' \
                -e 's/ENGINE=InnoDB//g' \
                -e 's/`//g' \
                "$input_file" > "$output_file"
            ;;
        postgres_to_mysql)
            # Conversões PostgreSQL -> MySQL
            sed -e 's/SERIAL/INT AUTO_INCREMENT/g' \
                -e 's/TEXT/VARCHAR(255)/g' \
                -e 's/BOOLEAN/TINYINT(1)/g' \
                -e 's/TIMESTAMP/DATETIME/g' \
                "$input_file" > "$output_file"
            ;;
        mysql_to_sqlserver)
            # Conversões MySQL -> SQL Server
            sed -e 's/AUTO_INCREMENT/IDENTITY(1,1)/g' \
                -e 's/VARCHAR(/NVARCHAR(/g' \
                -e 's/TEXT/NVARCHAR(MAX)/g' \
                -e 's/TIMESTAMP/DATETIME2/g' \
                -e 's/`/[/g' \
                -e 's/`/]/g' \
                "$input_file" > "$output_file"
            ;;
        *)
            echo -e "${YELLOW}⚠️ Conversão automática não implementada para ${source_type} -> ${target_type}${NC}"
            cp "$input_file" "$output_file"
            ;;
    esac
    
    echo -e "${GREEN}✅ Esquema convertido: $output_file${NC}"
    log_migration "INFO" "Schema converted from $source_type to $target_type"
    echo "$output_file"
}

# Função para importar dados
import_data() {
    local db_type=$1
    local input_file=$2
    
    echo -e "${BLUE}📥 Importando dados para $db_type...${NC}"
    
    if [ ! -f "$input_file" ]; then
        echo -e "${RED}❌ Arquivo não encontrado: $input_file${NC}"
        return 1
    fi
    
    case $db_type in
        mysql)
            docker exec -i mysql_db mysql \
                -u"${DB_USER}" -p"${DB_PASSWORD}" \
                "${DB_NAME}" < "$input_file"
            ;;
        postgres)
            docker exec -i postgres_db psql \
                -U "${POSTGRES_USER}" \
                -d "${POSTGRES_DB}" < "$input_file"
            ;;
        sqlserver)
            docker exec -i sqlserver_db /opt/mssql-tools18/bin/sqlcmd \
                -S localhost -U SA -P "${SA_PASSWORD}" -C \
                -i /dev/stdin < "$input_file"
            ;;
    esac
    
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✅ Dados importados com sucesso${NC}"
        log_migration "INFO" "Data imported successfully to $db_type"
    else
        echo -e "${RED}❌ Falha ao importar dados (código: $exit_code)${NC}"
        log_migration "ERROR" "Failed to import data to $db_type (exit code: $exit_code)"
        return 1
    fi
}

# Função para migração completa
migrate_full() {
    local source_db=$1
    local target_db=$2
    local include_schema=${3:-true}
    local include_data=${4:-true}
    
    echo -e "${PURPLE}🚀 MIGRAÇÃO COMPLETA: $source_db → $target_db${NC}"
    echo "================================================"
    
    # Validar bancos
    validate_database_type "$source_db" || return 1
    validate_database_type "$target_db" || return 1
    
    # Testar conectividade
    echo -e "${BLUE}🔍 Testando conectividade...${NC}"
    if ! test_connection "$source_db"; then
        echo -e "${RED}❌ Não é possível conectar ao banco de origem: $source_db${NC}"
        return 1
    fi
    
    if ! test_connection "$target_db"; then
        echo -e "${RED}❌ Não é possível conectar ao banco de destino: $target_db${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Conectividade confirmada${NC}"
    
    # Exportar e converter esquema
    if [ "$include_schema" = "true" ]; then
        local schema_file=$(export_schema "$source_db") || return 1
        
        if [ "$source_db" != "$target_db" ]; then
            local converted_schema=$(convert_schema "$source_db" "$target_db" "$schema_file") || return 1
            echo -e "${BLUE}📥 Importando esquema convertido...${NC}"
            import_data "$target_db" "$converted_schema" || return 1
        else
            echo -e "${BLUE}📥 Importando esquema...${NC}"
            import_data "$target_db" "$schema_file" || return 1
        fi
    fi
    
    # Exportar e importar dados
    if [ "$include_data" = "true" ]; then
        local data_file=$(export_data "$source_db") || return 1
        echo -e "${BLUE}📥 Importando dados...${NC}"
        import_data "$target_db" "$data_file" || return 1
    fi
    
    echo -e "${GREEN}🎉 Migração concluída com sucesso!${NC}"
    log_migration "INFO" "Full migration completed: $source_db -> $target_db"
}

# Função para sincronização incremental
sync_incremental() {
    local source_db=$1
    local target_db=$2
    local since_timestamp=${3:-"24 hours ago"}
    
    echo -e "${BLUE}🔄 Sincronização incremental: $source_db → $target_db${NC}"
    echo "Desde: $since_timestamp"
    
    # Implementação básica - pode ser expandida
    case $source_db in
        mysql)
            local query="SELECT * FROM clientes WHERE updated_at >= DATE_SUB(NOW(), INTERVAL 1 DAY);"
            docker exec mysql_db mysql -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" -e "$query" > "${MIGRATION_DIR}/data/incremental_$(date +%Y%m%d_%H%M%S).sql"
            ;;
        postgres)
            local query="SELECT * FROM clientes WHERE updated_at >= NOW() - INTERVAL '1 day';"
            docker exec postgres_db psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c "$query" > "${MIGRATION_DIR}/data/incremental_$(date +%Y%m%d_%H%M%S).sql"
            ;;
    esac
    
    echo -e "${GREEN}✅ Sincronização incremental concluída${NC}"
}

# Função para validar migração
validate_migration() {
    local source_db=$1
    local target_db=$2
    
    echo -e "${BLUE}✅ Validando migração...${NC}"
    
    # Contar registros em cada tabela
    local tables=("clientes" "produtos" "pedidos" "itens_pedido" "logs")
    local validation_passed=true
    
    for table in "${tables[@]}"; do
        echo -n "📊 Tabela $table: "
        
        local source_count=0
        local target_count=0
        
        # Contar registros na origem
        case $source_db in
            mysql)
                source_count=$(docker exec mysql_db mysql -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" -e "SELECT COUNT(*) FROM $table;" -s -N 2>/dev/null || echo "0")
                ;;
            postgres)
                source_count=$(docker exec postgres_db psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c "SELECT COUNT(*) FROM $table;" -t 2>/dev/null | tr -d ' ' || echo "0")
                ;;
        esac
        
        # Contar registros no destino
        case $target_db in
            mysql)
                target_count=$(docker exec mysql_db mysql -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" -e "SELECT COUNT(*) FROM $table;" -s -N 2>/dev/null || echo "0")
                ;;
            postgres)
                target_count=$(docker exec postgres_db psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c "SELECT COUNT(*) FROM $table;" -t 2>/dev/null | tr -d ' ' || echo "0")
                ;;
        esac
        
        if [ "$source_count" = "$target_count" ]; then
            echo -e "${GREEN}OK ($source_count registros)${NC}"
        else
            echo -e "${RED}FALHA (origem: $source_count, destino: $target_count)${NC}"
            validation_passed=false
        fi
    done
    
    if [ "$validation_passed" = true ]; then
        echo -e "${GREEN}🎉 Validação passou - migração bem-sucedida!${NC}"
        log_migration "INFO" "Migration validation passed"
        return 0
    else
        echo -e "${RED}❌ Validação falhou - verificar dados${NC}"
        log_migration "ERROR" "Migration validation failed"
        return 1
    fi
}

# Função para mostrar ajuda
show_help() {
    echo "Sistema de Migração de Dados"
    echo "============================="
    echo ""
    echo "Uso: $0 [comando] [opções]"
    echo ""
    echo "Comandos:"
    echo "  export-schema <db_type>              - Exporta esquema do banco"
    echo "  export-data <db_type> [tables]       - Exporta dados do banco"
    echo "  import-data <db_type> <file>         - Importa dados para o banco"
    echo "  migrate <source> <target>            - Migração completa"
    echo "  migrate-schema <source> <target>     - Migra apenas esquema"
    echo "  migrate-data <source> <target>       - Migra apenas dados"
    echo "  sync <source> <target> [timestamp]   - Sincronização incremental"
    echo "  validate <source> <target>           - Valida migração"
    echo "  list-migrations                      - Lista migrações realizadas"
    echo ""
    echo "Tipos de banco suportados:"
    echo "  mysql, postgres, sqlserver"
    echo ""
    echo "Exemplos:"
    echo "  $0 migrate mysql postgres            # Migração completa"
    echo "  $0 export-data mysql                 # Exportar todos os dados"
    echo "  $0 validate mysql postgres           # Validar migração"
}

# Função principal
main() {
    # Carregar variáveis de ambiente
    if [ -f ".env" ]; then
        export $(grep -v '^#' .env | xargs)
    else
        echo -e "${RED}❌ Arquivo .env não encontrado${NC}"
        exit 1
    fi
    
    case "${1:-help}" in
        export-schema)
            export_schema "${2}"
            ;;
        export-data)
            export_data "${2}" "${3:-all}"
            ;;
        import-data)
            import_data "${2}" "${3}"
            ;;
        migrate)
            migrate_full "${2}" "${3}"
            ;;
        migrate-schema)
            migrate_full "${2}" "${3}" true false
            ;;
        migrate-data)
            migrate_full "${2}" "${3}" false true
            ;;
        sync)
            sync_incremental "${2}" "${3}" "${4}"
            ;;
        validate)
            validate_migration "${2}" "${3}"
            ;;
        list-migrations)
            echo -e "${BLUE}📋 Arquivos de migração:${NC}"
            find "${MIGRATION_DIR}" -name "*.sql" -exec ls -lh {} \; 2>/dev/null || echo "Nenhuma migração encontrada"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo "Comando inválido: $1"
            show_help
            exit 1
            ;;
    esac
}

# Executar se chamado diretamente
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi