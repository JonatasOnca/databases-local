#!/bin/bash

# ==============================================================================
# Script de Inicialização do Gerenciamento Automático de Dados
# ==============================================================================

echo "🗄️  Sistema de Gerenciamento Automático de Dados"
echo "================================================="
echo ""

# Verificar se Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 não encontrado!"
    echo "💡 Instale o Python 3 primeiro"
    exit 1
fi

echo "✅ Python 3 encontrado: $(python3 --version)"

# Verificar se ambiente virtual existe
if [ ! -d ".venv" ]; then
    echo "⚠️  Ambiente virtual não encontrado!"
    echo "� Configurando ambiente virtual..."
    make setup-python-env
    if [ $? -ne 0 ]; then
        echo "❌ Falha ao configurar ambiente virtual"
        exit 1
    fi
fi

echo "✅ Ambiente virtual encontrado"

# Ativar ambiente virtual e verificar dependências
source .venv/bin/activate

echo "✅ Ambiente virtual ativado: $(python --version)"

# Verificar se as dependências estão instaladas
echo "🔍 Verificando dependências..."
python -c "import pymysql, psycopg2, pymssql" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "📦 Instalando dependências..."
    make install-python-deps
    if [ $? -ne 0 ]; then
        echo "❌ Falha ao instalar dependências"
        exit 1
    fi
fi

echo "✅ Dependências verificadas"

# Criar diretório de logs se não existir
if [ ! -d "logs" ]; then
    mkdir -p logs
    echo "📁 Diretório logs/ criado"
fi

# Instalar dependências
echo ""
echo "📦 Verificando/Instalando dependências Python..."
if python3 -m pip install -r requirements.txt &> /dev/null; then
    echo "✅ Dependências instaladas com sucesso!"
else
    echo "❌ Erro ao instalar dependências!"
    echo "💡 Execute manualmente: pip install -r requirements.txt"
    exit 1
fi

# Verificar se os containers estão rodando
echo ""
echo "🔍 Verificando status dos containers..."
containers_running=0

if docker ps --format "table {{.Names}}" | grep -q "mysql_db"; then
    echo "✅ MySQL: RODANDO"
    containers_running=$((containers_running + 1))
else
    echo "❌ MySQL: NÃO ESTÁ RODANDO"
fi

if docker ps --format "table {{.Names}}" | grep -q "postgres_db"; then
    echo "✅ PostgreSQL: RODANDO"
    containers_running=$((containers_running + 1))
else
    echo "❌ PostgreSQL: NÃO ESTÁ RODANDO"
fi

if docker ps --format "table {{.Names}}" | grep -q "sqlserver_db"; then
    echo "✅ SQL Server: RODANDO"
    containers_running=$((containers_running + 1))
else
    echo "❌ SQL Server: NÃO ESTÁ RODANDO"
fi

if [ $containers_running -eq 0 ]; then
    echo ""
    echo "⚠️  Nenhum container de banco está rodando!"
    echo "💡 Execute primeiro: make up (ou make up-native para Mac M1/M2)"
    exit 1
fi

echo ""
echo "🎯 Encontrados $containers_running banco(s) em execução"

# Menu de seleção
echo ""
echo "Selecione uma opção:"
echo "1) Iniciar apenas MySQL"
echo "2) Iniciar apenas PostgreSQL"
echo "3) Iniciar apenas SQL Server"
echo "4) Iniciar TODOS os bancos disponíveis"
echo "5) Sair"
echo ""
read -p "Digite sua escolha (1-5): " choice

case $choice in
    1)
        if docker ps --format "table {{.Names}}" | grep -q "mysql_db"; then
            echo ""
            echo "🚀 Iniciando gerenciador automático para MySQL..."
            echo "⏰ Operações executadas a cada 30 segundos"
            echo "🔄 Pressione Ctrl+C para parar"
            echo ""
            python3 scripts/auto-data-manager.py mysql
        else
            echo "❌ MySQL não está rodando!"
        fi
        ;;
    2)
        if docker ps --format "table {{.Names}}" | grep -q "postgres_db"; then
            echo ""
            echo "🚀 Iniciando gerenciador automático para PostgreSQL..."
            echo "⏰ Operações executadas a cada 30 segundos"
            echo "🔄 Pressione Ctrl+C para parar"
            echo ""
            python3 scripts/auto-data-manager.py postgres
        else
            echo "❌ PostgreSQL não está rodando!"
        fi
        ;;
    3)
        if docker ps --format "table {{.Names}}" | grep -q "sqlserver_db"; then
            echo ""
            echo "🚀 Iniciando gerenciador automático para SQL Server..."
            echo "⏰ Operações executadas a cada 30 segundos"
            echo "🔄 Pressione Ctrl+C para parar"
            echo ""
            python3 scripts/auto-data-manager.py sqlserver
        else
            echo "❌ SQL Server não está rodando!"
        fi
        ;;
    4)
        echo ""
        echo "🚀 Iniciando gerenciadores automáticos para TODOS os bancos..."
        echo "⏰ Operações executadas a cada 30 segundos em cada banco"
        echo "📋 Logs salvos em: logs/auto-*.log"
        echo "🔄 Para parar todos: make stop-auto-data"
        echo ""
        
        # Iniciar cada banco disponível em background
        if docker ps --format "table {{.Names}}" | grep -q "mysql_db"; then
            nohup python3 scripts/auto-data-manager.py mysql > logs/auto-mysql.log 2>&1 &
            echo "✅ MySQL iniciado em background (PID: $!)"
        fi
        
        if docker ps --format "table {{.Names}}" | grep -q "postgres_db"; then
            nohup python3 scripts/auto-data-manager.py postgres > logs/auto-postgres.log 2>&1 &
            echo "✅ PostgreSQL iniciado em background (PID: $!)"
        fi
        
        if docker ps --format "table {{.Names}}" | grep -q "sqlserver_db"; then
            nohup python3 scripts/auto-data-manager.py sqlserver > logs/auto-sqlserver.log 2>&1 &
            echo "✅ SQL Server iniciado em background (PID: $!)"
        fi
        
        echo ""
        echo "🎉 Todos os gerenciadores disponíveis foram iniciados!"
        echo ""
        echo "📊 Para monitorar:"
        echo "   make status-auto-data    # Status dos gerenciadores"
        echo "   make logs-auto-data      # Logs em tempo real"
        echo ""
        echo "⏹️  Para parar:"
        echo "   make stop-auto-data      # Para todos os gerenciadores"
        ;;
    5)
        echo "👋 Saindo..."
        exit 0
        ;;
    *)
        echo "❌ Opção inválida!"
        exit 1
        ;;
esac