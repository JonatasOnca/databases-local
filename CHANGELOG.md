# Changelog

Todas as mudanças notáveis do projeto serão documentadas neste arquivo.

## [2.0.0] - 2024-10-21

### 🚀 Adicionado
- **Profiles do Docker Compose**: Execução seletiva de bancos específicos
  - `make up-mysql` - Apenas MySQL
  - `make up-postgres` - Apenas PostgreSQL  
  - `make up-sqlserver` - Apenas SQL Server
- **Script de validação**: `make validate` para verificar integridade do ambiente
- **Campos de auditoria**: `created_at` e `updated_at` em todas as tabelas
- **Triggers automáticos**: Atualização automática de `updated_at`
- **Arquivo docker-compose.override.yml**: Configurações de desenvolvimento
- **Configurações de recursos**: Limites de memória para containers
- **Suporte a timezone**: Configuração América/São Paulo
- **Comando test-audit**: Teste dos campos de auditoria

### 🔧 Corrigido
- **Docker Compose version warning**: Removido atributo obsoleto
- **SQL Server Tools**: Atualizado para mssql-tools18
- **Problema de arquitetura**: Adicionado `platform: linux/amd64` para SQL Server
- **Healthchecks**: Melhorados intervalos e timeouts
- **Scripts de inicialização**: SQL Server agora executa scripts corretamente
- **Segurança**: `.env` adicionado ao `.gitignore`

### 📚 Documentação
- **README atualizado**: Documentação completa com novos comandos
- **Estrutura do banco**: Detalhamento dos campos de auditoria
- **Guia de profiles**: Como usar execução seletiva
- **Troubleshooting**: Seção expandida de solução de problemas

### 🗄️ Infraestrutura
- **Scripts específicos por SGBD**: Dados de exemplo individualizados
- **Estrutura organizada**: Pasta `scripts/` para utilitários
- **Arquivos de configuração**: `.env.development` e `.env.monitoring`

## [1.0.0] - 2024-10-20

### 🚀 Inicial
- **Docker Compose**: Configuração para MySQL, PostgreSQL e SQL Server
- **Scripts de inicialização**: Criação automática de tabelas
- **Makefile**: Comandos básicos de gerenciamento
- **Volumes persistentes**: Dados mantidos entre reinicializações
- **Health checks**: Monitoramento básico de containers