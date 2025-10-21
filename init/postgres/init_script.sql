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

-- Comentários da tabela clientes
COMMENT ON TABLE clientes IS 'Tabela que armazena informações dos clientes';
COMMENT ON COLUMN clientes.id IS 'Identificador único do cliente';
COMMENT ON COLUMN clientes.nome IS 'Nome completo do cliente';
COMMENT ON COLUMN clientes.email IS 'Endereço de email único do cliente';
COMMENT ON COLUMN clientes.created_at IS 'Data e hora de criação do registro';
COMMENT ON COLUMN clientes.updated_at IS 'Data e hora da última atualização';

-- Tabela 2: Produtos
CREATE TABLE IF NOT EXISTS produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Comentários da tabela produtos
COMMENT ON TABLE produtos IS 'Tabela que armazena informações dos produtos';
COMMENT ON COLUMN produtos.id IS 'Identificador único do produto';
COMMENT ON COLUMN produtos.nome IS 'Nome do produto';
COMMENT ON COLUMN produtos.preco IS 'Preço do produto em decimal (10,2)';
COMMENT ON COLUMN produtos.created_at IS 'Data e hora de criação do registro';
COMMENT ON COLUMN produtos.updated_at IS 'Data e hora da última atualização';

-- Tabela 3: Pedidos
CREATE TABLE IF NOT EXISTS pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INT,
    data_pedido DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Comentários da tabela pedidos
COMMENT ON TABLE pedidos IS 'Tabela que armazena informações dos pedidos';
COMMENT ON COLUMN pedidos.id IS 'Identificador único do pedido';
COMMENT ON COLUMN pedidos.cliente_id IS 'Referência ao cliente que fez o pedido';
COMMENT ON COLUMN pedidos.data_pedido IS 'Data do pedido';
COMMENT ON COLUMN pedidos.created_at IS 'Data e hora de criação do registro';
COMMENT ON COLUMN pedidos.updated_at IS 'Data e hora da última atualização';

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

-- Comentários da tabela itens_pedido
COMMENT ON TABLE itens_pedido IS 'Tabela que armazena os itens de cada pedido';
COMMENT ON COLUMN itens_pedido.pedido_id IS 'Referência ao pedido';
COMMENT ON COLUMN itens_pedido.produto_id IS 'Referência ao produto';
COMMENT ON COLUMN itens_pedido.quantidade IS 'Quantidade do produto no pedido';
COMMENT ON COLUMN itens_pedido.created_at IS 'Data e hora de criação do registro';
COMMENT ON COLUMN itens_pedido.updated_at IS 'Data e hora da última atualização';

-- Tabela 5: Logs
CREATE TABLE IF NOT EXISTS logs (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    mensagem VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Comentários da tabela logs
COMMENT ON TABLE logs IS 'Tabela que armazena logs do sistema';
COMMENT ON COLUMN logs.id IS 'Identificador único do log';
COMMENT ON COLUMN logs.timestamp IS 'Data e hora do evento de log';
COMMENT ON COLUMN logs.mensagem IS 'Mensagem do log';
COMMENT ON COLUMN logs.created_at IS 'Data e hora de criação do registro';
COMMENT ON COLUMN logs.updated_at IS 'Data e hora da última atualização';

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