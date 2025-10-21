#!/bin/bash

# Script de backup automatizado para bancos de dados
# Suporta backup incremental, compressão e rotação automática

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="${PROJECT_DIR}/backups"
LOG_FILE="${BACKUP_DIR}/backup.log"
RETENTION_DAYS=30
COMPRESSION_LEVEL=6

# Função de logging
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Função para criar estrutura de diretórios
setup_backup_structure() {
    local today=$(date '+%Y-%m-%d')
    
    mkdir -p "${BACKUP_DIR}"/{mysql,postgres,sqlserver}
    mkdir -p "${BACKUP_DIR}/archive"
    mkdir -p "${BACKUP_DIR}/logs"
    
    log_message "INFO" "Backup structure created"
}

# Função para verificar espaço em disco
check_disk_space() {
    local required_space_gb=2
    local available_space=$(df "${BACKUP_DIR}" | awk 'NR==2{print int($4/1024/1024)}')
    
    if [ "$available_space" -lt "$required_space_gb" ]; then
        log_message "ERROR" "Insufficient disk space. Required: ${required_space_gb}GB, Available: ${available_space}GB"
        echo -e "${RED}❌ Espaço insuficiente em disco${NC}"
        exit 1
    fi
    
    log_message "INFO" "Disk space check passed: ${available_space}GB available"
}

# Função para backup do MySQL
backup_mysql() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="${BACKUP_DIR}/mysql/mysql_backup_${timestamp}.sql"
    local compressed_file="${backup_file}.gz"
    
    echo -e "${BLUE}🔄 Fazendo backup do MySQL...${NC}"
    
    if ! docker exec mysql_db mysqldump \
        -u$(grep '^DB_USER' .env | cut -d '=' -f2) \
        -p$(grep '^DB_PASSWORD' .env | cut -d '=' -f2) \
        --single-transaction \
        --routines \
        --triggers \
        --events \
        --hex-blob \
        --add-drop-database \
        --databases $(grep '^DB_NAME' .env | cut -d '=' -f2) > "$backup_file" 2>/dev/null; then
        
        log_message "ERROR" "MySQL backup failed"
        echo -e "${RED}❌ Backup do MySQL falhou${NC}"
        return 1
    fi
    
    # Comprimir backup
    gzip -"$COMPRESSION_LEVEL" "$backup_file"
    
    local file_size=$(du -h "$compressed_file" | cut -f1)
    log_message "INFO" "MySQL backup completed: ${compressed_file} (${file_size})"
    echo -e "${GREEN}✅ MySQL backup: ${file_size}${NC}"
    
    return 0
}

# Função para backup do PostgreSQL
backup_postgres() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="${BACKUP_DIR}/postgres/postgres_backup_${timestamp}.sql"
    local compressed_file="${backup_file}.gz"
    
    echo -e "${BLUE}🔄 Fazendo backup do PostgreSQL...${NC}"
    
    if ! docker exec postgres_db pg_dump \
        -U $(grep '^POSTGRES_USER' .env | cut -d '=' -f2) \
        --verbose \
        --clean \
        --if-exists \
        --create \
        --format=plain \
        $(grep '^POSTGRES_DB' .env | cut -d '=' -f2) > "$backup_file" 2>/dev/null; then
        
        log_message "ERROR" "PostgreSQL backup failed"
        echo -e "${RED}❌ Backup do PostgreSQL falhou${NC}"
        return 1
    fi
    
    # Comprimir backup
    gzip -"$COMPRESSION_LEVEL" "$backup_file"
    
    local file_size=$(du -h "$compressed_file" | cut -f1)
    log_message "INFO" "PostgreSQL backup completed: ${compressed_file} (${file_size})"
    echo -e "${GREEN}✅ PostgreSQL backup: ${file_size}${NC}"
    
    return 0
}

# Função para backup do SQL Server
backup_sqlserver() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="${BACKUP_DIR}/sqlserver/sqlserver_backup_${timestamp}.bak"
    local export_file="${BACKUP_DIR}/sqlserver/sqlserver_export_${timestamp}.sql"
    local compressed_file="${export_file}.gz"
    
    echo -e "${BLUE}🔄 Fazendo backup do SQL Server...${NC}"
    
    # Backup nativo do SQL Server (arquivo .bak)
    if ! docker exec sqlserver_db /opt/mssql-tools18/bin/sqlcmd \
        -S localhost -U SA -P "$(grep '^SA_PASSWORD' .env | cut -d '=' -f2)" -C \
        -Q "BACKUP DATABASE [master] TO DISK = '/tmp/backup.bak' WITH FORMAT, INIT;" &>/dev/null; then
        
        log_message "WARN" "SQL Server native backup failed, trying export"
    else
        # Copiar backup do container
        docker cp sqlserver_db:/tmp/backup.bak "$backup_file"
        gzip -"$COMPRESSION_LEVEL" "$backup_file"
        local file_size=$(du -h "${backup_file}.gz" | cut -f1)
        echo -e "${GREEN}✅ SQL Server backup: ${file_size}${NC}"
    fi
    
    # Export as SQL (fallback)
    if docker exec sqlserver_db /opt/mssql-tools18/bin/sqlcmd \
        -S localhost -U SA -P "$(grep '^SA_PASSWORD' .env | cut -d '=' -f2)" -C \
        -Q "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE';" > "$export_file" 2>/dev/null; then
        
        gzip -"$COMPRESSION_LEVEL" "$export_file"
        local export_size=$(du -h "$compressed_file" | cut -f1)
        log_message "INFO" "SQL Server export completed: ${compressed_file} (${export_size})"
        echo -e "${GREEN}✅ SQL Server export: ${export_size}${NC}"
    fi
    
    return 0
}

# Função para limpar backups antigos
cleanup_old_backups() {
    echo -e "${BLUE}🧹 Limpando backups antigos (>${RETENTION_DAYS} dias)...${NC}"
    
    local removed_count=0
    
    # Buscar e remover arquivos antigos
    find "${BACKUP_DIR}" -name "*.gz" -type f -mtime +${RETENTION_DAYS} -exec rm {} \; -exec bash -c 'echo "Removido: $1"' _ {} \; | while read line; do
        if [[ $line == "Removido:"* ]]; then
            ((removed_count++))
            log_message "INFO" "$line"
        fi
    done
    
    # Mover backups muito antigos para arquivo
    find "${BACKUP_DIR}" -name "*.gz" -type f -mtime +$((RETENTION_DAYS * 2)) -exec mv {} "${BACKUP_DIR}/archive/" \; 2>/dev/null || true
    
    log_message "INFO" "Cleanup completed: ${removed_count} files removed"
    echo -e "${GREEN}✅ Limpeza concluída${NC}"
}

# Função para gerar relatório de backup
generate_backup_report() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local report_file="${BACKUP_DIR}/backup_report_$(date '+%Y%m%d').txt"
    
    echo "RELATÓRIO DE BACKUP - $timestamp" > "$report_file"
    echo "=======================================" >> "$report_file"
    echo "" >> "$report_file"
    
    # Estatísticas de backups
    echo "📊 ESTATÍSTICAS:" >> "$report_file"
    echo "MySQL backups: $(find "${BACKUP_DIR}/mysql" -name "*.gz" | wc -l)" >> "$report_file"
    echo "PostgreSQL backups: $(find "${BACKUP_DIR}/postgres" -name "*.gz" | wc -l)" >> "$report_file"
    echo "SQL Server backups: $(find "${BACKUP_DIR}/sqlserver" -name "*.gz" | wc -l)" >> "$report_file"
    echo "" >> "$report_file"
    
    # Tamanho total
    local total_size=$(du -sh "${BACKUP_DIR}" | cut -f1)
    echo "💾 Tamanho total dos backups: $total_size" >> "$report_file"
    echo "" >> "$report_file"
    
    # Backups mais recentes
    echo "📅 BACKUPS MAIS RECENTES:" >> "$report_file"
    find "${BACKUP_DIR}" -name "*.gz" -type f -printf "%T@ %p\n" | sort -nr | head -5 | while read timestamp filepath; do
        local date_str=$(date -d "@$timestamp" '+%Y-%m-%d %H:%M')
        local size=$(du -h "$filepath" | cut -f1)
        echo "  $date_str - $(basename "$filepath") ($size)" >> "$report_file"
    done
    
    echo -e "${GREEN}📋 Relatório salvo em: $report_file${NC}"
    log_message "INFO" "Backup report generated: $report_file"
}

# Função para verificar integridade dos backups
verify_backup_integrity() {
    echo -e "${BLUE}🔍 Verificando integridade dos backups...${NC}"
    
    local corrupt_files=0
    
    # Verificar arquivos comprimidos
    find "${BACKUP_DIR}" -name "*.gz" -type f | while read file; do
        if ! gzip -t "$file" 2>/dev/null; then
            echo -e "${RED}❌ Arquivo corrompido: $(basename "$file")${NC}"
            log_message "ERROR" "Corrupt backup file: $file"
            ((corrupt_files++))
        fi
    done
    
    if [ $corrupt_files -eq 0 ]; then
        echo -e "${GREEN}✅ Todos os backups estão íntegros${NC}"
        log_message "INFO" "All backup files verified successfully"
    else
        echo -e "${RED}❌ $corrupt_files arquivo(s) corrompido(s) encontrado(s)${NC}"
        log_message "WARN" "$corrupt_files corrupt backup files found"
    fi
}

# Função para configurar cron job
setup_cron_job() {
    local cron_schedule="0 2 * * *"  # Todo dia às 2h da manhã
    local script_path="$(realpath "${BASH_SOURCE[0]}")"
    
    echo -e "${BLUE}⏰ Configurando backup automático...${NC}"
    
    # Verificar se já existe
    if crontab -l 2>/dev/null | grep -q "$script_path"; then
        echo -e "${YELLOW}⚠️  Cron job já existe${NC}"
        return 0
    fi
    
    # Adicionar ao crontab
    (crontab -l 2>/dev/null; echo "$cron_schedule $script_path --cron") | crontab -
    
    echo -e "${GREEN}✅ Backup automático configurado (diário às 2h)${NC}"
    log_message "INFO" "Cron job configured: $cron_schedule"
}

# Função para mostrar ajuda
show_help() {
    echo "Script de Backup Automatizado"
    echo "============================="
    echo ""
    echo "Uso: $0 [opções]"
    echo ""
    echo "Opções:"
    echo "  --help, -h         Mostra esta ajuda"
    echo "  --mysql           Backup apenas MySQL"
    echo "  --postgres        Backup apenas PostgreSQL"
    echo "  --sqlserver       Backup apenas SQL Server"
    echo "  --all             Backup de todos os bancos (padrão)"
    echo "  --cleanup         Limpa backups antigos"
    echo "  --verify          Verifica integridade dos backups"
    echo "  --report          Gera relatório de backups"
    echo "  --setup-cron      Configura backup automático"
    echo "  --cron            Execução via cron (silenciosa)"
    echo ""
    echo "Exemplos:"
    echo "  $0 --all          # Backup completo"
    echo "  $0 --mysql        # Apenas MySQL"
    echo "  $0 --cleanup      # Limpar backups antigos"
}

# Função principal
main() {
    local backup_mysql_flag=false
    local backup_postgres_flag=false
    local backup_sqlserver_flag=false
    local cleanup_flag=false
    local verify_flag=false
    local report_flag=false
    local setup_cron_flag=false
    local cron_mode=false
    local all_flag=true
    
    # Parse argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --mysql)
                backup_mysql_flag=true
                all_flag=false
                ;;
            --postgres)
                backup_postgres_flag=true
                all_flag=false
                ;;
            --sqlserver)
                backup_sqlserver_flag=true
                all_flag=false
                ;;
            --all)
                all_flag=true
                ;;
            --cleanup)
                cleanup_flag=true
                all_flag=false
                ;;
            --verify)
                verify_flag=true
                all_flag=false
                ;;
            --report)
                report_flag=true
                all_flag=false
                ;;
            --setup-cron)
                setup_cron_flag=true
                all_flag=false
                ;;
            --cron)
                cron_mode=true
                ;;
            *)
                echo "Opção desconhecida: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done
    
    # Modo silencioso para cron
    if [ "$cron_mode" = true ]; then
        exec > "${LOG_FILE}.cron" 2>&1
    fi
    
    if [ "$cron_mode" = false ]; then
        echo -e "${GREEN}💾 SISTEMA DE BACKUP AUTOMATIZADO${NC}"
        echo "=================================="
    fi
    
    # Verificar se .env existe
    if [ ! -f ".env" ]; then
        log_message "ERROR" ".env file not found"
        echo -e "${RED}❌ Arquivo .env não encontrado${NC}"
        exit 1
    fi
    
    # Carregar variáveis de ambiente
    export $(grep -v '^#' .env | xargs)
    
    # Configurar estrutura
    setup_backup_structure
    
    # Verificar espaço em disco
    check_disk_space
    
    log_message "INFO" "Backup process started"
    
    # Executar ações baseadas nos flags
    local success_count=0
    local total_count=0
    
    if [ "$setup_cron_flag" = true ]; then
        setup_cron_job
        exit 0
    fi
    
    if [ "$cleanup_flag" = true ]; then
        cleanup_old_backups
        exit 0
    fi
    
    if [ "$verify_flag" = true ]; then
        verify_backup_integrity
        exit 0
    fi
    
    if [ "$report_flag" = true ]; then
        generate_backup_report
        exit 0
    fi
    
    # Executar backups
    if [ "$all_flag" = true ] || [ "$backup_mysql_flag" = true ]; then
        ((total_count++))
        if backup_mysql; then
            ((success_count++))
        fi
    fi
    
    if [ "$all_flag" = true ] || [ "$backup_postgres_flag" = true ]; then
        ((total_count++))
        if backup_postgres; then
            ((success_count++))
        fi
    fi
    
    if [ "$all_flag" = true ] || [ "$backup_sqlserver_flag" = true ]; then
        ((total_count++))
        if backup_sqlserver; then
            ((success_count++))
        fi
    fi
    
    # Limpeza automática após backup completo
    if [ "$all_flag" = true ]; then
        cleanup_old_backups
        verify_backup_integrity
        generate_backup_report
    fi
    
    # Resumo final
    if [ "$cron_mode" = false ]; then
        echo -e "\n${GREEN}📊 Resumo: $success_count/$total_count backups concluídos${NC}"
    fi
    
    log_message "INFO" "Backup process completed: $success_count/$total_count successful"
    
    # Exit code baseado no sucesso
    if [ $success_count -eq $total_count ]; then
        exit 0
    else
        exit 1
    fi
}

# Executar apenas se chamado diretamente
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi