#!/bin/bash

# Script de inicialização inteligente
# Detecta ambiente e configura automaticamente a melhor configuração

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Função para detectar sistema
detect_system() {
    local arch=$(uname -m)
    local os=$(uname -s)
    local cpu_cores=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "4")
    local total_memory=""
    
    # Detectar memória baseado no OS
    if [[ "$os" == "Darwin" ]]; then
        total_memory=$(( $(sysctl -n hw.memsize) / 1024 / 1024 ))
    else
        total_memory=$(free -m | awk 'NR==2{print $2}')
    fi
    
    echo "SYSTEM_ARCH=$arch"
    echo "SYSTEM_OS=$os"
    echo "CPU_CORES=$cpu_cores"
    echo "TOTAL_MEMORY_MB=$total_memory"
}

# Função para verificar dependências
check_dependencies() {
    echo -e "${BLUE}🔍 Verificando dependências...${NC}"
    
    local missing_deps=()
    
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        missing_deps+=("docker")
    else
        # Verificar se Docker está rodando
        if ! docker info &>/dev/null; then
            echo -e "${RED}❌ Docker não está rodando${NC}"
            echo -e "${YELLOW}💡 Inicie o Docker Desktop${NC}"
            exit 1
        fi
    fi
    
    # Verificar Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        missing_deps+=("docker-compose")
    fi
    
    # Dependências opcionais mas recomendadas
    for cmd in bc jq make; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${RED}❌ Dependências faltando: ${missing_deps[*]}${NC}"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo -e "${YELLOW}💡 Para instalar no macOS: brew install ${missing_deps[*]}${NC}"
        elif command -v apt-get &> /dev/null; then
            echo -e "${YELLOW}💡 Para instalar no Ubuntu/Debian: sudo apt-get install ${missing_deps[*]}${NC}"
        elif command -v yum &> /dev/null; then
            echo -e "${YELLOW}💡 Para instalar no CentOS/RHEL: sudo yum install ${missing_deps[*]}${NC}"
        fi
        exit 1
    fi
    
    echo -e "${GREEN}✅ Todas as dependências encontradas${NC}"
}

# Função para configurar ambiente automaticamente
auto_configure_environment() {
    echo -e "${BLUE}⚙️  Configurando ambiente automaticamente...${NC}"
    
    # Ler informações do sistema
    eval $(detect_system)
    
    # Configurar .env se não existir
    if [ ! -f ".env" ]; then
        echo -e "${YELLOW}📝 Criando arquivo .env...${NC}"
        cp .env.example .env
        
        # Personalizar senhas
        local mysql_pass="DevPass$(date +%s | tail -c 4)"
        local sa_pass="DevSecure$(date +%s | tail -c 4)!"
        
        sed -i.bak "s/devpassword123/$mysql_pass/g" .env
        sed -i.bak "s/SuperSecureP@ssword2024!/$sa_pass/g" .env
        rm .env.bak 2>/dev/null || true
        
        echo -e "${GREEN}✅ Arquivo .env criado com senhas personalizadas${NC}"
    fi
    
    # Configurar limites de memória baseado no hardware
    echo -e "${BLUE}🧠 Configurando limites de memória...${NC}"
    
    local mysql_mem="512m"
    local postgres_mem="512m"
    local sqlserver_mem="2g"
    
    if [ $TOTAL_MEMORY_MB -lt 4096 ]; then
        # Sistemas com pouca memória
        mysql_mem="256m"
        postgres_mem="256m"
        sqlserver_mem="1g"
        echo -e "${YELLOW}⚠️  Sistema com pouca memória detectado - usando limites reduzidos${NC}"
    elif [ $TOTAL_MEMORY_MB -gt 16384 ]; then
        # Sistemas com muita memória
        mysql_mem="1g"
        postgres_mem="1g"
        sqlserver_mem="4g"
        echo -e "${GREEN}🚀 Sistema com muita memória detectado - usando limites aumentados${NC}"
    fi
    
    # Atualizar docker-compose.override.yml
    cat > docker-compose.override.yml << EOF
# Override automático gerado pelo setup inteligente
# Sistema: $SYSTEM_OS $SYSTEM_ARCH ($TOTAL_MEMORY_MB MB RAM, $CPU_CORES cores)

services:
  mysql_db:
    environment:
      - TZ=America/Sao_Paulo
    deploy:
      resources:
        limits:
          memory: $mysql_mem
          cpus: '$(echo "scale=1; $CPU_CORES / 2" | bc -l)'
        reservations:
          memory: $(echo "$mysql_mem" | sed 's/g$//' | sed 's/m$//' | awk '{print int($1/2)}')m

  postgres_db:
    environment:
      - TZ=America/Sao_Paulo
    deploy:
      resources:
        limits:
          memory: $postgres_mem
          cpus: '$(echo "scale=1; $CPU_CORES / 2" | bc -l)'
        reservations:
          memory: $(echo "$postgres_mem" | sed 's/g$//' | sed 's/m$//' | awk '{print int($1/2)}')m

  sqlserver_db:
    environment:
      - TZ=America/Sao_Paulo
    deploy:
      resources:
        limits:
          memory: $sqlserver_mem
          cpus: '$(echo "scale=1; $CPU_CORES / 1.5" | bc -l)'
        reservations:
          memory: $(echo "$sqlserver_mem" | sed 's/g$//' | awk '{print int($1*1024/2)}')m
EOF

    echo -e "${GREEN}✅ Configurações de recursos otimizadas${NC}"
}

# Função para sugerir comando de inicialização
suggest_startup_command() {
    eval $(detect_system)
    
    echo -e "\n${PURPLE}🚀 RECOMENDAÇÕES DE INICIALIZAÇÃO${NC}"
    echo "================================="
    
    if [[ "$SYSTEM_ARCH" == "arm64" ]]; then
        echo -e "${YELLOW}🍎 Mac M1/M2 detectado${NC}"
        echo -e "📝 Recomendação: ${GREEN}make up-native${NC} (apenas bancos nativos)"
        echo -e "📝 Alternativa: ${BLUE}make up${NC} (inclui SQL Server via emulação)"
    else
        echo -e "${GREEN}💻 Arquitetura x86_64 detectada${NC}"
        echo -e "📝 Recomendação: ${GREEN}make up${NC} (todos os bancos nativos)"
    fi
    
    # Recomendações baseadas na memória
    if [ $TOTAL_MEMORY_MB -lt 4096 ]; then
        echo -e "⚠️  ${YELLOW}Memória limitada - considere usar apenas 1-2 bancos${NC}"
        echo -e "💡 Comandos específicos: make up-mysql, make up-postgres"
    fi
    
    echo -e "\n${BLUE}📋 Próximos passos sugeridos:${NC}"
    echo "1. make up-native    # Iniciar bancos"
    echo "2. make load-sample-data  # Carregar dados de exemplo"
    echo "3. make validate     # Validar ambiente"
    echo "4. make health-check # Verificar saúde"
}

# Função para configurar ferramentas de desenvolvimento
setup_dev_tools() {
    echo -e "${BLUE}🛠️  Configurando ferramentas de desenvolvimento...${NC}"
    
    # Criar estrutura de diretórios
    mkdir -p logs backups/{mysql,postgres,sqlserver}
    
    # Configurar git hooks se for um repositório git
    if [ -d ".git" ]; then
        # Pre-commit hook para verificar .env
        cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Verificar se .env não está sendo commitado
if git diff --cached --name-only | grep -q "^\.env$"; then
    echo "❌ ERRO: Arquivo .env não deve ser commitado"
    echo "💡 Use: git reset HEAD .env"
    exit 1
fi
EOF
        chmod +x .git/hooks/pre-commit
        echo -e "${GREEN}✅ Git hooks configurados${NC}"
    fi
    
    # Criar arquivo de configuração do VS Code
    mkdir -p .vscode
    cat > .vscode/settings.json << 'EOF'
{
    "files.exclude": {
        "**/.env": false
    },
    "files.watcherExclude": {
        "**/logs/**": true,
        "**/backups/**": true
    },
    "extensions.recommendations": [
        "ms-vscode.vscode-docker",
        "ms-azuretools.vscode-docker",
        "ms-vscode.makefile-tools"
    ]
}
EOF
    
    echo -e "${GREEN}✅ Ferramentas de desenvolvimento configuradas${NC}"
}

# Função para executar testes iniciais
run_initial_tests() {
    echo -e "${BLUE}🧪 Executando testes iniciais...${NC}"
    
    # Verificar se containers podem ser criados
    echo -e "📦 Testando criação de containers..."
    if docker-compose config &>/dev/null; then
        echo -e "${GREEN}✅ Configuração do Docker Compose válida${NC}"
    else
        echo -e "${RED}❌ Erro na configuração do Docker Compose${NC}"
        exit 1
    fi
    
    # Verificar conectividade de rede
    echo -e "🌐 Testando conectividade..."
    if ping -c 1 google.com &>/dev/null; then
        echo -e "${GREEN}✅ Conectividade com internet OK${NC}"
    else
        echo -e "${YELLOW}⚠️  Sem conectividade com internet (normal em algumas redes)${NC}"
    fi
    
    echo -e "${GREEN}✅ Testes iniciais concluídos${NC}"
}

# Função para mostrar resumo final
show_final_summary() {
    echo -e "\n${GREEN}🎉 CONFIGURAÇÃO INTELIGENTE CONCLUÍDA${NC}"
    echo "======================================"
    
    eval $(detect_system)
    
    echo -e "🖥️  Sistema: $SYSTEM_OS $SYSTEM_ARCH"
    echo -e "🧠 Memória: $(echo "scale=1; $TOTAL_MEMORY_MB / 1024" | bc -l)GB"
    echo -e "⚙️  CPU Cores: $CPU_CORES"
    echo -e "📁 Diretório: $(pwd)"
    
    echo -e "\n${BLUE}📋 Arquivos configurados:${NC}"
    echo "• .env (credenciais personalizadas)"
    echo "• docker-compose.override.yml (recursos otimizados)"
    echo "• logs/ (diretório de logs)"
    echo "• backups/ (diretório de backups)"
    
    suggest_startup_command
    
    echo -e "\n${YELLOW}💡 Comandos úteis:${NC}"
    echo "make help           # Ver todos os comandos"
    echo "make detect         # Detectar arquitetura"
    echo "make monitor        # Monitoramento em tempo real"
    echo "make backup-auto    # Backup automatizado"
    
    echo -e "\n${GREEN}✨ Ambiente pronto para uso!${NC}"
}

# Função para mostrar ajuda
show_help() {
    echo "Setup Inteligente - Database Local Environment"
    echo "=============================================="
    echo ""
    echo "Uso: $0 [opções]"
    echo ""
    echo "Opções:"
    echo "  --help, -h         Mostra esta ajuda"
    echo "  --force           Força reconfiguração (sobrescreve arquivos)"
    echo "  --minimal         Configuração mínima (sem ferramentas extras)"
    echo "  --auto-start      Inicia automaticamente após configuração"
    echo "  --dev-tools       Configura apenas ferramentas de desenvolvimento"
    echo ""
    echo "Exemplos:"
    echo "  $0                # Configuração completa"
    echo "  $0 --auto-start   # Configura e inicia"
    echo "  $0 --minimal      # Configuração básica"
}

# Função principal
main() {
    local force_mode=false
    local minimal_mode=false
    local auto_start=false
    local dev_tools_only=false
    
    # Parse argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --force)
                force_mode=true
                ;;
            --minimal)
                minimal_mode=true
                ;;
            --auto-start)
                auto_start=true
                ;;
            --dev-tools)
                dev_tools_only=true
                ;;
            *)
                echo "Opção desconhecida: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done
    
    echo -e "${GREEN}🚀 SETUP INTELIGENTE - DATABASE ENVIRONMENT${NC}"
    echo "============================================="
    
    # Verificar se já está configurado
    if [ -f ".env" ] && [ -f "docker-compose.override.yml" ] && [ "$force_mode" = false ]; then
        echo -e "${YELLOW}⚠️  Ambiente já parece estar configurado${NC}"
        echo -e "💡 Use --force para reconfigurar"
        suggest_startup_command
        exit 0
    fi
    
    # Verificar dependências
    check_dependencies
    
    if [ "$dev_tools_only" = true ]; then
        setup_dev_tools
        exit 0
    fi
    
    # Configurar ambiente
    auto_configure_environment
    
    if [ "$minimal_mode" = false ]; then
        setup_dev_tools
    fi
    
    # Executar testes
    run_initial_tests
    
    # Mostrar resumo
    show_final_summary
    
    # Auto-start se solicitado
    if [ "$auto_start" = true ]; then
        echo -e "\n${BLUE}🚀 Iniciando ambiente automaticamente...${NC}"
        eval $(detect_system)
        
        if [[ "$SYSTEM_ARCH" == "arm64" ]]; then
            make up-native
        else
            make up
        fi
        
        echo -e "${GREEN}✅ Ambiente iniciado com sucesso!${NC}"
    fi
}

# Executar apenas se chamado diretamente
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi