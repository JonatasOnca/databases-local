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

-- Inserir dados na tabela generic_table (exemplo com TODOS os tipos de dados PostgreSQL)
INSERT INTO generic_table (
    -- Tipos numéricos inteiros
    campo_smallint, campo_integer, campo_bigint,
    -- Tipos numéricos decimais  
    campo_decimal, campo_numeric, campo_real, campo_double_precision,
    -- Tipos de texto
    campo_char, campo_varchar, campo_text, campo_name,
    -- Tipos de data e hora
    campo_date, campo_time, campo_timetz, campo_timestamp, campo_timestamptz, campo_interval,
    -- Tipos booleanos
    campo_boolean,
    -- Tipos binários
    campo_bytea,
    -- Tipos de rede
    campo_inet, campo_cidr, campo_macaddr, campo_macaddr8,
    -- Tipos UUID
    campo_uuid,
    -- Tipos JSON
    campo_json, campo_jsonb,
    -- Tipos de array
    campo_int_array, campo_text_array,
    -- Tipos geométricos
    campo_point, campo_line, campo_lseg, campo_box, campo_path, campo_polygon, campo_circle,
    -- Tipos de bit
    campo_bit, campo_bit_varying,
    -- Tipos especiais
    campo_money, campo_xml,
    -- Tipos de range
    campo_int4range, campo_int8range, campo_numrange, 
    campo_tsrange, campo_tstzrange, campo_daterange,
    -- Tipos de full text search
    campo_tsvector, campo_tsquery,
    -- Tipos internos úteis
    campo_oid, campo_tid, campo_xid, campo_pg_lsn
) VALUES (
    -- Tipos numéricos inteiros
    32767, 2147483647, 9223372036854775807,
    -- Tipos numéricos decimais
    99999999.99, 12345.67890, 3.14159, 2.718281828459045,
    -- Tipos de texto
    'CHAR_TEST', 'Este é um VARCHAR de exemplo', 'Este é um texto longo para demonstração do tipo TEXT', 'exemplo_name',
    -- Tipos de data e hora
    '2024-01-15', '14:30:00', '14:30:00+00', '2024-01-15 14:30:00', '2024-01-15 14:30:00+00', '1 year 2 months 3 days 4 hours 5 minutes 6 seconds',
    -- Tipos booleanos
    TRUE,
    -- Tipos binários
    '\x48656c6c6f20576f726c6421',
    -- Tipos de rede
    '192.168.1.1', '192.168.0.0/24', '08:00:2b:01:02:03', '08:00:2b:01:02:03:04:05',
    -- Tipos UUID
    gen_random_uuid(),
    -- Tipos JSON
    '{"nome": "Exemplo PostgreSQL", "valor": 123}', '{"nome": "Exemplo", "valor": 123, "ativo": true, "tipos": ["texto", "numero", "booleano"]}',
    -- Tipos de array
    ARRAY[1,2,3,4,5], ARRAY['texto1', 'texto2', 'texto3'],
    -- Tipos geométricos
    POINT(10, 20), LINE(POINT(0,0), POINT(1,1)), LSEG(POINT(1,1), POINT(5,5)), BOX(POINT(0,0), POINT(10,10)), 
    PATH(POINT(0,0), POINT(1,1), POINT(2,0)), POLYGON(POINT(0,0), POINT(10,0), POINT(10,10), POINT(0,10)), CIRCLE(POINT(5,5), 3),
    -- Tipos de bit
    B'10101010', B'1010101011001100',
    -- Tipos especiais
    123.45::MONEY, '<exemplo><item>valor</item><lista><item>item1</item><item>item2</item></lista></exemplo>',
    -- Tipos de range
    '[1,10)', '[100,200)', '[0.5,10.5)',
    '[2024-01-01 10:00:00, 2024-01-01 18:00:00)', 
    '[2024-01-01 10:00:00+00, 2024-01-01 18:00:00+00)',
    '[2024-01-01, 2024-01-31)',
    -- Tipos de full text search
    to_tsvector('exemplo de texto para busca'), to_tsquery('exemplo & texto'),
    -- Tipos internos úteis (valores de exemplo - alguns podem precisar de ajuste no ambiente real)
    123456::OID, '(0,1)'::TID, 12345::XID, '0/123456'::PG_LSN
);