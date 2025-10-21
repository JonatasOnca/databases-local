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
	@echo "⚠️  ATENÇÃO: Mac M1/M2 executará via emulação (mais lento)"
	docker-compose -f $(COMPOSE_FILE) --profile sqlserver up -d

# Inicia apenas bancos nativos (MySQL + PostgreSQL) - Recomendado para Mac M1/M2
up-native:
	@echo "Iniciando bancos nativos (MySQL + PostgreSQL)..."
	docker-compose -f $(COMPOSE_FILE) --profile mysql --profile postgres up -d

# Verifica a arquitetura do sistema
check-arch:
	@echo "Verificando arquitetura do sistema..."
	@echo "Arquitetura: $$(uname -m)"
	@echo "Sistema: $$(uname -s)"
	@if [ "$$(uname -m)" = "arm64" ]; then \
		echo "🍎 Mac M1/M2 detectado - SQL Server executará via emulação"; \
		echo "💡 Recomendação: Use 'make up-native' para melhor performance"; \
	else \
		echo "💻 Arquitetura x86_64 - Todas as imagens nativas"; \
	fi

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

# Recarrega dados (limpa e carrega novamente)
reload-sample-data:
	@echo "Limpando e recarregando dados de exemplo..."
	@echo "MySQL - Limpando dados existentes:"
	@docker exec mysql_db mysql -u$$(grep '^DB_USER' .env | cut -d '=' -f2) -p$$(grep '^DB_PASSWORD' .env | cut -d '=' -f2) $$(grep '^DB_NAME' .env | cut -d '=' -f2) -e "DELETE FROM itens_pedido; DELETE FROM pedidos; DELETE FROM produtos; DELETE FROM clientes; DELETE FROM logs;"
	@echo "PostgreSQL - Limpando dados existentes:"
	@docker exec postgres_db psql -U $$(grep '^POSTGRES_USER' .env | cut -d '=' -f2) -d $$(grep '^POSTGRES_DB' .env | cut -d '=' -f2) -c "DELETE FROM itens_pedido; DELETE FROM pedidos; DELETE FROM produtos; DELETE FROM clientes; DELETE FROM logs;"
	@echo "SQL Server - Limpando dados existentes:"
	@docker exec sqlserver_db /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "$$(grep '^SA_PASSWORD' .env | cut -d '=' -f2)" -C -Q "DELETE FROM itens_pedido; DELETE FROM pedidos; DELETE FROM produtos; DELETE FROM clientes; DELETE FROM logs;"
	@echo "Carregando dados novamente..."
	@$(MAKE) load-sample-data

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

# Detecta arquitetura e sugere melhor configuração
detect:
	@echo "Detectando arquitetura e configurações recomendadas..."
	@./scripts/detect-architecture.sh

# Mostra informações dos bancos de dados
info:
	@echo "📊 Informações dos Bancos de Dados"
	@echo "=================================="
	@echo ""
	@echo "🔍 MySQL:"
	@docker exec mysql_db mysql -u$$(grep '^DB_USER' .env | cut -d '=' -f2) -p$$(grep '^DB_PASSWORD' .env | cut -d '=' -f2) $$(grep '^DB_NAME' .env | cut -d '=' -f2) -e "SELECT 'MySQL' as Banco, VERSION() as Versao, DATABASE() as Base_Atual; SELECT TABLE_NAME as Tabelas FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='$$(grep '^DB_NAME' .env | cut -d '=' -f2)';"
	@echo ""
	@echo "🐘 PostgreSQL:"
	@docker exec postgres_db psql -U $$(grep '^POSTGRES_USER' .env | cut -d '=' -f2) -d $$(grep '^POSTGRES_DB' .env | cut -d '=' -f2) -c "SELECT 'PostgreSQL' as banco, version();"
	@docker exec postgres_db psql -U $$(grep '^POSTGRES_USER' .env | cut -d '=' -f2) -d $$(grep '^POSTGRES_DB' .env | cut -d '=' -f2) -c "\\dt"
	@echo ""
	@echo "🏢 SQL Server:"
	@docker exec sqlserver_db /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "$$(grep '^SA_PASSWORD' .env | cut -d '=' -f2)" -C -Q "SELECT 'SQL Server' as Banco, @@VERSION as Versao; SELECT TABLE_NAME as Tabelas FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE';" 2>/dev/null || echo "❌ SQL Server não está disponível"

# Executa testes de conectividade básicos
test-connections:
	@echo "🔌 Testando Conectividade dos Bancos"
	@echo "===================================="
	@echo ""
	@echo "MySQL (porta 3306):"
	@docker exec mysql_db mysql -u$$(grep '^DB_USER' .env | cut -d '=' -f2) -p$$(grep '^DB_PASSWORD' .env | cut -d '=' -f2) -e "SELECT 'MySQL conectado com sucesso!' as status;" 2>/dev/null && echo "✅ MySQL: OK" || echo "❌ MySQL: FALHOU"
	@echo ""
	@echo "PostgreSQL (porta 5432):"
	@docker exec postgres_db psql -U $$(grep '^POSTGRES_USER' .env | cut -d '=' -f2) -d $$(grep '^POSTGRES_DB' .env | cut -d '=' -f2) -c "SELECT 'PostgreSQL conectado com sucesso!' as status;" 2>/dev/null && echo "✅ PostgreSQL: OK" || echo "❌ PostgreSQL: FALHOU"
	@echo ""
	@echo "SQL Server (porta 1433):"
	@docker exec sqlserver_db /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "$$(grep '^SA_PASSWORD' .env | cut -d '=' -f2)" -C -Q "SELECT 'SQL Server conectado com sucesso!' as status;" 2>/dev/null && echo "✅ SQL Server: OK" || echo "❌ SQL Server: FALHOU"

# Executa monitoramento completo do sistema
monitor:
	@echo "Executando monitoramento dos bancos de dados..."
	@./scripts/monitor.sh

# Executa benchmark básico de performance
benchmark:
	@echo "Executando benchmark básico dos bancos de dados..."
	@./scripts/benchmark.sh

# ==============================================================================
# Targets Auxiliares
# ==============================================================================

# Target padrão (roda make)
all: up

# Mostra ajuda com todos os comandos disponíveis
help:
	@echo "🗄️  Database Local Environment - Comandos Disponíveis"
	@echo "======================================================"
	@echo ""
	@echo "📱 Iniciação:"
	@echo "  make up              - Inicia todos os containers"
	@echo "  make up-mysql        - Inicia apenas MySQL"
	@echo "  make up-postgres     - Inicia apenas PostgreSQL"
	@echo "  make up-sqlserver    - Inicia apenas SQL Server"
	@echo "  make up-native       - Inicia bancos nativos (recomendado Mac M1/M2)"
	@echo ""
	@echo "🔧 Controle:"
	@echo "  make down            - Para todos os containers"
	@echo "  make restart         - Reinicia todos os containers"
	@echo "  make clean           - Remove containers e volumes (⚠️  apaga dados)"
	@echo ""
	@echo "📊 Monitoramento:"
	@echo "  make status          - Status dos containers"
	@echo "  make logs            - Logs dos containers"
	@echo "  make monitor         - Monitoramento completo"
	@echo "  make info            - Informações detalhadas dos bancos"
	@echo "  make test-connections - Testa conectividade"
	@echo ""
	@echo "🔌 Conexão:"
	@echo "  make mysql-cli       - Conecta ao MySQL"
	@echo "  make postgres-cli    - Conecta ao PostgreSQL"
	@echo "  make sqlserver-cli   - Conecta ao SQL Server"
	@echo ""
	@echo "📋 Dados:"
	@echo "  make load-sample-data    - Carrega dados de exemplo"
	@echo "  make reload-sample-data  - Recarrega dados (limpa e carrega)"
	@echo "  make backup             - Cria backup dos bancos"
	@echo ""
	@echo "🧪 Testes:"
	@echo "  make validate        - Validação completa do ambiente"
	@echo "  make test-audit      - Testa campos de auditoria"
	@echo "  make benchmark       - Benchmark básico de performance"
	@echo ""
	@echo "🏗️  Sistema:"
	@echo "  make detect          - Detecta arquitetura e recomendações"
	@echo "  make check-arch      - Verificação rápida da arquitetura"
	@echo "  make help            - Mostra esta ajuda"
	@echo ""
	@echo "💡 Exemplos rápidos:"
	@echo "  make detect && make up-native    # Mac M1/M2 otimizado"
	@echo "  make up && make load-sample-data # Ambiente completo com dados"
	@echo "  make monitor                     # Monitoramento em tempo real"

# Remove os arquivos de volumes criados para permitir uma nova inicialização do DB (reset)
# **Não remove os dados persistentes, apenas a configuração de inicialização**
.PHONY: up up-mysql up-postgres up-sqlserver up-native down clean restart logs mysql-cli postgres-cli sqlserver-cli status load-sample-data reload-sample-data backup test-audit validate detect info test-connections monitor benchmark check-arch help all