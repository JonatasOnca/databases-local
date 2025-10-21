-- O comando CREATE DATABASE não é necessário aqui,
-- pois as imagens Docker criam o DB automaticamente com as variáveis de ambiente.

-- Função para atualizar automaticamente o campo updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Tabela 1: Clientes
CREATE TABLE IF NOT EXISTS clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela 2: Produtos
CREATE TABLE IF NOT EXISTS produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela 3: Pedidos
CREATE TABLE IF NOT EXISTS pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INT,
    data_pedido DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Tabela 4: Itens_Pedido
CREATE TABLE IF NOT EXISTS itens_pedido (
    pedido_id INT,
    produto_id INT,
    quantidade INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (pedido_id, produto_id),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
);

-- Tabela 5: Logs
CREATE TABLE IF NOT EXISTS logs (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    mensagem VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Triggers para atualizar automaticamente o campo updated_at
CREATE TRIGGER update_clientes_updated_at 
    BEFORE UPDATE ON clientes 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_produtos_updated_at 
    BEFORE UPDATE ON produtos 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pedidos_updated_at 
    BEFORE UPDATE ON pedidos 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_itens_pedido_updated_at 
    BEFORE UPDATE ON itens_pedido 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_logs_updated_at 
    BEFORE UPDATE ON logs 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();