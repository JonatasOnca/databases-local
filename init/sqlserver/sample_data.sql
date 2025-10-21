-- Dados de exemplo específicos para SQL Server

-- Garantir que estamos no banco correto
USE testdb;
GO

-- Resetar contadores IDENTITY para começar do 1
DBCC CHECKIDENT('clientes', RESEED, 0);
DBCC CHECKIDENT('produtos', RESEED, 0);
DBCC CHECKIDENT('pedidos', RESEED, 0);
DBCC CHECKIDENT('logs', RESEED, 0);
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