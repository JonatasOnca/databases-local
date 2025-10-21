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
	docker exec -i sqlserver_db /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "$$(grep '^SA_PASSWORD' .env | cut -d '=' -f2)" -C -d testdb -i /dev/stdin < init/sqlserver/sample_data.sql
	@echo "Dados carregados com sucesso!"

# Recarrega dados (limpa e carrega novamente)
reload-sample-data:
	@echo "Limpando e recarregando dados de exemplo..."
	@echo "MySQL - Limpando dados existentes:"
	@docker exec mysql_db mysql -u$$(grep '^DB_USER' .env | cut -d '=' -f2) -p$$(grep '^DB_PASSWORD' .env | cut -d '=' -f2) $$(grep '^DB_NAME' .env | cut -d '=' -f2) -e "SET FOREIGN_KEY_CHECKS = 0; TRUNCATE TABLE itens_pedido; TRUNCATE TABLE pedidos; TRUNCATE TABLE produtos; TRUNCATE TABLE clientes; TRUNCATE TABLE logs; SET FOREIGN_KEY_CHECKS = 1;"
	@echo "PostgreSQL - Limpando dados existentes:"
	@docker exec postgres_db psql -U $$(grep '^POSTGRES_USER' .env | cut -d '=' -f2) -d $$(grep '^POSTGRES_DB' .env | cut -d '=' -f2) -c "TRUNCATE TABLE itens_pedido, pedidos, produtos, clientes, logs RESTART IDENTITY CASCADE;"
	@echo "SQL Server - Limpando dados existentes:"
	@docker exec sqlserver_db /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "$$(grep '^SA_PASSWORD' .env | cut -d '=' -f2)" -C -d testdb -Q "TRUNCATE TABLE itens_pedido; TRUNCATE TABLE logs; DELETE FROM pedidos; DELETE FROM produtos; DELETE FROM clientes; DBCC CHECKIDENT('pedidos', RESEED, 0); DBCC CHECKIDENT('produtos', RESEED, 0); DBCC CHECKIDENT('clientes', RESEED, 0);"
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

# Executa health check avançado
health-check:
	@echo "Executando health check avançado..."
	@./scripts/health-check.sh

# Executa backup automatizado
backup-auto:
	@echo "Executando backup automatizado..."
	@./scripts/backup-auto.sh --all

# Configura backup automático via cron
setup-backup-cron:
	@echo "Configurando backup automático..."
	@./scripts/backup-auto.sh --setup-cron

# Verifica integridade dos backups
verify-backups:
	@echo "Verificando integridade dos backups..."
	@./scripts/backup-auto.sh --verify

# Gera relatório de backups
backup-report:
	@echo "Gerando relatório de backups..."
	@./scripts/backup-auto.sh --report

# Limpa backups antigos
cleanup-backups:
	@echo "Limpando backups antigos..."
	@./scripts/backup-auto.sh --cleanup

# Setup inteligente do ambiente
smart-setup:
	@echo "Executando setup inteligente..."
	@./scripts/smart-setup.sh

# Setup com auto-start
quick-start:
	@echo "Setup rápido com início automático..."
	@./scripts/smart-setup.sh --auto-start

# Executa suite completa de testes
test-suite:
	@echo "Executando suite de testes automatizados..."
	@./scripts/test-suite.sh

# Coleta métricas de performance e recursos
collect-metrics:
	@echo "Coletando métricas do sistema..."
	@./scripts/metrics-collector.sh --collect

# Monitor de métricas em tempo real
realtime-metrics:
	@echo "Iniciando monitoramento de métricas em tempo real..."
	@./scripts/metrics-collector.sh --realtime

# Gera métricas no formato Prometheus
prometheus-metrics:
	@echo "Gerando métricas para Prometheus..."
	@./scripts/metrics-collector.sh --prometheus

# Migração completa entre bancos
migrate:
	@echo "Sistema de migração de dados..."
	@./scripts/migration-manager.sh help

# Exportar dados de um banco específico
export-data:
	@echo "Exportando dados..."
	@if [ -z "$(DB)" ]; then \
		echo "Uso: make export-data DB=mysql|postgres|sqlserver"; \
		echo "Exemplo: make export-data DB=mysql"; \
	else \
		./scripts/migration-manager.sh export-data $(DB); \
	fi

# Validar migração entre bancos
validate-migration:
	@echo "Validando migração..."
	@if [ -z "$(SOURCE)" ] || [ -z "$(TARGET)" ]; then \
		echo "Uso: make validate-migration SOURCE=mysql TARGET=postgres"; \
		echo "Bancos suportados: mysql, postgres, sqlserver"; \
	else \
		./scripts/migration-manager.sh validate $(SOURCE) $(TARGET); \
	fi

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
	@echo "🧪 Testes e Qualidade:"
	@echo "  make test-suite      - Suite completa de testes automatizados"
	@echo "  make validate        - Validação completa do ambiente"
	@echo "  make test-audit      - Testa campos de auditoria"
	@echo "  make benchmark       - Benchmark básico de performance"
	@echo "  make health-check    - Health check avançado"
	@echo ""
	@echo "💾 Backup:"
	@echo "  make backup-auto     - Backup automatizado completo"
	@echo "  make setup-backup-cron - Configura backup automático"
	@echo "  make verify-backups  - Verifica integridade dos backups"
	@echo "  make backup-report   - Relatório de backups"
	@echo "  make cleanup-backups - Limpa backups antigos"
	@echo ""
	@echo "📊 Métricas e Monitoramento:"
	@echo "  make collect-metrics - Coleta métricas do sistema"
	@echo "  make realtime-metrics - Monitor de métricas em tempo real"
	@echo "  make prometheus-metrics - Gera métricas para Prometheus"
	@echo "  make monitor         - Monitoramento completo"
	@echo ""
	@echo "🔄 Migração de Dados:"
	@echo "  make migrate         - Sistema de migração entre bancos"
	@echo "  make export-data DB=mysql - Exporta dados (mysql|postgres|sqlserver)"
	@echo "  make validate-migration SOURCE=mysql TARGET=postgres - Valida migração"
	@echo ""
	@echo "🏗️  Sistema:"
	@echo "  make detect          - Detecta arquitetura e recomendações"
	@echo "  make check-arch      - Verificação rápida da arquitetura"
	@echo "  make smart-setup     - Setup inteligente do ambiente"
	@echo "  make quick-start     - Setup rápido com início automático"
	@echo "  make help            - Mostra esta ajuda"
	@echo ""
	@echo "💡 Exemplos rápidos:"
	@echo "  make detect && make up-native    # Mac M1/M2 otimizado"
	@echo "  make up && make load-sample-data # Ambiente completo com dados"
	@echo "  make test-suite                  # Executar todos os testes"
	@echo "  make realtime-metrics            # Monitoramento em tempo real"
	@echo "  make migrate                     # Ver opções de migração"

# Remove os arquivos de volumes criados para permitir uma nova inicialização do DB (reset)
# **Não remove os dados persistentes, apenas a configuração de inicialização**
.PHONY: up up-mysql up-postgres up-sqlserver up-native down clean restart logs mysql-cli postgres-cli sqlserver-cli status load-sample-data reload-sample-data backup test-audit validate detect info test-connections monitor benchmark check-arch help all health-check backup-auto setup-backup-cron verify-backups backup-report cleanup-backups smart-setup quick-start test-suite collect-metrics realtime-metrics prometheus-metrics migrate export-data validate-migration