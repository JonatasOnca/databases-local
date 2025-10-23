-- Dados de exemplo específicos para PostgreSQL

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

-- Inserir dados na tabela generic_table (exemplo com tipos de dados PostgreSQL)
INSERT INTO generic_table (
    campo_smallint, campo_integer, campo_bigint,
    campo_decimal, campo_numeric, campo_real, campo_double_precision,
    campo_char, campo_varchar, campo_text,
    campo_date, campo_time, campo_timestamp, campo_interval,
    campo_boolean,
    campo_bytea,
    campo_inet, campo_cidr, campo_macaddr, campo_macaddr8,
    campo_uuid,
    campo_json, campo_jsonb,
    campo_int_array, campo_text_array,
    campo_point, campo_lseg, campo_box, campo_circle,
    campo_bit, campo_bit_varying,
    campo_money,
    campo_xml,
    campo_int4range, campo_int8range, campo_numrange, 
    campo_tsrange, campo_tstzrange, campo_daterange
) VALUES (
    32767, 2147483647, 9223372036854775807,
    99999999.99, 12345.67890, 3.14159, 2.718281828459045,
    'CHAR_TEST', 'Este é um VARCHAR de exemplo', 'Este é um texto longo para demonstração do tipo TEXT',
    '2024-01-15', '14:30:00', '2024-01-15 14:30:00', '1 year 2 months 3 days 4 hours 5 minutes 6 seconds',
    TRUE,
    '\x48656c6c6f20576f726c6421',
    '192.168.1.1', '192.168.0.0/24', '08:00:2b:01:02:03', '08:00:2b:01:02:03:04:05',
    gen_random_uuid(),
    '{"nome": "Exemplo", "valor": 123}', '{"nome": "Exemplo", "valor": 123, "ativo": true}',
    ARRAY[1,2,3,4,5], ARRAY['texto1', 'texto2', 'texto3'],
    POINT(10, 20), LSEG(POINT(1,1), POINT(5,5)), BOX(POINT(0,0), POINT(10,10)), CIRCLE(POINT(5,5), 3),
    B'10101010', B'1010101011001100',
    123.45::MONEY,
    '<exemplo><item>valor</item></exemplo>',
    '[1,10)', '[100,200)', '[0.5,10.5)',
    '[2024-01-01 10:00:00, 2024-01-01 18:00:00)', 
    '[2024-01-01 10:00:00+00, 2024-01-01 18:00:00+00)',
    '[2024-01-01, 2024-01-31)'
);