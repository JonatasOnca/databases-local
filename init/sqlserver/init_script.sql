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