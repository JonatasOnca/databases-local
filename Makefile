# ==============================================================================
# Variáveis e Configuração
# ==============================================================================

# O nome do arquivo docker-compose a ser usado
COMPOSE_FILE = docker-compose.yml

# ==============================================================================
# Comandos Principais
# ==============================================================================

# Inicia todos os serviços em segundo plano (-d)
up:
	@echo "Iniciando todos os containers (MySQL, PostgreSQL, SQL Server)..."
	docker-compose -f $(COMPOSE_FILE) --profile all up -d

# Inicia apenas o MySQL
up-mysql:
	@echo "Iniciando apenas o MySQL..."
	docker-compose -f $(COMPOSE_FILE) --profile mysql up -d

# Inicia apenas o PostgreSQL
up-postgres:
	@echo "Iniciando apenas o PostgreSQL..."
	docker-compose -f $(COMPOSE_FILE) --profile postgres up -d

# Inicia apenas o SQL Server
up-sqlserver:
	@echo "Iniciando apenas o SQL Server..."
	docker-compose -f $(COMPOSE_FILE) --profile sqlserver up -d

# Para todos os serviços
down:
	@echo "Parando e removendo containers e redes..."
	docker-compose -f $(COMPOSE_FILE) down

# Para e remove containers, redes E VOLUMES (cuidado: apaga os dados do DB!)
clean:
	@echo "Parando, removendo containers, redes e volumes (DELETANDO DADOS PERMANENTEMENTE!)..."
	docker-compose -f $(COMPOSE_FILE) down -v

# Reinicia todos os containers
restart: down up

# Exibe os logs de todos os serviços (ou de um serviço específico)
logs:
	@echo "Exibindo logs dos containers (Ctrl+C para sair)..."
	docker-compose -f $(COMPOSE_FILE) logs -f

# Conecta ao shell do container MySQL
mysql-cli:
	@echo "Conectando ao MySQL..."
	docker exec -it mysql_db mysql -u$$(grep '^DB_USER' .env | cut -d '=' -f2) -p$$(grep '^DB_PASSWORD' .env | cut -d '=' -f2) $$(grep '^DB_NAME' .env | cut -d '=' -f2)

# Conecta ao shell do container PostgreSQL
postgres-cli:
	@echo "Conectando ao PostgreSQL..."
	docker exec -it postgres_db psql -U $$(grep '^POSTGRES_USER' .env | cut -d '=' -f2) -d $$(grep '^POSTGRES_DB' .env | cut -d '=' -f2)

# Conecta ao SQL Server usando o cliente sqlcmd dentro do container
sqlserver-cli:
	@echo "Conectando ao SQL Server..."
	docker exec -it sqlserver_db /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "$$(grep '^SA_PASSWORD' .env | cut -d '=' -f2)" -C

# Verifica o status dos containers
status:
	@echo "Status dos containers:"
	@docker-compose -f $(COMPOSE_FILE) ps

# Carrega dados de exemplo em todos os bancos
load-sample-data:
	@echo "Carregando dados de exemplo..."
	@echo "MySQL:"
	docker exec -i mysql_db mysql -u$$(grep '^DB_USER' .env | cut -d '=' -f2) -p$$(grep '^DB_PASSWORD' .env | cut -d '=' -f2) $$(grep '^DB_NAME' .env | cut -d '=' -f2) < init/mysql/sample_data.sql
	@echo "PostgreSQL:"
	docker exec -i postgres_db psql -U $$(grep '^POSTGRES_USER' .env | cut -d '=' -f2) -d $$(grep '^POSTGRES_DB' .env | cut -d '=' -f2) < init/postgres/sample_data.sql
	@echo "SQL Server:"
	docker exec -i sqlserver_db /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "$$(grep '^SA_PASSWORD' .env | cut -d '=' -f2)" -C -i /dev/stdin < init/sqlserver/sample_data.sql
	@echo "Dados carregados com sucesso!"

# Backup de todos os bancos
backup:
	@echo "Criando backup dos bancos..."
	@mkdir -p backups
	@echo "Backup MySQL..."
	docker exec mysql_db mysqldump -u$$(grep '^DB_USER' .env | cut -d '=' -f2) -p$$(grep '^DB_PASSWORD' .env | cut -d '=' -f2) $$(grep '^DB_NAME' .env | cut -d '=' -f2) > backups/mysql_backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "Backup PostgreSQL..."
	docker exec postgres_db pg_dump -U $$(grep '^POSTGRES_USER' .env | cut -d '=' -f2) $$(grep '^POSTGRES_DB' .env | cut -d '=' -f2) > backups/postgres_backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "Backups criados na pasta backups/"

# Testa a funcionalidade dos campos de auditoria
test-audit:
	@echo "Testando campos de auditoria..."
	@echo "MySQL - Atualizando cliente 1:"
	@docker exec mysql_db mysql -u$$(grep '^DB_USER' .env | cut -d '=' -f2) -p$$(grep '^DB_PASSWORD' .env | cut -d '=' -f2) $$(grep '^DB_NAME' .env | cut -d '=' -f2) -e "UPDATE clientes SET nome='João Silva Santos' WHERE id=1; SELECT id, nome, created_at, updated_at FROM clientes WHERE id=1;"
	@echo "PostgreSQL - Atualizando produto 1:"
	@docker exec postgres_db psql -U $$(grep '^POSTGRES_USER' .env | cut -d '=' -f2) -d $$(grep '^POSTGRES_DB' .env | cut -d '=' -f2) -c "UPDATE produtos SET preco=2600.00 WHERE id=1; SELECT id, nome, created_at, updated_at FROM produtos WHERE id=1;"

# Valida se o ambiente está funcionando corretamente
validate:
	@echo "Executando validação completa do ambiente..."
	@source .env && ./scripts/validate.sh

# ==============================================================================
# Targets Auxiliares
# ==============================================================================

# Target padrão (roda make)
all: up

# Remove os arquivos de volumes criados para permitir uma nova inicialização do DB (reset)
# **Não remove os dados persistentes, apenas a configuração de inicialização**
.PHONY: up up-mysql up-postgres up-sqlserver down clean restart logs mysql-cli postgres-cli sqlserver-cli status load-sample-data backup test-audit validate all