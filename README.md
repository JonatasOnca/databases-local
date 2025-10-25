# 🗄️ Local Database Environment

Um ambiente de desenvolvimento local com múltiplos sistemas de gerenciamento de banco de dados (MySQL, PostgreSQL e SQL Server) usando Docker Compose. Agora com **setup inteligente**, **health check avançado**, **backup automatizado**, **testes automatizados**, **sistema de métricas** e **gerenciamento automático de dados**.

## ✨ Principais Funcionalidades

- 🚀 **Setup inteligente** com detecção automática de arquitetura
- 🤖 **Sistema automático de carga de dados** (INSERT/UPDATE a cada 30 segundos)
- 📊 **Monitoramento em tempo real** com métricas detalhadas  
- 🔄 **Backup automatizado** com verificação de integridade
- 🧪 **Suite de testes automatizados** para validação completa
- 🔧 **Migração de dados** entre diferentes bancos
- 🐍 **Ambiente Python integrado** com dependências gerenciadas

## 🚀 Início Rápido

### Setup Automático (Recomendado)
```bash
# Setup inteligente com detecção automática
make smart-setup

# Ou setup rápido com início automático
make quick-start
```

### 🐍 Configuração do Ambiente Python
```bash
# 1. Configure o ambiente virtual Python (recomendado)
make setup-python-env

# 2. Ative o ambiente virtual
source activate-env.sh
# ou
source .venv/bin/activate

# 3. Instale/atualize dependências
make install-python-deps
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
| `make test-suite` | Suite completa de testes automatizados |
| `make collect-metrics` | Coleta métricas de performance e recursos |
| `make realtime-metrics` | Monitor de métricas em tempo real |
| `make migrate` | Sistema de migração entre bancos |
| `make export-data DB=mysql` | Exporta dados de banco específico |
| `make validate-migration SOURCE=mysql TARGET=postgres` | Valida migração entre bancos |

### 🐍 Comandos do Ambiente Python

| Comando | Descrição |
|---------|-----------|
| `make setup-python-env` | Configura ambiente virtual Python |
| `make install-python-deps` | Instala dependências Python |
| `make update-python-deps` | Atualiza dependências Python |
| `make check-python-env` | Verifica saúde do ambiente Python |
| `make list-python-deps` | Lista dependências instaladas |
| `make clean-python-env` | Remove ambiente virtual |
| `make recreate-python-env` | Recria ambiente virtual do zero |

### 🤖 Gerenciamento Automático de Dados

Sistema que executa operações INSERT e UPDATE automaticamente a cada **30 segundos** nos bancos de dados.

| Comando | Descrição |
|---------|-----------|
| `make start-auto-data` | **🚀 Inicialização interativa (RECOMENDADO)** |
| `make auto-data-mysql` | Gerenciador automático para MySQL |
| `make auto-data-postgres` | Gerenciador automático para PostgreSQL |
| `make auto-data-sqlserver` | Gerenciador automático para SQL Server |
| `make auto-data-all` | Gerenciador automático para TODOS os bancos em paralelo |
| `make stop-auto-data` | Para todos os gerenciadores |
| `make status-auto-data` | Status dos gerenciadores |
| `make logs-auto-data` | Logs em tempo real |
| `make clean-auto-logs` | Limpa logs dos gerenciadores |

### 🎬 Demonstrações do Sistema Automático

| Comando | Descrição |
|---------|-----------|
| `make demo-quick` | ⚡ Demonstração rápida MySQL (15s) |
| `make demo-auto-data` | 🎬 Demonstração MySQL (30s) |
| `make demo-auto-data-postgres` | 🎬 Demonstração PostgreSQL (30s) |
| `make demo-auto-data-sqlserver` | 🎬 Demonstração SQL Server (20s) |
| `make demo-all-databases` | 🎯 Teste completo de todos os bancos |

## 🤖 Sistema de Gerenciamento Automático de Dados

O projeto inclui um sistema avançado que **automatiza a carga de dados nos bancos a cada 30 segundos**, simulando uma aplicação real em produção.

### 🚀 Como Usar

**Opção 1: Inicialização Interativa (Recomendada)**
```bash
make start-auto-data
```
Abre um menu onde você pode escolher executar para um banco específico ou todos simultaneamente.

**Opção 2: Comandos Diretos**
```bash
# Apenas um banco
make auto-data-mysql      # MySQL
make auto-data-postgres   # PostgreSQL  
make auto-data-sqlserver  # SQL Server

# Todos os bancos em paralelo
make auto-data-all
```

### ⚙️ O que o Sistema Faz

**Operações Regulares (a cada ciclo):**
- ➕ INSERT de novos clientes com emails únicos
- 🔄 UPDATE de clientes existentes
- ➕ INSERT de produtos com preços variáveis
- 🔄 UPDATE de preços de produtos (+/- 15%)
- 📝 INSERT de logs do sistema
- 🔧 Operações ocasionais na tabela `generic`

**Operações Especiais da Tabela Generic (exatamente a cada 30 segundos):**
- 🔧 INSERT/UPDATE específicos com metadata JSON
- ⏰ Timestamps automáticos de sincronização
- 📊 Dados de configuração e cache simulados

### 📊 Dados Gerados

O sistema utiliza dados realistas:

**Clientes:** Ana Costa, Bruno Lima, Carlos Pereira, Diana Silva, etc.
**Produtos:** Smartphone Samsung, iPhone 15, Tablet iPad, Notebook Gamer, etc.
**Tabela Generic:** config, settings, metadata, cache, session, temp

### 🔍 Monitoramento

```bash
# Verificar status dos gerenciadores
make status-auto-data

# Ver logs em tempo real  
make logs-auto-data

# Parar todos os gerenciadores
make stop-auto-data
```

### 📁 Logs Automáticos

Os logs são salvos automaticamente em:
- `logs/auto-mysql.log`
- `logs/auto-postgres.log`
- `logs/auto-sqlserver.log`

### 🎬 Testes e Demonstrações

Antes de usar em produção, teste com as demonstrações:

```bash
# Teste rápido (15 segundos)
make demo-quick

# Teste específico por banco
make demo-auto-data          # MySQL (30s)
make demo-auto-data-postgres # PostgreSQL (30s)  
make demo-auto-data-sqlserver # SQL Server (20s)

# Teste completo de todos os bancos
make demo-all-databases
```

### 💡 Casos de Uso

Este sistema é ideal para:
- 🧪 **Testes de Performance** - Carga contínua de dados
- 📊 **Simulação de Produção** - Ambiente realista de desenvolvimento  
- 🔍 **Testes de Monitoramento** - Validar alertas e dashboards
- 🚀 **Demonstrações** - Mostrar sistemas funcionando com dados dinâmicos
- 📈 **Análise de Crescimento** - Testar como o sistema escala com dados

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
- O sistema automático de dados roda independentemente e pode ser usado para testes de carga
- Logs do sistema automático são mantidos em `logs/auto-*.log`

## ❓ FAQ - Sistema Automático

**P: Como parar o sistema automático se ele estiver rodando em background?**
```bash
make stop-auto-data
```

**P: O sistema automático interfere com minhas operações manuais?**
R: Não, o sistema usa transações pequenas e não bloqueia operações normais.

**P: Posso ajustar o intervalo de 30 segundos?**
R: Sim, edite o arquivo `scripts/auto-data-manager.py` e modifique a variável de tempo.

**P: Como ver apenas os logs de um banco específico?**
```bash
tail -f logs/auto-mysql.log      # MySQL
tail -f logs/auto-postgres.log   # PostgreSQL  
tail -f logs/auto-sqlserver.log  # SQL Server
```

**P: O sistema automático funciona com containers parados?**
R: Não, os containers devem estar rodando. Use `make up` ou `make up-native` primeiro.

**P: Posso usar o sistema em produção?**
R: O sistema é projetado para desenvolvimento e testes. Para produção, ajuste as configurações conforme necessário.

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT.