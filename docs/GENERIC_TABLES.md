# Tabelas Generic Table - Demonstração de Tipos de Dados

Este documento descreve as tabelas `generic_table` criadas em cada banco de dados para demonstrar os tipos de dados suportados por MySQL, PostgreSQL e SQL Server.

## Objetivo

As tabelas `generic_table` foram criadas para:
- Demonstrar todos os principais tipos de dados suportados por cada SGBD
- Servir como referência para desenvolvedores
- Facilitar testes de compatibilidade entre diferentes bancos
- Exemplificar o uso prático de cada tipo de dado

## MySQL - generic_table

### Tipos Numéricos Inteiros
- `campo_tinyint` - TINYINT: -128 a 127
- `campo_smallint` - SMALLINT: -32768 a 32767  
- `campo_mediumint` - MEDIUMINT: -8388608 a 8388607
- `campo_int` - INT: -2147483648 a 2147483647
- `campo_bigint` - BIGINT: -9223372036854775808 a 9223372036854775807

### Tipos Numéricos Decimais
- `campo_decimal` - DECIMAL(10,2): Decimal fixo com precisão
- `campo_float` - FLOAT: Ponto flutuante de precisão simples
- `campo_double` - DOUBLE: Ponto flutuante de precisão dupla

### Tipos de Texto
- `campo_char` - CHAR(10): String de tamanho fixo
- `campo_varchar` - VARCHAR(255): String de tamanho variável
- `campo_text` - TEXT: Texto longo (até 65535 caracteres)
- `campo_mediumtext` - MEDIUMTEXT: Texto médio (até 16777215 caracteres)
- `campo_longtext` - LONGTEXT: Texto muito longo (até 4294967295 caracteres)

### Tipos de Data e Hora
- `campo_date` - DATE: Data (YYYY-MM-DD)
- `campo_time` - TIME: Hora (HH:MM:SS)
- `campo_datetime` - DATETIME: Data e hora
- `campo_timestamp` - TIMESTAMP: Timestamp com timezone
- `campo_year` - YEAR: Ano (YYYY)

### Tipos Binários
- `campo_binary` - BINARY(16): Dados binários de tamanho fixo
- `campo_varbinary` - VARBINARY(255): Dados binários de tamanho variável
- `campo_blob` - BLOB: Objeto binário grande
- `campo_mediumblob` - MEDIUMBLOB: Blob médio
- `campo_longblob` - LONGBLOB: Blob longo

### Tipos Especiais
- `campo_boolean` - BOOLEAN: Valor booleano
- `campo_bit` - BIT(8): Valor de bit
- `campo_enum` - ENUM: Enumeração de valores
- `campo_set` - SET: Conjunto de valores
- `campo_json` - JSON: Dados em formato JSON
- `campo_geometry` - GEOMETRY: Dados geométricos
- `campo_point` - POINT: Ponto geométrico

## PostgreSQL - generic_table

### Tipos Numéricos
- `campo_smallint` - SMALLINT: -32768 a 32767
- `campo_integer` - INTEGER: -2147483648 a 2147483647
- `campo_bigint` - BIGINT: -9223372036854775808 a 9223372036854775807
- `campo_decimal` - DECIMAL(10,2): Decimal fixo
- `campo_numeric` - NUMERIC(15,5): Numérico com precisão variável
- `campo_real` - REAL: Ponto flutuante simples
- `campo_double_precision` - DOUBLE PRECISION: Ponto flutuante duplo

### Tipos de Texto
- `campo_char` - CHAR(10): String de tamanho fixo
- `campo_varchar` - VARCHAR(255): String de tamanho variável
- `campo_text` - TEXT: Texto de tamanho ilimitado

### Tipos de Data e Hora
- `campo_date` - DATE: Data
- `campo_time` - TIME: Hora
- `campo_timestamp` - TIMESTAMP: Data e hora sem timezone
- `campo_timestamptz` - TIMESTAMPTZ: Data e hora com timezone
- `campo_interval` - INTERVAL: Intervalo de tempo

### Tipos Especiais PostgreSQL
- `campo_boolean` - BOOLEAN: Valor booleano
- `campo_bytea` - BYTEA: Dados binários
- `campo_inet` - INET: Endereço IP
- `campo_cidr` - CIDR: Bloco de rede CIDR
- `campo_macaddr` - MACADDR: Endereço MAC (6 bytes)
- `campo_macaddr8` - MACADDR8: Endereço MAC (8 bytes)
- `campo_uuid` - UUID: Identificador único universal
- `campo_json` - JSON: Dados JSON (texto)
- `campo_jsonb` - JSONB: Dados JSON binário (indexável)
- `campo_xml` - XML: Dados XML
- `campo_money` - MONEY: Valor monetário

### Tipos de Array
- `campo_int_array` - INTEGER[]: Array de inteiros
- `campo_text_array` - TEXT[]: Array de texto

### Tipos Geométricos
- `campo_point` - POINT: Ponto geométrico
- `campo_line` - LINE: Linha infinita
- `campo_lseg` - LSEG: Segmento de linha
- `campo_box` - BOX: Retângulo
- `campo_path` - PATH: Caminho geométrico
- `campo_polygon` - POLYGON: Polígono
- `campo_circle` - CIRCLE: Círculo

### Tipos de Bit
- `campo_bit` - BIT(8): Sequência de bits de tamanho fixo
- `campo_bit_varying` - BIT VARYING(16): Sequência de bits de tamanho variável

### Tipos de Range
- `campo_int4range` - INT4RANGE: Range de inteiros (int4)
- `campo_int8range` - INT8RANGE: Range de inteiros (int8)
- `campo_numrange` - NUMRANGE: Range numérico
- `campo_tsrange` - TSRANGE: Range de timestamp
- `campo_tstzrange` - TSTZRANGE: Range de timestamp com timezone
- `campo_daterange` - DATERANGE: Range de datas

## SQL Server - generic_table

### Tipos Numéricos Inteiros
- `campo_tinyint` - TINYINT: 0 a 255
- `campo_smallint` - SMALLINT: -32768 a 32767
- `campo_int` - INT: -2147483648 a 2147483647
- `campo_bigint` - BIGINT: -9223372036854775808 a 9223372036854775807

### Tipos Numéricos Decimais
- `campo_decimal` - DECIMAL(10,2): Decimal fixo
- `campo_numeric` - NUMERIC(15,5): Numérico com precisão
- `campo_float` - FLOAT: Ponto flutuante de precisão variável
- `campo_real` - REAL: Ponto flutuante de precisão simples
- `campo_money` - MONEY: Valor monetário grande
- `campo_smallmoney` - SMALLMONEY: Valor monetário pequeno

### Tipos de Texto
- `campo_char` - CHAR(10): String de tamanho fixo
- `campo_varchar` - VARCHAR(255): String de tamanho variável
- `campo_text` - TEXT: Texto longo (até 2GB)
- `campo_nchar` - NCHAR(10): String Unicode de tamanho fixo
- `campo_nvarchar` - NVARCHAR(255): String Unicode de tamanho variável
- `campo_ntext` - NTEXT: Texto Unicode longo

### Tipos de Data e Hora
- `campo_date` - DATE: Data
- `campo_time` - TIME: Hora
- `campo_datetime` - DATETIME: Data e hora
- `campo_datetime2` - DATETIME2: Data e hora com maior precisão
- `campo_smalldatetime` - SMALLDATETIME: Data e hora com menor precisão
- `campo_datetimeoffset` - DATETIMEOFFSET: Data e hora com timezone offset

### Tipos Especiais SQL Server
- `campo_bit` - BIT: Valor booleano (0 ou 1)
- `campo_binary` - BINARY(16): Dados binários de tamanho fixo
- `campo_varbinary` - VARBINARY(255): Dados binários de tamanho variável
- `campo_image` - IMAGE: Dados binários grandes
- `campo_uniqueidentifier` - UNIQUEIDENTIFIER: GUID
- `campo_xml` - XML: Dados XML
- `campo_sql_variant` - SQL_VARIANT: Dados de tipo variável
- `campo_geometry` - GEOMETRY: Dados geométricos planares
- `campo_geography` - GEOGRAPHY: Dados geográficos (terra redonda)
- `campo_hierarchyid` - HIERARCHYID: Identificador hierárquico

## Exemplos de Uso

### Consultar todos os tipos de dados:

**MySQL:**
```sql
SELECT * FROM generic_table;
```

**PostgreSQL:**
```sql
SELECT * FROM generic_table;
```

**SQL Server:**
```sql
SELECT * FROM generic_table;
```

### Inserir novos dados de exemplo:

**MySQL:**
```sql
INSERT INTO generic_table (campo_varchar, campo_int, campo_decimal, campo_boolean, campo_json) 
VALUES ('Teste', 123, 456.78, TRUE, '{"teste": "valor"}');
```

**PostgreSQL:**
```sql
INSERT INTO generic_table (campo_varchar, campo_integer, campo_decimal, campo_boolean, campo_jsonb) 
VALUES ('Teste', 123, 456.78, TRUE, '{"teste": "valor"}');
```

**SQL Server:**
```sql
INSERT INTO generic_table (campo_varchar, campo_int, campo_decimal, campo_bit, campo_xml) 
VALUES ('Teste', 123, 456.78, 1, '<teste>valor</teste>');
```

## Notas Importantes

1. **Compatibilidade**: Nem todos os tipos são compatíveis entre os bancos
2. **Precisão**: Alguns tipos têm precisões diferentes entre os SGBDs
3. **Limites**: Os limites de tamanho variam entre os bancos
4. **Encoding**: PostgreSQL e SQL Server têm melhor suporte para Unicode
5. **JSON**: PostgreSQL tem o tipo JSONB otimizado, MySQL tem JSON nativo, SQL Server usa XML como alternativa principal

## Como Testar

1. Inicie os containers Docker com `docker-compose up -d`
2. Conecte-se a cada banco usando suas credenciais
3. Execute consultas nas tabelas `generic_table`
4. Compare os resultados entre os diferentes SGBDs
5. Teste inserções com diferentes tipos de dados

## Recursos Adicionais

- [Documentação MySQL - Tipos de Dados](https://dev.mysql.com/doc/refman/8.0/en/data-types.html)
- [Documentação PostgreSQL - Tipos de Dados](https://www.postgresql.org/docs/current/datatype.html)
- [Documentação SQL Server - Tipos de Dados](https://docs.microsoft.com/en-us/sql/t-sql/data-types/data-types-transact-sql)