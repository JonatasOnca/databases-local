# API Reference - Database Local Environment

Este documento descreve as APIs e endpoints disponíveis no ambiente de bancos de dados locais.

## 📋 Resumo de Serviços

| Serviço | Porta | URL | Credenciais |
|---------|-------|-----|-------------|
| MySQL | 3306 | - | devuser / devpassword |
| PostgreSQL | 5432 | - | devuser / devpassword |
| SQL Server | 1433 | - | SA / SuperSecureP@ssword! |
| Adminer | 8081 | http://localhost:8081 | - |
| phpMyAdmin | 8082 | http://localhost:8082 | devuser / devpassword |
| pgAdmin | 8083 | http://localhost:8083 | admin@database-local.com / admin123 |
| Code Server | 8080 | http://localhost:8080 | - |
| Jupyter | 8888 | http://localhost:8888 | - |
| Prometheus | 9090 | http://localhost:9090 | - |
| Grafana | 3000 | http://localhost:3000 | admin / admin123 |

## 🗄️ Estrutura do Banco de Dados

Todos os bancos implementam o mesmo esquema com as seguintes tabelas:

### Tabela: `clientes`
```sql
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Tabela: `produtos`
```sql
CREATE TABLE produtos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Tabela: `pedidos`
```sql
CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    data_pedido DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);
```

### Tabela: `itens_pedido`
```sql
CREATE TABLE itens_pedido (
    pedido_id INT,
    produto_id INT,
    quantidade INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (pedido_id, produto_id),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
);
```

### Tabela: `logs`
```sql
CREATE TABLE logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    mensagem VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## 🔌 Conexões de Banco

### MySQL
```bash
# Via container
docker exec -it mysql_db mysql -udevuser -pdevpassword123 testdb

# Via cliente externo
mysql -h localhost -P 3306 -u devuser -p testdb
```

### PostgreSQL
```bash
# Via container
docker exec -it postgres_db psql -U devuser -d testdb

# Via cliente externo
psql -h localhost -p 5432 -U devuser -d testdb
```

### SQL Server
```bash
# Via container
docker exec -it sqlserver_db /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P 'SuperSecureP@ssword!' -C

# Via cliente externo
sqlcmd -S localhost,1433 -U SA -P 'SuperSecureP@ssword!' -C
```

## 📊 Métricas e Monitoramento

### Endpoint de Métricas
```bash
# Coletar métricas em JSON
curl -s http://localhost:9090/api/v1/query?query=up | jq .

# Métricas Prometheus
make prometheus-metrics
cat metrics/prometheus/metrics.txt
```

### Alertas Disponíveis
- **CPU Alto**: >80% de uso por mais de 5 minutos
- **Memória Alta**: >80% de uso por mais de 5 minutos  
- **Disco Cheio**: >90% de uso
- **Conexões Lentas**: Tempo de resposta >1 segundo
- **Container Parado**: Qualquer container principal inativo

## 🧪 API de Testes

### Executar Suite de Testes
```bash
# Todos os testes
make test-suite

# Testes específicos
./scripts/test-suite.sh

# Validação de migração
make validate-migration SOURCE=mysql TARGET=postgres
```

### Formatos de Resposta
```json
{
  "test_name": "MySQL conectividade",
  "status": "PASSED|FAILED",
  "duration": "0.123s",
  "timestamp": "2024-01-01T12:00:00Z",
  "details": "Detalhes do teste"
}
```

## 🔄 API de Migração

### Exportar Dados
```bash
# Exportar esquema
make export-data DB=mysql

# Exportar dados específicos
./scripts/migration-manager.sh export-data mysql "clientes,produtos"
```

### Migração Completa
```bash
# Migração entre bancos
./scripts/migration-manager.sh migrate mysql postgres

# Apenas esquema
./scripts/migration-manager.sh migrate-schema mysql postgres

# Apenas dados
./scripts/migration-manager.sh migrate-data mysql postgres
```

### Status de Migração
```json
{
  "migration_id": "20241001_120000_mysql_to_postgres",
  "status": "completed|failed|in_progress",
  "source": "mysql",
  "target": "postgres",
  "started_at": "2024-01-01T12:00:00Z",
  "completed_at": "2024-01-01T12:05:00Z",
  "records_migrated": 1250,
  "tables": ["clientes", "produtos", "pedidos", "itens_pedido", "logs"]
}
```

## 🔒 Segurança

### Configurações de Segurança
- Senhas complexas obrigatórias
- Conexões SSL/TLS habilitadas (produção)
- Auditoria de comandos SQL
- Rate limiting configurável
- Backup criptografado

### Headers de Segurança
```http
X-Database-Environment: development
X-Rate-Limit-Remaining: 950
X-Rate-Limit-Reset: 3600
```

## 📈 Health Check API

### Endpoint Principal
```bash
GET /health
```

### Resposta
```json
{
  "status": "healthy|degraded|unhealthy",
  "timestamp": "2024-01-01T12:00:00Z",
  "services": {
    "mysql": {
      "status": "healthy",
      "response_time": "0.023s",
      "connections": 5,
      "cpu_percent": 15.2,
      "memory_percent": 45.8
    },
    "postgres": {
      "status": "healthy", 
      "response_time": "0.019s",
      "connections": 3,
      "cpu_percent": 12.1,
      "memory_percent": 38.4
    },
    "sqlserver": {
      "status": "healthy",
      "response_time": "0.156s", 
      "connections": 2,
      "cpu_percent": 25.7,
      "memory_percent": 62.1
    }
  },
  "system": {
    "disk_usage_percent": 45,
    "memory_total_mb": 16384,
    "memory_used_mb": 8192,
    "docker_containers": 6
  }
}
```

## 🛠️ Scripts Utilitários

### Scripts Disponíveis
| Script | Função | Uso |
|--------|--------|-----|
| `smart-setup.sh` | Setup inteligente | `make smart-setup` |
| `health-check.sh` | Verificação de saúde | `make health-check` |
| `backup-auto.sh` | Backup automatizado | `make backup-auto` |
| `test-suite.sh` | Suite de testes | `make test-suite` |
| `metrics-collector.sh` | Coleta de métricas | `make collect-metrics` |
| `migration-manager.sh` | Gerenciar migrações | `make migrate` |

### Exemplos de Uso
```bash
# Setup completo automatizado
make quick-start

# Monitoramento em tempo real
make realtime-metrics

# Teste completo do ambiente
make test-suite

# Backup de emergência
make backup-auto

# Migração de dados
make migrate
```

## 🔧 Configuração Avançada

### Variáveis de Ambiente Principais
```bash
# Banco de dados
DB_USER=devuser
DB_PASSWORD=devpassword123
DB_NAME=testdb

# Monitoramento
ALERT_THRESHOLD_CPU=80
ALERT_THRESHOLD_MEMORY=80
ALERT_THRESHOLD_RESPONSE_TIME=1.0

# Backup
BACKUP_RETENTION_DAYS=30
BACKUP_COMPRESSION_LEVEL=6

# Segurança
ENABLE_SSL=false
ENABLE_AUDIT_LOG=true
```

### Profiles Docker Compose
```bash
# Apenas bancos básicos
docker-compose up mysql postgres

# Ambiente completo de desenvolvimento  
docker-compose -f docker-compose.dev.yml --profile all up

# Apenas ferramentas de administração
docker-compose -f docker-compose.dev.yml --profile admin up

# Monitoramento completo
docker-compose -f docker-compose.dev.yml --profile monitoring up
```

## 📞 Suporte e Troubleshooting

### Logs Principais
```bash
# Logs dos containers
make logs

# Logs de health check
tail -f logs/health-check.log

# Logs de métricas
tail -f metrics/metrics.log

# Logs de migração
tail -f migrations/migration.log
```

### Comandos de Diagnóstico
```bash
# Status completo
make status

# Teste de conectividade
make test-connections

# Informações detalhadas
make info

# Validação completa
make validate
```