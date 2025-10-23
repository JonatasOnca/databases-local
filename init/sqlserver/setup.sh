#!/bin/bash

# Aguarda o SQL Server inicializar completamente
echo "Aguardando SQL Server inicializar..."
sleep 10s

# Criar o banco testdb primeiro
echo "Criando banco de dados testdb..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "$SA_PASSWORD" -C -Q "CREATE DATABASE testdb;"

# Tenta executar o script de inicialização
echo "Executando script de inicialização..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "$SA_PASSWORD" -C -i /usr/config/init_script.sql

if [ $? -eq 0 ]; then
    echo "Script de inicialização executado com sucesso!"
    # Executar dados de exemplo
    echo "Executando dados de exemplo..."
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "$SA_PASSWORD" -C -i /usr/config/sample_data.sql
    if [ $? -eq 0 ]; then
        echo "SQL Server inicializado com sucesso!"
    else
        echo "Erro ao executar dados de exemplo"
    fi
else
    echo "Erro ao executar script de inicialização"
fi