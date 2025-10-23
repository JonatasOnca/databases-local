-- O comando CREATE DATABASE não é necessário aqui,
-- pois as imagens Docker criam o DB automaticamente com as variáveis de ambiente.

-- Configurar charset para UTF-8
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- Tabela 1: Clientes
CREATE TABLE IF NOT EXISTS clientes (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificador único do cliente',
    nome VARCHAR(100) NOT NULL COMMENT 'Nome completo do cliente',
    email VARCHAR(100) UNIQUE COMMENT 'Endereço de email único do cliente',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora de criação do registro',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data e hora da última atualização'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tabela que armazena informações dos clientes';

-- Tabela 2: Produtos
CREATE TABLE IF NOT EXISTS produtos (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificador único do produto',
    nome VARCHAR(100) NOT NULL COMMENT 'Nome do produto',
    preco DECIMAL(10, 2) NOT NULL COMMENT 'Preço do produto em decimal (10,2)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora de criação do registro',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data e hora da última atualização'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tabela que armazena informações dos produtos';

-- Tabela 3: Pedidos
CREATE TABLE IF NOT EXISTS pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificador único do pedido',
    cliente_id INT COMMENT 'Referência ao cliente que fez o pedido',
    data_pedido DATE COMMENT 'Data do pedido',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora de criação do registro',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data e hora da última atualização',
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tabela que armazena informações dos pedidos';

-- Tabela 4: Itens_Pedido
CREATE TABLE IF NOT EXISTS itens_pedido (
    pedido_id INT COMMENT 'Referência ao pedido',
    produto_id INT COMMENT 'Referência ao produto',
    quantidade INT COMMENT 'Quantidade do produto no pedido',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora de criação do registro',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data e hora da última atualização',
    PRIMARY KEY (pedido_id, produto_id),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tabela que armazena os itens de cada pedido';

-- Tabela 5: Logs
CREATE TABLE IF NOT EXISTS logs (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificador único do log',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora do evento de log',
    mensagem VARCHAR(255) COMMENT 'Mensagem do log',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora de criação do registro',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data e hora da última atualização'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tabela que armazena logs do sistema';

-- Tabela 6: Generic Table - Demonstração de tipos de dados MySQL
CREATE TABLE IF NOT EXISTS generic_table (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Chave primária auto incremento',
    -- Tipos numéricos inteiros
    campo_tinyint TINYINT COMMENT 'Inteiro muito pequeno (-128 a 127)',
    campo_tinyint_unsigned TINYINT UNSIGNED COMMENT 'Inteiro muito pequeno sem sinal (0 a 255)',
    campo_smallint SMALLINT COMMENT 'Inteiro pequeno (-32768 a 32767)',
    campo_smallint_unsigned SMALLINT UNSIGNED COMMENT 'Inteiro pequeno sem sinal (0 a 65535)',
    campo_mediumint MEDIUMINT COMMENT 'Inteiro médio (-8388608 a 8388607)',
    campo_mediumint_unsigned MEDIUMINT UNSIGNED COMMENT 'Inteiro médio sem sinal (0 a 16777215)',
    campo_int INT COMMENT 'Inteiro padrão (-2147483648 a 2147483647)',
    campo_int_unsigned INT UNSIGNED COMMENT 'Inteiro sem sinal (0 a 4294967295)',
    campo_bigint BIGINT COMMENT 'Inteiro grande (-9223372036854775808 a 9223372036854775807)',
    campo_bigint_unsigned BIGINT UNSIGNED COMMENT 'Inteiro grande sem sinal (0 a 18446744073709551615)',
    -- Tipos numéricos decimais
    campo_decimal DECIMAL(10,2) COMMENT 'Decimal fixo com precisão (10 dígitos, 2 decimais)',
    campo_float FLOAT COMMENT 'Ponto flutuante de precisão simples',
    campo_double DOUBLE COMMENT 'Ponto flutuante de precisão dupla',
    -- Tipos de texto
    campo_char CHAR(10) COMMENT 'String de tamanho fixo (10 caracteres)',
    campo_varchar VARCHAR(255) COMMENT 'String de tamanho variável (até 255 caracteres)',
    campo_text TEXT COMMENT 'Texto longo (até 65535 caracteres)',
    campo_mediumtext MEDIUMTEXT COMMENT 'Texto médio (até 16777215 caracteres)',
    campo_longtext LONGTEXT COMMENT 'Texto muito longo (até 4294967295 caracteres)',
    -- Tipos de data e hora
    campo_date DATE COMMENT 'Data (YYYY-MM-DD)',
    campo_time TIME COMMENT 'Hora (HH:MM:SS)',
    campo_datetime DATETIME COMMENT 'Data e hora (YYYY-MM-DD HH:MM:SS)',
    campo_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp (data e hora com timezone)',
    campo_year YEAR COMMENT 'Ano (YYYY)',
    -- Tipos binários
    campo_binary BINARY(16) COMMENT 'Dados binários de tamanho fixo',
    campo_varbinary VARBINARY(255) COMMENT 'Dados binários de tamanho variável',
    campo_blob BLOB COMMENT 'Objeto binário grande (até 65535 bytes)',
    campo_mediumblob MEDIUMBLOB COMMENT 'Blob médio (até 16777215 bytes)',
    campo_longblob LONGBLOB COMMENT 'Blob longo (até 4294967295 bytes)',
    -- Tipos especiais
    campo_boolean BOOLEAN COMMENT 'Valor booleano (TRUE/FALSE)',
    campo_bit BIT(8) COMMENT 'Valor de bit (até 64 bits)',
    campo_enum ENUM('valor1', 'valor2', 'valor3') COMMENT 'Enumeração de valores predefinidos',
    campo_set SET('opcao1', 'opcao2', 'opcao3') COMMENT 'Conjunto de valores (múltiplas escolhas)',
    campo_json JSON COMMENT 'Dados em formato JSON',
    -- Tipos geométricos (MySQL suporta tipos espaciais)
    campo_geometry GEOMETRY COMMENT 'Dados geométricos genéricos',
    campo_point POINT COMMENT 'Ponto geométrico (x, y)',
    campo_linestring LINESTRING COMMENT 'Linha geométrica (sequência de pontos)',
    campo_polygon POLYGON COMMENT 'Polígono geométrico',
    campo_multipoint MULTIPOINT COMMENT 'Múltiplos pontos geométricos',
    campo_multilinestring MULTILINESTRING COMMENT 'Múltiplas linhas geométricas',
    campo_multipolygon MULTIPOLYGON COMMENT 'Múltiplos polígonos geométricos',
    campo_geometrycollection GEOMETRYCOLLECTION COMMENT 'Coleção de geometrias',
    -- Campos de controle
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora de criação do registro',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data e hora da última atualização'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tabela demonstrativa com todos os tipos de dados suportados pelo MySQL';