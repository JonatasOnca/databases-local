# 🤖 Sistema de Gerenciamento Automático de Dados

## 📋 Visão Geral

O Sistema de Gerenciamento Automático de Dados é uma solução que executa operações de INSERT e UPDATE nas tabelas do banco de dados a cada 30 segundos de forma automática. Esta funcionalidade é útil para:

- **Testes de Performance**: Simular carga constante no banco
- **Desenvolvimento**: Gerar dados de teste continuamente
- **Monitoramento**: Validar comportamento do banco sob operações constantes
- **Demonstrações**: Mostrar dados sendo atualizados em tempo real

## 🚀 Início Rápido

### 1. Instalação das Dependências

```bash
# Instalar dependências Python
make install-python-deps
```

### 2. Inicialização Interativa (Recomendado)

```bash
# Inicialização com menu interativo
make start-auto-data
```

Este comando oferece um menu para escolher qual(is) banco(s) gerenciar automaticamente.

## 🛠️ Comandos Disponíveis

### Gerenciamento Individual

```bash
# MySQL apenas
make auto-data-mysql

# PostgreSQL apenas  
make auto-data-postgres

# SQL Server apenas
make auto-data-sqlserver
```

### Gerenciamento Múltiplo

```bash
# Todos os bancos simultaneamente (background)
make auto-data-all

# Parar todos os gerenciadores
make stop-auto-data

# Status dos gerenciadores
make status-auto-data

# Logs em tempo real
make logs-auto-data

# Limpar logs
make clean-auto-logs
```

## 📊 Operações Executadas

O sistema executa as seguintes operações automaticamente:

### 🆕 Operações de INSERT

1. **Clientes**: Insere novos clientes com nomes e emails únicos
2. **Produtos**: Adiciona produtos com preços variáveis
3. **Pedidos**: Cria pedidos associados a clientes existentes
4. **Itens do Pedido**: Adiciona itens aos pedidos criados
5. **Logs**: Registra mensagens do sistema

### 🔄 Operações de UPDATE

1. **Clientes**: Atualiza nomes de clientes existentes
2. **Produtos**: Ajusta preços com variações de -10% a +15%
3. **Pedidos**: Modifica datas de pedidos existentes
4. **Logs**: Atualiza mensagens de log existentes

### ⏰ Frequência e Aleatoriedade

- **Intervalo**: 30 segundos entre ciclos
- **Operações por Ciclo**: 2-4 operações aleatórias
- **Dados**: Gerados aleatoriamente a partir de listas predefinidas
- **Segurança**: Respeita integridade referencial e constraints

### Estrutura de Arquivos

```text
scripts/
├── auto-data-manager.py    # Script principal do gerenciamento
└── start-auto-data.sh      # Script de inicialização interativa

logs/
├── auto-mysql.log          # Logs do MySQL
├── auto-postgres.log       # Logs do PostgreSQL  
├── auto-sqlserver.log      # Logs do SQL Server
└── auto-data-manager.log   # Log geral (modo interativo)

requirements.txt            # Dependências Python
```

## 🔧 Configuração

### Configurações de Banco

As configurações de conexão estão definidas no arquivo `auto-data-manager.py`:

```python
class DatabaseConfig:
    MYSQL = {
        'host': 'localhost',
        'port': 3306,
        'user': 'devuser',
        'password': 'devpassword',
        'database': 'testdb'
    }
    
    POSTGRES = {
        'host': 'localhost', 
        'port': 5432,
        'user': 'devuser',
        'password': 'devpassword',
        'database': 'testdb'
    }
    
    SQLSERVER = {
        'server': 'localhost,1433',
        'user': 'SA',
        'password': 'SuperSecureP@ssword!',
        'database': 'testdb'
    }
```

### Dados de Simulação

O sistema usa dados predefinidos para simulação:

- **20 nomes diferentes** para clientes
- **15 produtos variados** com preços base
- **8 mensagens de log diferentes**
- **Variações aleatórias** em preços e quantidades

## 📊 Monitoramento

### Logs em Tempo Real

```bash
# Ver todos os logs simultaneamente
make logs-auto-data

# Logs específicos por arquivo
tail -f logs/auto-mysql.log
tail -f logs/auto-postgres.log  
tail -f logs/auto-sqlserver.log
```

### Status dos Processos

```bash
# Status detalhado
make status-auto-data

# Processos em execução
ps aux | grep auto-data-manager
```

### Exemplo de Log

```text
2025-10-21 15:30:45 - INFO - ✅ Conectado ao MYSQL
2025-10-21 15:30:45 - INFO - 🚀 Iniciando gerenciamento automático de dados (MYSQL)
2025-10-21 15:30:46 - INFO - ➕ Cliente inserido: Ana Costa (ana.costa_1234@email.com)
2025-10-21 15:30:47 - INFO - 🔄 Produto atualizado: ID 3 (preço ajustado em 8.5%)
2025-10-21 15:30:48 - INFO - ➕ Pedido inserido: ID 15, Cliente 2
2025-10-21 15:30:49 - INFO - ✅ Ciclo concluído: 3/3 operações executadas com sucesso
```

## ⚠️ Considerações Importantes

### Segurança

- **Integridade Referencial**: Respeitada em todas as operações
- **Transações**: Uso de commits/rollbacks adequados
- **Validação**: Verificação de registros existentes antes de updates

### Performance

- **Conexão Persistente**: Uma conexão por processo
- **Operações Limitadas**: 2-4 operações por ciclo (30s)
- **Tratamento de Erro**: Recuperação automática de falhas

### Dados

- **Não Destrutivo**: Apenas INSERT e UPDATE, nunca DELETE
- **Dados Simulados**: Dados realistas mas claramente de teste
- **Campos de Auditoria**: `created_at` e `updated_at` gerenciados automaticamente

## 🔄 Fluxo de Operação

1. **Inicialização**
   - Conecta ao banco especificado
   - Verifica tabelas e estrutura
   - Inicia thread de execução

2. **Ciclo de Operações** (a cada 30s)
   - Seleciona 2-4 operações aleatórias
   - Executa operações com dados simulados
   - Registra resultados no log
   - Aguarda próximo ciclo

3. **Tratamento de Erros**
   - Log detalhado de erros
   - Rollback automático em falhas
   - Continuidade da operação

4. **Finalização**
   - Ctrl+C para parar gracefully
   - Fecha conexões adequadamente
   - Salva logs finais

## 🛡️ Solução de Problemas

### Erro de Dependências

```bash
# Reinstalar dependências
make install-python-deps

# Verificar instalação manual
pip install pymysql psycopg2-binary pyodbc
```

### Erro de Conexão

```bash
# Verificar containers rodando
make status

# Testar conectividade
make test-connections

# Verificar logs dos containers
make logs
```

### Processos Travados

```bash
# Parar todos os processos
make stop-auto-data

# Força parada (se necessário)
pkill -f auto-data-manager.py

# Limpar logs e reiniciar
make clean-auto-logs
```

## 💡 Casos de Uso

### Desenvolvimento

```bash
# Ambiente ativo com dados sendo inseridos constantemente
make up
make load-sample-data
make auto-data-all
```

### Testes de Performance

```bash
# Monitorar impacto de operações constantes
make auto-data-mysql &
make realtime-metrics
```

### Demonstrações

```bash
# Mostrar dados sendo atualizados em tempo real
make start-auto-data
# Escolher opção 4 (todos os bancos)
make logs-auto-data
```

### Validação de Sistema

```bash
# Validar comportamento sob carga constante
make auto-data-all
make health-check
make monitor
```

## 📈 Métricas e Estatísticas

O sistema registra:

- **Operações por Minuto**: ~4-8 operações (2-4 a cada 30s)
- **Taxa de Sucesso**: Percentual de operações bem-sucedidas  
- **Tipos de Operação**: Distribuição entre INSERT/UPDATE
- **Tempo de Resposta**: Latência das operações do banco

Combine com outros comandos para análise completa:

```bash
make collect-metrics
make benchmark  
make health-check
```

---

## 🤝 Contribuições

Para melhorias no sistema:

1. Modificar dados de simulação em `auto-data-manager.py`
2. Ajustar frequência alterando o valor de sleep (30s)
3. Adicionar novas operações nas funções específicas
4. Expandir suporte para outros SGBDs
