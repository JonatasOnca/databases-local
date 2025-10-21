# 🐍 Guia do Ambiente Virtual Python

Este documento descreve como configurar e usar o ambiente virtual Python para o projeto Database Local Environment.

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Configuração Inicial](#configuração-inicial)
3. [Comandos Disponíveis](#comandos-disponíveis)
4. [Uso Diário](#uso-diário)
5. [Resolução de Problemas](#resolução-de-problemas)
6. [Dependências](#dependências)

## 🎯 Visão Geral

O projeto agora utiliza um ambiente virtual Python (.venv) para isolar as dependências e garantir consistência entre diferentes ambientes de desenvolvimento. Isso oferece os seguintes benefícios:

- ✅ **Isolamento de dependências**: Evita conflitos com outras instalações Python
- ✅ **Versões específicas**: Garante que todos usem as mesmas versões das bibliotecas
- ✅ **Facilidade de deploy**: Reproducibilidade entre ambientes
- ✅ **Limpeza do sistema**: Não "suja" a instalação global do Python

## 🚀 Configuração Inicial

### 1. Configurar Ambiente Virtual

```bash
# Comando principal para setup completo
make setup-python-env
```

Este comando irá:
- Criar o ambiente virtual em `.venv/`
- Instalar todas as dependências do `requirements.txt`
- Criar scripts de ativação
- Configurar o `.gitignore`

### 2. Ativar Ambiente Virtual

```bash
# Opção 1: Script personalizado (recomendado)
source activate-env.sh

# Opção 2: Comando padrão Python
source .venv/bin/activate
```

### 3. Verificar Instalação

```bash
# Verificar saúde do ambiente
make check-python-env
```

## 🛠️ Comandos Disponíveis

### Configuração e Manutenção

| Comando | Descrição |
|---------|-----------|
| `make setup-python-env` | 🐍 Configura ambiente virtual do zero |
| `make check-venv` | 🔍 Verifica se ambiente virtual existe |
| `make install-python-deps` | 📦 Instala/reinstala dependências |
| `make update-python-deps` | 🔄 Atualiza todas as dependências |
| `make list-python-deps` | 📋 Lista dependências instaladas |
| `make check-python-env` | 🧪 Verifica saúde completa do ambiente |
| `make clean-python-env` | 🧹 Remove ambiente virtual |
| `make recreate-python-env` | 🔄 Recria ambiente do zero |

### Execução de Scripts

Todos os comandos Python agora usam automaticamente o ambiente virtual:

| Comando | Descrição |
|---------|-----------|
| `make demo-quick` | ⚡ Demo rápida (15s) |
| `make demo-auto-data` | 🎬 Demo MySQL (30s) |
| `make demo-auto-data-postgres` | 🎬 Demo PostgreSQL (30s) |
| `make demo-auto-data-sqlserver` | 🎬 Demo SQL Server (20s) |
| `make demo-all-databases` | 🎯 Demo completa todos os bancos |
| `make auto-data-mysql` | 🚀 Gerenciador MySQL |
| `make auto-data-postgres` | 🚀 Gerenciador PostgreSQL |
| `make auto-data-sqlserver` | 🚀 Gerenciador SQL Server |
| `make auto-data-all` | 🚀 Todos os gerenciadores |
| `make start-auto-data` | 🚀 Inicialização interativa |

## 📅 Uso Diário

### Cenário 1: Primeira vez no projeto

```bash
# 1. Configurar ambiente
make setup-python-env

# 2. Ativar ambiente
source activate-env.sh

# 3. Testar funcionamento
make demo-quick
```

### Cenário 2: Retornando ao projeto

```bash
# Ativar ambiente virtual
source activate-env.sh

# Executar scripts normalmente
make auto-data-mysql
```

### Cenário 3: Atualizando dependências

```bash
# Atualizar requirements.txt se necessário
# Depois executar:
make update-python-deps
```

### Cenário 4: Problema no ambiente

```bash
# Recriar ambiente do zero
make recreate-python-env
```

## 🔧 Resolução de Problemas

### ❌ Problema: "Comando não encontrado"

```bash
# Verifique se o ambiente virtual está ativo
which python
# Deve mostrar: /caminho/para/projeto/.venv/bin/python

# Se não estiver ativo:
source activate-env.sh
```

### ❌ Problema: "Módulo não encontrado"

```bash
# Verifique dependências instaladas
make list-python-deps

# Reinstale se necessário
make install-python-deps
```

### ❌ Problema: "Ambiente virtual corrompido"

```bash
# Recrie o ambiente
make recreate-python-env
```

### ❌ Problema: "Permission denied"

```bash
# Verifique permissões dos scripts
chmod +x scripts/*.sh
chmod +x activate-env.sh
```

### ❌ Problema: "Python version incompatible"

```bash
# Verifique versão do Python
python3 --version
# Mínimo requerido: Python 3.8+

# Se necessário, instale versão adequada do Python
```

## 📦 Dependências

### Principais

- **pymysql**: Driver MySQL para Python
- **psycopg2-binary**: Driver PostgreSQL para Python  
- **pymssql**: Driver SQL Server para Python

### Opcionais

- **colorama**: Cores no terminal
- **python-dotenv**: Suporte a arquivos .env

### Arquivo requirements.txt

```text
pymysql>=1.1.0
psycopg2-binary>=2.9.7
pymssql>=2.3.8
colorama>=0.4.6
python-dotenv>=1.0.0
```

## 🏗️ Estrutura do Ambiente

```
projeto/
├── .venv/                 # Ambiente virtual (ignorado no git)
├── activate-env.sh        # Script de ativação rápida
├── requirements.txt       # Dependências Python
├── scripts/
│   ├── setup-python-env.sh   # Script de configuração
│   ├── auto-data-manager.py  # Scripts Python principais
│   └── ...
└── Makefile              # Comandos automatizados
```

## 📚 Referências

- [Python Virtual Environments](https://docs.python.org/3/tutorial/venv.html)
- [pip Documentation](https://pip.pypa.io/en/stable/)
- [Requirements Files](https://pip.pypa.io/en/stable/reference/requirements-file-format/)

## 💡 Dicas e Melhores Práticas

1. **Sempre ative o ambiente virtual** antes de trabalhar no projeto
2. **Use `make check-python-env`** regularmente para verificar o estado
3. **Mantenha o `requirements.txt` atualizado** com versões específicas
4. **Não commite a pasta `.venv`** (já está no .gitignore)
5. **Use `make recreate-python-env`** se houver problemas persistentes
6. **Documente novas dependências** ao adicioná-las ao projeto

---

🎉 **Ambiente virtual configurado com sucesso!** Agora você pode executar todos os scripts Python com isolamento e consistência de dependências.