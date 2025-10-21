#!/bin/bash

# Script para configuração automática baseada na arquitetura
# Detecta o sistema e sugere a melhor configuração

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Detectando arquitetura do sistema...${NC}"

# Detectar arquitetura
ARCH=$(uname -m)
OS=$(uname -s)

echo -e "📊 Sistema: ${GREEN}$OS${NC}"
echo -e "🏗️  Arquitetura: ${GREEN}$ARCH${NC}"

# Recomendações baseadas na arquitetura
case $ARCH in
    "arm64")
        echo -e "\n${YELLOW}🍎 Mac M1/M2 (ARM64) detectado${NC}"
        echo -e "📝 Recomendações:"
        echo -e "  ✅ MySQL e PostgreSQL: ${GREEN}Nativos (performance total)${NC}"
        echo -e "  ⚠️  SQL Server: ${YELLOW}Emulação x86_64 (performance reduzida)${NC}"
        echo -e "\n💡 Sugestões:"
        echo -e "  • Para desenvolvimento rápido: ${BLUE}make up-native${NC} (MySQL + PostgreSQL)"
        echo -e "  • Para ambiente completo: ${BLUE}make up${NC} (inclui SQL Server)"
        ;;
    "x86_64")
        echo -e "\n${GREEN}💻 Arquitetura x86_64 detectada${NC}"
        echo -e "✅ Todas as imagens são nativas - performance total em todos os bancos"
        echo -e "\n💡 Sugestão: ${BLUE}make up${NC} (ambiente completo)"
        ;;
    *)
        echo -e "\n${RED}❓ Arquitetura não reconhecida: $ARCH${NC}"
        echo -e "⚠️  Pode haver problemas de compatibilidade"
        ;;
esac

# Verificar se Docker está instalado
echo -e "\n${BLUE}🐳 Verificando Docker...${NC}"
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | cut -d ' ' -f3 | cut -d ',' -f1)
    echo -e "✅ Docker ${GREEN}$DOCKER_VERSION${NC} instalado"
else
    echo -e "${RED}❌ Docker não encontrado${NC}"
    echo -e "📋 Instale o Docker Desktop: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Verificar se Docker Compose está disponível
if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version | cut -d ' ' -f3 | cut -d ',' -f1)
    echo -e "✅ Docker Compose ${GREEN}$COMPOSE_VERSION${NC} instalado"
elif docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version | cut -d ' ' -f4)
    echo -e "✅ Docker Compose ${GREEN}$COMPOSE_VERSION${NC} (plugin) instalado"
else
    echo -e "${RED}❌ Docker Compose não encontrado${NC}"
    exit 1
fi

# Verificar recursos disponíveis
echo -e "\n${BLUE}📊 Verificando recursos do sistema...${NC}"

# Memória disponível (funciona no macOS e Linux)
if [[ "$OS" == "Darwin" ]]; then
    TOTAL_MEM=$(( $(sysctl -n hw.memsize) / 1024 / 1024 ))
else
    TOTAL_MEM=$(free -m | awk 'NR==2{print $2}')
fi

echo -e "💾 Memória total: ${GREEN}${TOTAL_MEM}MB${NC}"

if [ $TOTAL_MEM -lt 4096 ]; then
    echo -e "${YELLOW}⚠️  Memória baixa detectada (<4GB)${NC}"
    echo -e "💡 Considere usar apenas 1-2 bancos simultaneamente"
elif [ $TOTAL_MEM -lt 8192 ]; then
    echo -e "${YELLOW}⚠️  Memória moderada (4-8GB)${NC}"
    echo -e "💡 Recomendado usar profiles para bancos específicos"
else
    echo -e "✅ Memória suficiente para todos os bancos"
fi

echo -e "\n${GREEN}🎉 Verificação concluída!${NC}"
echo -e "📚 Consulte o README.md para comandos disponíveis"