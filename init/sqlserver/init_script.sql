-- O comando CREATE DATABASE não é necessário aqui,
-- pois as imagens Docker criam o DB automaticamente com as variáveis de ambiente.

-- Tabela 1: Clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY IDENTITY(1,1),
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- Tabela 2: Produtos
CREATE TABLE produtos (
    id INT PRIMARY KEY IDENTITY(1,1),
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10, 2) NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- Tabela 3: Pedidos
CREATE TABLE pedidos (
    id INT PRIMARY KEY IDENTITY(1,1),
    cliente_id INT,
    data_pedido DATE,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

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

-- Tabela 5: Logs
CREATE TABLE logs (
    id INT PRIMARY KEY IDENTITY(1,1),
    timestamp DATETIME2 DEFAULT GETDATE(),
    mensagem VARCHAR(255),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);
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