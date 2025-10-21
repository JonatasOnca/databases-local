#!/bin/bash

# Aguarda o SQL Server inicializar
sleep 30s

# Executa o script de inicialização
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$SA_PASSWORD" -d master -i /usr/config/init_script.sql

echo "SQL Server inicializado com sucesso!"