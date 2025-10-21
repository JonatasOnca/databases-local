# Docker Compose para diferentes arquiteturas

## Configuração Multi-Arquitetura

### ✅ Compatibilidade por Plataforma:

| Serviço | Windows | Linux | Mac Intel | Mac M1/M2 |
|---------|---------|-------|-----------|----------|
| MySQL | ✅ | ✅ | ✅ | ✅ |
| PostgreSQL | ✅ | ✅ | ✅ | ✅ |
| SQL Server | ✅ | ✅ | ✅ | ⚠️ Emulação |

### 📝 Notas Importantes:

1. **SQL Server no Mac M1/M2**: Executa via emulação (mais lento)
2. **Windows**: Requer Docker Desktop com WSL2
3. **Linux**: Nativo em todas as arquiteturas
4. **Mac Intel**: Totalmente nativo

### 🔧 Configurações Específicas:

- **Mac M1/M2**: SQL Server usa emulação x86_64
- **Windows/Linux**: Execução nativa
- **Todas as plataformas**: MySQL e PostgreSQL nativos