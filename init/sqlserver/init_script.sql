-- O comando CREATE DATABASE não é necessário aqui,
-- pois as imagens Docker criam o DB automaticamente com as variáveis de ambiente.

-- Criar usuário devuser para compatibilidade com outros bancos
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'devuser')
BEGIN
    CREATE LOGIN devuser WITH PASSWORD = 'DevP@ssw0rd!';
END;

USE testdb;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'devuser')
BEGIN
    CREATE USER devuser FOR LOGIN devuser;
    ALTER ROLE db_owner ADD MEMBER devuser;
END;
GO

-- Tabela 1: Clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY IDENTITY(1,1),
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- Adicionar descrições para a tabela clientes
EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Tabela que armazena informações dos clientes',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = clientes;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Identificador único do cliente',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = clientes,
    @level2type = N'Column', @level2name = id;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Nome completo do cliente',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = clientes,
    @level2type = N'Column', @level2name = nome;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Endereço de email único do cliente',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = clientes,
    @level2type = N'Column', @level2name = email;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Data e hora de criação do registro',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = clientes,
    @level2type = N'Column', @level2name = created_at;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Data e hora da última atualização',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = clientes,
    @level2type = N'Column', @level2name = updated_at;

-- Tabela 2: Produtos
CREATE TABLE produtos (
    id INT PRIMARY KEY IDENTITY(1,1),
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10, 2) NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- Adicionar descrições para a tabela produtos
EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Tabela que armazena informações dos produtos',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = produtos;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Identificador único do produto',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = produtos,
    @level2type = N'Column', @level2name = id;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Nome do produto',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = produtos,
    @level2type = N'Column', @level2name = nome;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Preço do produto em decimal (10,2)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = produtos,
    @level2type = N'Column', @level2name = preco;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Data e hora de criação do registro',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = produtos,
    @level2type = N'Column', @level2name = created_at;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Data e hora da última atualização',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = produtos,
    @level2type = N'Column', @level2name = updated_at;

-- Tabela 3: Pedidos
CREATE TABLE pedidos (
    id INT PRIMARY KEY IDENTITY(1,1),
    cliente_id INT,
    data_pedido DATE,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Adicionar descrições para a tabela pedidos
EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Tabela que armazena informações dos pedidos',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = pedidos;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Identificador único do pedido',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = pedidos,
    @level2type = N'Column', @level2name = id;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Referência ao cliente que fez o pedido',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = pedidos,
    @level2type = N'Column', @level2name = cliente_id;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Data do pedido',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = pedidos,
    @level2type = N'Column', @level2name = data_pedido;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Data e hora de criação do registro',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = pedidos,
    @level2type = N'Column', @level2name = created_at;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Data e hora da última atualização',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = pedidos,
    @level2type = N'Column', @level2name = updated_at;

-- Tabela 4: Itens_Pedido
CREATE TABLE itens_pedido (
    pedido_id INT,
    produto_id INT,
    quantidade INT,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    PRIMARY KEY (pedido_id, produto_id),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
);

-- Adicionar descrições para a tabela itens_pedido
EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Tabela que armazena os itens de cada pedido',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = itens_pedido;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Referência ao pedido',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = itens_pedido,
    @level2type = N'Column', @level2name = pedido_id;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Referência ao produto',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = itens_pedido,
    @level2type = N'Column', @level2name = produto_id;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Quantidade do produto no pedido',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = itens_pedido,
    @level2type = N'Column', @level2name = quantidade;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Data e hora de criação do registro',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = itens_pedido,
    @level2type = N'Column', @level2name = created_at;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Data e hora da última atualização',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = itens_pedido,
    @level2type = N'Column', @level2name = updated_at;

-- Tabela 5: Logs
CREATE TABLE logs (
    id INT PRIMARY KEY IDENTITY(1,1),
    timestamp DATETIME2 DEFAULT GETDATE(),
    mensagem VARCHAR(255),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- Adicionar descrições para a tabela logs
EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Tabela que armazena logs do sistema',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = logs;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Identificador único do log',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = logs,
    @level2type = N'Column', @level2name = id;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Data e hora do evento de log',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = logs,
    @level2type = N'Column', @level2name = timestamp;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Mensagem do log',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = logs,
    @level2type = N'Column', @level2name = mensagem;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Data e hora de criação do registro',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = logs,
    @level2type = N'Column', @level2name = created_at;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Data e hora da última atualização',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = logs,
    @level2type = N'Column', @level2name = updated_at;

-- Tabela 6: Generic Table - Demonstração de tipos de dados SQL Server
CREATE TABLE generic_table (
    id INT PRIMARY KEY IDENTITY(1,1),
    -- Tipos numéricos inteiros
    campo_tinyint TINYINT,
    campo_smallint SMALLINT,
    campo_int INT,
    campo_bigint BIGINT,
    -- Tipos numéricos decimais
    campo_decimal DECIMAL(10,2),
    campo_numeric NUMERIC(15,5),
    campo_float FLOAT,
    campo_real REAL,
    campo_money MONEY,
    campo_smallmoney SMALLMONEY,
    -- Tipos de texto
    campo_char CHAR(10),
    campo_varchar VARCHAR(255),
    campo_text TEXT,
    campo_nchar NCHAR(10),
    campo_nvarchar NVARCHAR(255),
    campo_ntext NTEXT,
    -- Tipos de data e hora
    campo_date DATE,
    campo_time TIME,
    campo_datetime DATETIME,
    campo_datetime2 DATETIME2,
    campo_smalldatetime SMALLDATETIME,
    campo_datetimeoffset DATETIMEOFFSET,
    -- Tipos booleanos
    campo_bit BIT,
    -- Tipos binários
    campo_binary BINARY(16),
    campo_varbinary VARBINARY(255),
    campo_image IMAGE,
    -- Tipos especiais
    campo_uniqueidentifier UNIQUEIDENTIFIER DEFAULT NEWID(),
    campo_xml XML,
    campo_sql_variant SQL_VARIANT,
    campo_rowversion ROWVERSION,
    -- Tipos geográficos/espaciais
    campo_geometry GEOMETRY,
    campo_geography GEOGRAPHY,
    -- Tipos CLR
    campo_hierarchyid HIERARCHYID,
    -- Campos de controle
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- Adicionar descrições para a tabela generic_table
EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Tabela demonstrativa com todos os tipos de dados suportados pelo SQL Server',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Chave primária auto incremento',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = id;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Inteiro muito pequeno (0 a 255)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_tinyint;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Inteiro pequeno (-32768 a 32767)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_smallint;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Inteiro padrão (-2147483648 a 2147483647)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_int;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Inteiro grande (-9223372036854775808 a 9223372036854775807)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_bigint;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Decimal fixo com precisão (10 dígitos, 2 decimais)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_decimal;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Numérico com precisão variável (15 dígitos, 5 decimais)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_numeric;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Ponto flutuante de precisão variável',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_float;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Ponto flutuante de precisão simples',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_real;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Valor monetário (-922337203685477.5808 a 922337203685477.5807)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_money;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Valor monetário pequeno (-214748.3648 a 214748.3647)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_smallmoney;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'String de tamanho fixo (10 caracteres)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_char;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'String de tamanho variável (até 255 caracteres)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_varchar;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Texto longo (até 2GB)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_text;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'String Unicode de tamanho fixo (10 caracteres)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_nchar;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'String Unicode de tamanho variável (até 255 caracteres)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_nvarchar;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Texto Unicode longo (até 2GB)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_ntext;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Data (YYYY-MM-DD)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_date;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Hora (HH:MM:SS.nnnnnnn)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_time;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Data e hora (YYYY-MM-DD HH:MM:SS.nnn)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_datetime;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Data e hora com maior precisão (YYYY-MM-DD HH:MM:SS.nnnnnnn)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_datetime2;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Data e hora menor precisão (YYYY-MM-DD HH:MM:SS)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_smalldatetime;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Data e hora com timezone offset',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_datetimeoffset;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Valor booleano (0 ou 1)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_bit;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Dados binários de tamanho fixo',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_binary;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Dados binários de tamanho variável',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_varbinary;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Dados binários grandes (até 2GB)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_image;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Identificador único global (GUID)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_uniqueidentifier;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Dados XML',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_xml;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Dados de tipo variável',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_sql_variant;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Dados geométricos planares',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_geometry;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Dados geográficos (terra redonda)',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_geography;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Identificador hierárquico',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = campo_hierarchyid;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Data e hora de criação do registro',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = created_at;

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Data e hora da última atualização',
    @level0type = N'Schema', @level0name = dbo,
    @level1type = N'Table', @level1name = generic_table,
    @level2type = N'Column', @level2name = updated_at;
GO

-- Triggers para atualizar automaticamente o campo updated_at
CREATE TRIGGER tr_clientes_updated_at
ON clientes
AFTER UPDATE
AS
BEGIN
    UPDATE clientes 
    SET updated_at = GETDATE() 
    WHERE id IN (SELECT id FROM inserted);
END;
GO

CREATE TRIGGER tr_produtos_updated_at
ON produtos
AFTER UPDATE
AS
BEGIN
    UPDATE produtos 
    SET updated_at = GETDATE() 
    WHERE id IN (SELECT id FROM inserted);
END;
GO

CREATE TRIGGER tr_pedidos_updated_at
ON pedidos
AFTER UPDATE
AS
BEGIN
    UPDATE pedidos 
    SET updated_at = GETDATE() 
    WHERE id IN (SELECT id FROM inserted);
END;
GO

CREATE TRIGGER tr_itens_pedido_updated_at
ON itens_pedido
AFTER UPDATE
AS
BEGIN
    UPDATE itens_pedido 
    SET updated_at = GETDATE() 
    WHERE pedido_id IN (SELECT pedido_id FROM inserted) 
    AND produto_id IN (SELECT produto_id FROM inserted);
END;
GO

CREATE TRIGGER tr_logs_updated_at
ON logs
AFTER UPDATE
AS
BEGIN
    UPDATE logs 
    SET updated_at = GETDATE() 
    WHERE id IN (SELECT id FROM inserted);
END;
GO

CREATE TRIGGER tr_generic_table_updated_at
ON generic_table
AFTER UPDATE
AS
BEGIN
    UPDATE generic_table 
    SET updated_at = GETDATE() 
    WHERE id IN (SELECT id FROM inserted);
END;
GO