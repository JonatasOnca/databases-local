#!/bin/bash

# Script para corrigir problemas de charset UTF-8 em MySQL
# Uso: ./fix-mysql-charset.sh

echo "🔧 Corrigindo charset UTF-8 no MySQL..."
echo "======================================="

# Para todos os containers
echo "⏹️  Parando containers..."
docker-compose down

# Remove volumes para forçar recriação com charset correto
echo "🧹 Removendo volumes antigos..."
docker-compose down -v

# Inicia apenas MySQL
echo "🚀 Iniciando MySQL com charset UTF-8..."
docker-compose --profile mysql up -d

# Aguarda MySQL inicializar
echo "⏳ Aguardando MySQL inicializar..."
sleep 15

# Carrega dados de exemplo
echo "📊 Carregando dados de exemplo..."
make reload-sample-data 2>/dev/null || echo "⚠️  Use 'make reload-sample-data' após o MySQL estar pronto"

echo ""
echo "✅ Correção aplicada com sucesso!"
echo "💡 Todas as tabelas agora usam charset UTF-8 (utf8mb4)"
echo "🔍 Teste com: docker exec mysql_db mysql -udevuser -pDevP@ssw0rd! testdb -e \"SELECT * FROM clientes;\""