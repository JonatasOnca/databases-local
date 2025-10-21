# 🗄️ Local Database Environment

Um ambiente de desenvolvimento local com múltiplos sistemas de gerenciamento de banco de dados (MySQL, PostgreSQL e SQL Server) usando Docker Compose. Agora com **setup inteligente**, **health check avançado** e **backup automatizado**.

## 🚀 Início Rápido

### Setup Automático (Recomendado)
```bash
# Setup inteligente com detecção automática
make smart-setup

# Ou setup rápido com início automático
make quick-start
```

### Setup Manual
```bash
# 1. Configure o ambiente
cp .env.example .env
# Edite o arquivo .env se necessário

# 2. Inicie os bancos (comando sugerido baseado na sua arquitetura)
make detect    # Veja as recomendações
make up-native # Para Mac M1/M2 ou make up para outras arquiteturas

# 3. Carregue dados de exemplo
make load-sample-data

# 4. Valide o ambiente
make health-check
```

## 📋 Profiles (Execução Seletiva)

Você pode executar apenas os bancos que precisar:

```bash
# Apenas MySQL
make up-mysql

# Apenas PostgreSQL  
make up-postgres

# Apenas SQL Server (⚠️ emulação no Mac M1/M2)
make up-sqlserver

# Bancos nativos - Recomendado para Mac M1/M2
make up-native

# Todos os bancos (padrão)
make up
```

### 🚀 Otimizações por Arquitetura

**Mac M1/M2 (ARM64):**
- ✅ `make up-native` - Apenas bancos nativos (melhor performance)
- ⚠️ `make up` - Inclui SQL Server via emulação (mais lento)

**Windows/Linux/Mac Intel:**
- ✅ `make up` - Todos os bancos nativos (performance total)

## 🛠️ Comandos Disponíveis

| Comando | Descrição |
|---------|-----------|
| `make up` | Inicia todos os containers |
| `make up-mysql` | Inicia apenas o MySQL |
| `make up-postgres` | Inicia apenas o PostgreSQL |
| `make up-sqlserver` | Inicia apenas o SQL Server |
| `make up-native` | Inicia bancos nativos (MySQL + PostgreSQL) |
| `make down` | Para todos os containers |
| `make restart` | Reinicia todos os containers |
| `make clean` | Remove containers e volumes (⚠️ apaga dados) |
| `make logs` | Exibe logs dos containers |
| `make status` | Mostra status dos containers |
| `make detect` | Detecta arquitetura e mostra recomendações |
| `make validate` | Valida se o ambiente está funcionando |
| `make monitor` | Monitoramento completo em tempo real |
| `make info` | Informações detalhadas dos bancos |
| `make test-connections` | Testa conectividade básica |
| `make benchmark` | Benchmark básico de performance |
| `make mysql-cli` | Conecta ao MySQL |
| `make postgres-cli` | Conecta ao PostgreSQL |
| `make sqlserver-cli` | Conecta ao SQL Server |
| `make load-sample-data` | Carrega dados de exemplo |
| `make reload-sample-data` | Recarrega dados (limpa e carrega) |
| `make backup` | Cria backup dos bancos |
| `make test-audit` | Testa campos de auditoria |
| `make help` | Mostra todos os comandos disponíveis |

## 🔌 Portas e Conexões

| Banco | Porta | Usuário | Senha | Database |
|-------|-------|---------|-------|----------|
| MySQL | 3306 | devuser | devpassword | testdb |
| PostgreSQL | 5432 | devuser | devpassword | testdb |
| SQL Server | 1433 | SA | SuperSecureP@ssword! | master |

## 📊 Monitoramento e Performance

### Monitoramento Completo
```bash
make monitor  # Monitoramento em tempo real
```

Exibe:
- Status dos containers
- Uso de recursos (CPU, memória)
- Conectividade dos bancos
- Logs recentes
- Atualização automática a cada 5 segundos

### Benchmark de Performance
```bash
make benchmark  # Teste básico de performance
```

Compara tempos de resposta entre os três bancos com:
- SELECT simples (COUNT)
- JOIN com GROUP BY

### Validação do Ambiente
```bash
make validate  # Valida configuração completa
```

Verifica:
- Containers rodando
- Conectividade
- Dados de exemplo
- Configurações

### Health Check Avançado
```bash
make health-check  # Verificação completa de saúde
```

Monitora:
- Status e métricas dos containers (CPU, memória)
- Tempo de resposta dos bancos
- Verificação de portas e rede
- Alertas automáticos para problemas
- Log detalhado de eventos

### Backup Automatizado
```bash
make backup-auto     # Backup completo de todos os bancos
make setup-backup-cron  # Configura backup automático diário
make verify-backups  # Verifica integridade dos backups
make backup-report   # Relatório detalhado de backups
```

Recursos:
- Backup comprimido com rotação automática
- Suporte a MySQL, PostgreSQL e SQL Server
- Verificação de integridade automática
- Agendamento via cron
- Relatórios detalhados

## 🗂️ Estrutura de Arquivos

Todos os bancos são inicializados com o mesmo esquema, incluindo campos de auditoria:

- **clientes** - Informações dos clientes
  - `id`, `nome`, `email`, `created_at`, `updated_at`
- **produtos** - Catálogo de produtos
  - `id`, `nome`, `preco`, `created_at`, `updated_at`
- **pedidos** - Registros de pedidos
  - `id`, `cliente_id`, `data_pedido`, `created_at`, `updated_at`
- **itens_pedido** - Itens dos pedidos
  - `pedido_id`, `produto_id`, `quantidade`, `created_at`, `updated_at`
- **logs** - Logs do sistema
  - `id`, `timestamp`, `mensagem`, `created_at`, `updated_at`

### 🕒 Campos de Auditoria

Todas as tabelas incluem campos de auditoria automáticos:
- **`created_at`** - Data/hora de criação do registro
- **`updated_at`** - Data/hora da última atualização (atualizado automaticamente via triggers)

## 🔧 Personalização

### Alterando Credenciais

Edite o arquivo `.env` com suas preferências:

```env
DB_USER=seu_usuario
DB_PASSWORD=sua_senha
DB_NAME=seu_banco
```

### Adicionando Novos Scripts

Adicione scripts SQL em:
- `init/mysql/` - Scripts para MySQL
- `init/postgres/` - Scripts para PostgreSQL
- `init/sqlserver/` - Scripts para SQL Server

### Modificando Configurações

Edite o `docker-compose.yml` para:
- Alterar versões das imagens
- Adicionar novos bancos
- Configurar recursos (CPU, memória)

## 🐛 Solução de Problemas

### SQL Server não inicia
- Verifique se a senha atende aos requisitos de complexidade
- Certifique-se de que a EULA foi aceita (`ACCEPT_EULA=Y`)

### Erro de conexão
```bash
# Verifique se os containers estão rodando
docker ps

# Veja os logs para diagnóstico
make logs
```

### Resetar dados
```bash
# ⚠️ CUIDADO: Isso apaga todos os dados
make clean
make up
```

## 📝 Notas

- Os dados são persistidos em volumes Docker
- Scripts de inicialização são executados apenas na primeira vez
- Para reinicializar os bancos, use `make clean && make up`

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT.