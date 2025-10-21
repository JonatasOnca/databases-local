-- O comando CREATE DATABASE não é necessário aqui,
-- pois as imagens Docker criam o DB automaticamente com as variáveis de ambiente.

-- Tabela 1: Clientes
CREATE TABLE IF NOT EXISTS clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabela 2: Produtos
CREATE TABLE IF NOT EXISTS produtos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabela 3: Pedidos
CREATE TABLE IF NOT EXISTS pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    data_pedido DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Tabela 4: Itens_Pedido
CREATE TABLE IF NOT EXISTS itens_pedido (
    pedido_id INT,
    produto_id INT,
    quantidade INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (pedido_id, produto_id),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
);

-- Tabela 5: Logs
CREATE TABLE IF NOT EXISTS logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    mensagem VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);