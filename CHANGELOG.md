# Changelog

Todas as mudanças notáveis do projeto serão documentadas neste arquivo.

## [3.0.0] - 2024-12-28

### 🚀 Novos Recursos Major
- **Sistema de Monitoramento Completo**: `make monitor`
  - Monitoramento em tempo real com atualização a cada 5s
  - Status de containers, uso de recursos, conectividade
  - Logs recentes integrados em tempo real
  - Interface colorizada e organizada
- **Benchmark de Performance**: `make benchmark`
  - Comparação automática entre MySQL, PostgreSQL e SQL Server
  - Testes com SELECT simples e JOIN complexo
  - Medição precisa de tempos de resposta
  - Resultados coloridos e organizados
- **Sistema de Ajuda Avançado**: `make help`
  - Comandos categorizados por funcionalidade
  - 20+ comandos organizados em 5 categorias
  - Descrições detalhadas de cada comando
- **Validação Completa do Ambiente**: `make validate`
  - Verificação de containers, conectividade e dados
  - Relatório detalhado do estado do ambiente
  - Detecção automática de problemas

### 🔧 Melhorias Técnicas
- **Scripts Shell Avançados**:
  - `scripts/monitor.sh`: Sistema de monitoramento completo
  - `scripts/benchmark.sh`: Framework de benchmark de performance
  - `scripts/validate.sh`: Validação abrangente do ambiente
- **Makefile Expandido**: 
  - 20+ comandos organizados por categoria
  - Sistema de ajuda interativo
  - Comandos para teste, monitoramento e benchmark
- **Correções de Conectividade**:
  - Resolvidos problemas de variáveis de ambiente no .env
  - Comandos SQL otimizados e com escape adequado
  - Melhor tratamento de erros e timeouts

### 📊 Resultados de Performance
- **Benchmark inicial** (ambiente local):
  - MySQL: ~0.08s (SELECT), ~0.07s (JOIN)
  - PostgreSQL: ~0.09s (SELECT), ~0.08s (JOIN)
  - SQL Server: ~0.21s (SELECT), ~0.20s (JOIN)

### 🐛 Correções Importantes
- Corrigida expansão de variáveis no arquivo .env
- Resolvidos erros de sintaxe SQL em comandos de informação
- Melhorada compatibilidade com diferentes shells (zsh/bash)
- Corrigidos problemas de permissão em scripts

## [2.1.0] - 2024-10-21

### 🌍 Suporte Multi-Arquitetura
- **Compatibilidade universal**: Windows, Linux, Mac Intel e Mac M1/M2
- **Detecção automática**: Script para identificar arquitetura e sugerir configuração
- **Otimizações específicas**: Recomendações baseadas na plataforma
- **Comando up-native**: Apenas bancos nativos para Mac M1/M2
- **Documentação detalhada**: Tabela de compatibilidade por sistema

### 🔧 Melhorias
- **Script detect-architecture.sh**: Análise automática do sistema
- **Comando make detect**: Detecção de arquitetura via Makefile
- **Configurações de plataforma**: Comentários explicativos no docker-compose
- **Documentação expandida**: Seção de otimizações por arquitetura

### 📊 Validações
- **Verificação de recursos**: Análise de memória disponível
- **Docker health check**: Validação de Docker e Docker Compose
- **Recomendações inteligentes**: Sugestões baseadas em recursos

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