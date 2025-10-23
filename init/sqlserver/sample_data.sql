-- Dados de exemplo específicos para SQL Server

-- Garantir que estamos no banco correto
USE testdb;
GO

-- Resetar contadores IDENTITY para começar do 1
DBCC CHECKIDENT('clientes', RESEED, 0);
DBCC CHECKIDENT('produtos', RESEED, 0);
DBCC CHECKIDENT('pedidos', RESEED, 0);
DBCC CHECKIDENT('logs', RESEED, 0);
DBCC CHECKIDENT('generic_table', RESEED, 0);
GO

-- Inserir clientes
SET IDENTITY_INSERT clientes ON;
INSERT INTO clientes (id, nome, email) VALUES 
(1, 'João Silva', 'joao@email.com'),
(2, 'Maria Santos', 'maria@email.com'),
(3, 'Pedro Oliveira', 'pedro@email.com');
SET IDENTITY_INSERT clientes OFF;

-- Inserir produtos
SET IDENTITY_INSERT produtos ON;
INSERT INTO produtos (id, nome, preco) VALUES 
(1, 'Notebook Dell', 2500.00),
(2, 'Mouse Logitech', 150.00),
(3, 'Teclado Mecânico', 300.00),
(4, 'Monitor 24"', 800.00);
SET IDENTITY_INSERT produtos OFF;

-- Inserir pedidos
SET IDENTITY_INSERT pedidos ON;
INSERT INTO pedidos (id, cliente_id, data_pedido) VALUES 
(1, 1, '2024-01-15'),
(2, 2, '2024-01-16'),
(3, 1, '2024-01-17');
SET IDENTITY_INSERT pedidos OFF;

-- Inserir itens dos pedidos
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade) VALUES 
(1, 1, 1),  -- João comprou 1 notebook
(1, 2, 1),  -- João comprou 1 mouse
(2, 3, 1),  -- Maria comprou 1 teclado
(2, 4, 1),  -- Maria comprou 1 monitor
(3, 2, 2);  -- João comprou 2 mouses

-- Inserir logs
SET IDENTITY_INSERT logs ON;
INSERT INTO logs (id, mensagem) VALUES 
(1, 'Sistema inicializado'),
(2, 'Dados de exemplo inseridos');
SET IDENTITY_INSERT logs OFF;

-- Inserir dados na tabela generic_table (exemplo com tipos de dados SQL Server)
SET IDENTITY_INSERT generic_table ON;
INSERT INTO generic_table (
    id,
    campo_tinyint, campo_smallint, campo_int, campo_bigint,
    campo_decimal, campo_numeric, campo_float, campo_real, campo_money, campo_smallmoney,
    campo_char, campo_varchar, campo_text, campo_nchar, campo_nvarchar, campo_ntext,
    campo_date, campo_time, campo_datetime, campo_datetime2, campo_smalldatetime, campo_datetimeoffset,
    campo_bit,
    campo_binary, campo_varbinary, campo_image,
    campo_uniqueidentifier,
    campo_xml,
    campo_sql_variant,
    campo_geometry, campo_geography,
    campo_hierarchyid
) VALUES (
    1,
    255, 32767, 2147483647, 9223372036854775807,
    99999999.99, 12345.67890, 3.14159, 2.71828, 922337203685477.5807, 214748.3647,
    'CHAR_TEST', 'Este é um VARCHAR de exemplo', 'Este é um texto longo para demonstração do tipo TEXT',
    N'NCHAR_TST', N'Este é um NVARCHAR de exemplo', N'Este é um texto Unicode longo',
    '2024-01-15', '14:30:00', '2024-01-15 14:30:00', '2024-01-15 14:30:00.1234567', '2024-01-15 14:30:00', '2024-01-15 14:30:00.1234567 +00:00',
    1,
    0x48656C6C6F20576F726C64210000, 0x48656C6C6F, 0x48656C6C6F20576F726C6421,
    NEWID(),
    '<exemplo><item>valor</item></exemplo>',
    123,
    geometry::STGeomFromText('POLYGON((0 0,10 0,10 10,0 10,0 0))', 0),
    geography::STGeomFromText('POINT(-122.34900 47.65100)', 4326),
    hierarchyid::Parse('/1/2/3/')
);
SET IDENTITY_INSERT generic_table OFF;