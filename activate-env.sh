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
