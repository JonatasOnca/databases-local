#!/bin/bash

# Aguarda o SQL Server inicializar completamente
echo "Aguardando SQL Server inicializar..."
sleep 10s

# Tenta executar o script de inicialização
echo "Executando script de inicialização..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "$SA_PASSWORD" -C -d master -i /usr/config/init_script.sql

if [ $? -eq 0 ]; then
    echo "SQL Server inicializado com sucesso!"
else
    echo "Erro ao executar script de inicialização"
fi