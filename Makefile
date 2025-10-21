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
	docker-compose -f $(COMPOSE_FILE) up -d

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
	docker exec -it mysql_db mysql -u $(shell grep 'DB_USER' .env | cut -d '=' -f2) -p$(shell grep 'DB_NAME' .env | cut -d '=' -f2)

# Conecta ao shell do container PostgreSQL
postgres-cli:
	@echo "Conectando ao PostgreSQL..."
	docker exec -it postgres_db psql -U $(shell grep 'DB_USER' .env | cut -d '=' -f2) -d $(shell grep 'DB_NAME' .env | cut -d '=' -f2)

# Conecta ao SQL Server usando o cliente sqlcmd dentro do container
sqlserver-cli:
	@echo "Conectando ao SQL Server..."
	# Usa o 'sqlcmd' dentro do container. Requer que o cliente esteja instalado.
	# -S: Server (local) | -U: User (sa) | -P: Password (do .env)
	docker exec -it sqlserver_db /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $(SA_PASSWORD)

# ==============================================================================
# Targets Auxiliares
# ==============================================================================

# Target padrão (roda make)
all: up

# Remove os arquivos de volumes criados para permitir uma nova inicialização do DB (reset)
# **Não remove os dados persistentes, apenas a configuração de inicialização**
.PHONY: up down clean restart logs mysql-cli postgres-cli all