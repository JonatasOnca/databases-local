-- Dados de exemplo específicos para MySQL

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

-- Reabilitar verificação de foreign keys
SET FOREIGN_KEY_CHECKS = 1;