-- O comando CREATE DATABASE não é necessário aqui,
-- pois as imagens Docker criam o DB automaticamente com as variáveis de ambiente.

-- Tabela 1: Clientes
CREATE TABLE IF NOT EXISTS clientes (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificador único do cliente',
    nome VARCHAR(100) NOT NULL COMMENT 'Nome completo do cliente',
    email VARCHAR(100) UNIQUE COMMENT 'Endereço de email único do cliente',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora de criação do registro',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data e hora da última atualização'
) COMMENT='Tabela que armazena informações dos clientes';

-- Tabela 2: Produtos
CREATE TABLE IF NOT EXISTS produtos (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificador único do produto',
    nome VARCHAR(100) NOT NULL COMMENT 'Nome do produto',
    preco DECIMAL(10, 2) NOT NULL COMMENT 'Preço do produto em decimal (10,2)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora de criação do registro',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data e hora da última atualização'
) COMMENT='Tabela que armazena informações dos produtos';

-- Tabela 3: Pedidos
CREATE TABLE IF NOT EXISTS pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificador único do pedido',
    cliente_id INT COMMENT 'Referência ao cliente que fez o pedido',
    data_pedido DATE COMMENT 'Data do pedido',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora de criação do registro',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data e hora da última atualização',
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
) COMMENT='Tabela que armazena informações dos pedidos';

-- Tabela 4: Itens_Pedido
CREATE TABLE IF NOT EXISTS itens_pedido (
    pedido_id INT COMMENT 'Referência ao pedido',
    produto_id INT COMMENT 'Referência ao produto',
    quantidade INT COMMENT 'Quantidade do produto no pedido',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora de criação do registro',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data e hora da última atualização',
    PRIMARY KEY (pedido_id, produto_id),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
) COMMENT='Tabela que armazena os itens de cada pedido';

-- Tabela 5: Logs
CREATE TABLE IF NOT EXISTS logs (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificador único do log',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora do evento de log',
    mensagem VARCHAR(255) COMMENT 'Mensagem do log',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora de criação do registro',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data e hora da última atualização'
) COMMENT='Tabela que armazena logs do sistema';