#!/bin/bash

# ==============================================================================
# Script de Configuração do Ambiente Virtual Python
# ==============================================================================
# Este script configura um ambiente virtual Python (.venv) para o projeto
# Autor: Sistema de Database Local Environment
# Data: 2025-10-21

set -e  # Para no primeiro erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Função para log colorido
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_header() {
    echo -e "${PURPLE}🐍 $1${NC}"
}

# Diretório do projeto
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="$PROJECT_DIR/.venv"

log_header "Configuração do Ambiente Virtual Python"
echo "======================================================"
echo ""

# Verificar se Python3 está instalado
if ! command -v python3 &> /dev/null; then
    log_error "Python3 não encontrado. Instale o Python3 primeiro."
    exit 1
fi

PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
log_info "Python encontrado: $PYTHON_VERSION"

# Verificar se o módulo venv está disponível
if ! python3 -m venv --help &> /dev/null; then
    log_error "Módulo venv não disponível. Instale python3-venv:"
    echo "   # Ubuntu/Debian:"
    echo "   sudo apt-get install python3-venv"
    echo "   # macOS com Homebrew:"
    echo "   brew install python3"
    echo "   # CentOS/RHEL:"
    echo "   sudo yum install python3-venv"
    exit 1
fi

cd "$PROJECT_DIR"

# Verificar se já existe um ambiente virtual
if [ -d "$VENV_DIR" ]; then
    log_warning "Ambiente virtual já existe em: $VENV_DIR"
    read -p "Deseja recriar o ambiente virtual? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Removendo ambiente virtual existente..."
        rm -rf "$VENV_DIR"
    else
        log_info "Usando ambiente virtual existente."
        echo ""
        log_info "Para ativar o ambiente virtual, execute:"
        echo "   source .venv/bin/activate"
        echo ""
        log_info "Para instalar dependências:"
        echo "   make install-python-deps"
        exit 0
    fi
fi

# Criar ambiente virtual
log_info "Criando ambiente virtual em: $VENV_DIR"
python3 -m venv "$VENV_DIR"

# Verificar se foi criado com sucesso
if [ ! -d "$VENV_DIR" ]; then
    log_error "Falha ao criar ambiente virtual"
    exit 1
fi

log_success "Ambiente virtual criado com sucesso!"

# Ativar ambiente virtual e instalar dependências
log_info "Ativando ambiente virtual e instalando dependências..."

# Ativar o ambiente virtual
source "$VENV_DIR/bin/activate"

# Atualizar pip
log_info "Atualizando pip..."
python -m pip install --upgrade pip

# Verificar se requirements.txt existe
if [ ! -f "requirements.txt" ]; then
    log_error "Arquivo requirements.txt não encontrado!"
    exit 1
fi

# Instalar dependências
log_info "Instalando dependências do requirements.txt..."
pip install -r requirements.txt

log_success "Dependências instaladas com sucesso!"

# Criar arquivo de ativação rápida
log_info "Criando script de ativação rápida..."
cat > activate-env.sh << 'EOF'
#!/bin/bash
# Script de ativação rápida do ambiente virtual

# Ativar ambiente virtual
source .venv/bin/activate

echo "🐍 Ambiente virtual Python ativado!"
echo "📦 Localização: $(pwd)/.venv"
echo "🐍 Python: $(python --version)"
echo "📋 Pip: $(pip --version)"
echo ""
echo "💡 Para desativar: deactivate"
echo "📚 Para instalar deps: make install-python-deps"
EOF

chmod +x activate-env.sh

# Criar arquivo .gitignore se não existir ou atualizar
if [ ! -f .gitignore ]; then
    log_info "Criando .gitignore..."
    cat > .gitignore << 'EOF'
# Ambiente Virtual Python
.venv/
venv/
env/

# Arquivos Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Logs
logs/*.log
*.log

# Arquivos de ambiente
.env
.env.local
.env.development
.env.test
.env.production

# Backups
backups/

# IDEs
.vscode/
.idea/
*.swp
*.swo

# MacOS
.DS_Store

# Docker
.docker/
EOF
else
    # Verificar se .venv já está no .gitignore
    if ! grep -q "\.venv" .gitignore; then
        log_info "Adicionando .venv ao .gitignore..."
        echo "" >> .gitignore
        echo "# Ambiente Virtual Python" >> .gitignore
        echo ".venv/" >> .gitignore
    fi
fi

echo ""
log_success "Configuração concluída com sucesso!"
echo ""
echo "📋 Próximos passos:"
echo "   1. Para ativar o ambiente virtual:"
echo "      source .venv/bin/activate"
echo "      # ou use o script rápido:"
echo "      source activate-env.sh"
echo ""
echo "   2. Para instalar/atualizar dependências:"
echo "      make install-python-deps"
echo ""
echo "   3. Para executar scripts Python:"
echo "      make demo-quick"
echo "      make auto-data-mysql"
echo ""
echo "   4. Para desativar o ambiente:"
echo "      deactivate"
echo ""
log_info "O ambiente virtual está pronto para uso!"