-- Dados de exemplo específicos para MySQL

-- Configurar charset para UTF-8
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- Desabilitar verificação de foreign keys temporariamente
SET FOREIGN_KEY_CHECKS = 0;

-- Inserir clientes
INSERT INTO clientes (nome, email) VALUES 
('João Silva', 'joao@email.com'),
('Maria Santos', 'maria@email.com'),
('Pedro Oliveira', 'pedro@email.com');

-- Inserir produtos
INSERT INTO produtos (nome, preco) VALUES 
('Notebook Dell', 2500.00),
('Mouse Logitech', 150.00),
('Teclado Mecânico', 300.00),
('Monitor 24"', 800.00);

-- Inserir pedidos
INSERT INTO pedidos (cliente_id, data_pedido) VALUES 
(1, '2024-01-15'),
(2, '2024-01-16'),
(1, '2024-01-17');

-- Inserir itens dos pedidos
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade) VALUES 
(1, 1, 1),  -- João comprou 1 notebook
(1, 2, 1),  -- João comprou 1 mouse
(2, 3, 1),  -- Maria comprou 1 teclado
(2, 4, 1),  -- Maria comprou 1 monitor
(3, 2, 2);  -- João comprou 2 mouses

-- Inserir logs
INSERT INTO logs (mensagem) VALUES 
('Sistema inicializado'),
('Dados de exemplo inseridos');

-- Inserir dados na tabela generic_table (exemplo com tipos de dados MySQL)
INSERT INTO generic_table (
    campo_tinyint, campo_tinyint_unsigned, campo_smallint, campo_smallint_unsigned, 
    campo_mediumint, campo_mediumint_unsigned, campo_int, campo_int_unsigned, 
    campo_bigint, campo_bigint_unsigned,
    campo_decimal, campo_float, campo_double,
    campo_char, campo_varchar, campo_text, campo_mediumtext, campo_longtext,
    campo_date, campo_time, campo_datetime, campo_year,
    campo_binary, campo_varbinary, campo_blob,
    campo_boolean, campo_bit,
    campo_enum, campo_set,
    campo_json,
    campo_geometry, campo_point, campo_linestring, campo_polygon
) VALUES (
    127, 255, 32767, 65535, 8388607, 16777215, 2147483647, 4294967295, 9223372036854775807, 18446744073709551615,
    99999999.99, 3.14159, 2.718281828459045,
    'CHAR_TEST', 'Este é um VARCHAR de exemplo', 'Este é um texto longo para demonstração do tipo TEXT',
    'Este é um texto médio para demonstração do tipo MEDIUMTEXT',
    'Este é um texto muito longo para demonstração do tipo LONGTEXT',
    '2024-01-15', '14:30:00', '2024-01-15 14:30:00', 2024,
    UNHEX('48656C6C6F20576F726C64210000'), UNHEX('48656C6C6F'), UNHEX('48656C6C6F20576F726C6421'),
    TRUE, b'10101010',
    'valor1', 'opcao1,opcao3',
    '{"nome": "Exemplo", "valor": 123, "ativo": true}',
    ST_GeomFromText('POLYGON((0 0,10 0,10 10,0 10,0 0))'), ST_GeomFromText('POINT(10 20)'),
    ST_GeomFromText('LINESTRING(0 0,1 1,2 2)'), ST_GeomFromText('POLYGON((0 0,10 0,10 10,0 10,0 0))')
);

-- Reabilitar verificação de foreign keys
SET FOREIGN_KEY_CHECKS = 1;