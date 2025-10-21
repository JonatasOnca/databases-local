# 🗄️ Local Database Environment

Um ambiente de desenvolvimento local com múltiplos sistemas de gerenciamento de banco de dados (MySQL, PostgreSQL e SQL Server) usando Docker Compose.

## 📋 Requisitos

- Docker
- Docker Compose
- Make (opcional, mas recomendado)

### 🏗️ Compatibilidade Multi-Arquitetura

| Sistema | MySQL | PostgreSQL | SQL Server |
|---------|-------|------------|------------|
| Windows (x64) | ✅ Nativo | ✅ Nativo | ✅ Nativo |
| Linux (x64) | ✅ Nativo | ✅ Nativo | ✅ Nativo |
| Mac Intel | ✅ Nativo | ✅ Nativo | ✅ Nativo |
| Mac M1/M2 | ✅ Nativo | ✅ Nativo | ⚠️ Emulação |

**Nota**: SQL Server no Mac M1/M2 executa via emulação x86_64 (performance reduzida)

## 🚀 Início Rápido

1. **Clone o repositório e configure o ambiente:**
   ```bash
   cp .env.example .env
   # Edite o arquivo .env com suas credenciais preferidas
   ```

2. **Inicie todos os bancos de dados:**
   ```bash
   make up
   # ou
   docker-compose up -d
   ```

3. **Conecte-se aos bancos:**
   ```bash
   # MySQL
   make mysql-cli
   
   # PostgreSQL
   make postgres-cli
   
   # SQL Server
   make sqlserver-cli
   ```

4. **Detecte sua arquitetura e obtenha recomendações:**
   ```bash
   make detect
   ```

5. **Valide o ambiente:**
   ```bash
   make validate
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
| `make mysql-cli` | Conecta ao MySQL |
| `make postgres-cli` | Conecta ao PostgreSQL |
| `make sqlserver-cli` | Conecta ao SQL Server |
| `make load-sample-data` | Carrega dados de exemplo |
| `make backup` | Cria backup dos bancos |
| `make test-audit` | Testa campos de auditoria |

## 🔌 Portas e Conexões

| Banco | Porta | Usuário | Senha | Database |
|-------|-------|---------|-------|----------|
| MySQL | 3306 | devuser | devpassword | testdb |
| PostgreSQL | 5432 | devuser | devpassword | testdb |
| SQL Server | 1433 | SA | SuperSecureP@ssword! | master |

## 📊 Estrutura do Banco

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