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

-- Tabela 6: Generic Table - Demonstração de tipos de dados PostgreSQL
CREATE TABLE IF NOT EXISTS generic_table (
    id SERIAL PRIMARY KEY,
    -- Tipos numéricos inteiros
    campo_smallint SMALLINT,
    campo_integer INTEGER,
    campo_bigint BIGINT,
    campo_serial SERIAL,
    campo_bigserial BIGSERIAL,
    -- Tipos numéricos decimais
    campo_decimal DECIMAL(10,2),
    campo_numeric NUMERIC(15,5),
    campo_real REAL,
    campo_double_precision DOUBLE PRECISION,
    -- Tipos de texto
    campo_char CHAR(10),
    campo_varchar VARCHAR(255),
    campo_text TEXT,
    campo_name NAME,
    -- Tipos de data e hora
    campo_date DATE,
    campo_time TIME,
    campo_timetz TIMETZ,
    campo_timestamp TIMESTAMP,
    campo_timestamptz TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    campo_interval INTERVAL,
    -- Tipos booleanos
    campo_boolean BOOLEAN,
    -- Tipos binários
    campo_bytea BYTEA,
    -- Tipos de rede
    campo_inet INET,
    campo_cidr CIDR,
    campo_macaddr MACADDR,
    campo_macaddr8 MACADDR8,
    -- Tipos UUID
    campo_uuid UUID,
    -- Tipos JSON
    campo_json JSON,
    campo_jsonb JSONB,
    -- Tipos de array
    campo_int_array INTEGER[],
    campo_text_array TEXT[],
    -- Tipos geométricos
    campo_point POINT,
    campo_line LINE,
    campo_lseg LSEG,
    campo_box BOX,
    campo_path PATH,
    campo_polygon POLYGON,
    campo_circle CIRCLE,
    -- Tipos de bit
    campo_bit BIT(8),
    campo_bit_varying BIT VARYING(16),
    -- Tipos especiais
    campo_money MONEY,
    campo_xml XML,
    -- Tipos de range
    campo_int4range INT4RANGE,
    campo_int8range INT8RANGE,
    campo_numrange NUMRANGE,
    campo_tsrange TSRANGE,
    campo_tstzrange TSTZRANGE,
    campo_daterange DATERANGE,
    -- Tipos de full text search
    campo_tsvector TSVECTOR,
    campo_tsquery TSQUERY,
    -- Tipos internos úteis
    campo_oid OID,
    campo_tid TID,
    campo_xid XID,
    campo_pg_lsn PG_LSN,
    -- Campos de controle
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Comentários da tabela generic_table
COMMENT ON TABLE generic_table IS 'Tabela demonstrativa com todos os tipos de dados suportados pelo PostgreSQL';
COMMENT ON COLUMN generic_table.id IS 'Chave primária auto incremento';
COMMENT ON COLUMN generic_table.campo_smallint IS 'Inteiro pequeno (-32768 a 32767)';
COMMENT ON COLUMN generic_table.campo_integer IS 'Inteiro padrão (-2147483648 a 2147483647)';
COMMENT ON COLUMN generic_table.campo_bigint IS 'Inteiro grande (-9223372036854775808 a 9223372036854775807)';
COMMENT ON COLUMN generic_table.campo_decimal IS 'Decimal fixo com precisão (10 dígitos, 2 decimais)';
COMMENT ON COLUMN generic_table.campo_numeric IS 'Numérico com precisão variável (15 dígitos, 5 decimais)';
COMMENT ON COLUMN generic_table.campo_real IS 'Ponto flutuante de precisão simples';
COMMENT ON COLUMN generic_table.campo_double_precision IS 'Ponto flutuante de precisão dupla';
COMMENT ON COLUMN generic_table.campo_char IS 'String de tamanho fixo (10 caracteres)';
COMMENT ON COLUMN generic_table.campo_varchar IS 'String de tamanho variável (até 255 caracteres)';
COMMENT ON COLUMN generic_table.campo_text IS 'Texto de tamanho ilimitado';
COMMENT ON COLUMN generic_table.campo_date IS 'Data (YYYY-MM-DD)';
COMMENT ON COLUMN generic_table.campo_time IS 'Hora (HH:MM:SS)';
COMMENT ON COLUMN generic_table.campo_timestamp IS 'Data e hora sem timezone';
COMMENT ON COLUMN generic_table.campo_timestamptz IS 'Data e hora com timezone';
COMMENT ON COLUMN generic_table.campo_interval IS 'Intervalo de tempo';
COMMENT ON COLUMN generic_table.campo_boolean IS 'Valor booleano (TRUE/FALSE)';
COMMENT ON COLUMN generic_table.campo_bytea IS 'Dados binários (byte array)';
COMMENT ON COLUMN generic_table.campo_inet IS 'Endereço IP (IPv4 ou IPv6)';
COMMENT ON COLUMN generic_table.campo_cidr IS 'Bloco de rede CIDR';
COMMENT ON COLUMN generic_table.campo_macaddr IS 'Endereço MAC (6 bytes)';
COMMENT ON COLUMN generic_table.campo_macaddr8 IS 'Endereço MAC (8 bytes)';
COMMENT ON COLUMN generic_table.campo_uuid IS 'Identificador único universal';
COMMENT ON COLUMN generic_table.campo_json IS 'Dados JSON (texto)';
COMMENT ON COLUMN generic_table.campo_jsonb IS 'Dados JSON binário (indexável)';
COMMENT ON COLUMN generic_table.campo_int_array IS 'Array de inteiros';
COMMENT ON COLUMN generic_table.campo_text_array IS 'Array de texto';
COMMENT ON COLUMN generic_table.campo_point IS 'Ponto geométrico (x, y)';
COMMENT ON COLUMN generic_table.campo_line IS 'Linha infinita';
COMMENT ON COLUMN generic_table.campo_lseg IS 'Segmento de linha';
COMMENT ON COLUMN generic_table.campo_box IS 'Retângulo';
COMMENT ON COLUMN generic_table.campo_path IS 'Caminho geométrico';
COMMENT ON COLUMN generic_table.campo_polygon IS 'Polígono';
COMMENT ON COLUMN generic_table.campo_circle IS 'Círculo';
COMMENT ON COLUMN generic_table.campo_bit IS 'Sequência de bits de tamanho fixo';
COMMENT ON COLUMN generic_table.campo_bit_varying IS 'Sequência de bits de tamanho variável';
COMMENT ON COLUMN generic_table.campo_money IS 'Valor monetário';
COMMENT ON COLUMN generic_table.campo_xml IS 'Dados XML';
COMMENT ON COLUMN generic_table.campo_int4range IS 'Range de inteiros (int4)';
COMMENT ON COLUMN generic_table.campo_int8range IS 'Range de inteiros (int8)';
COMMENT ON COLUMN generic_table.campo_numrange IS 'Range numérico';
COMMENT ON COLUMN generic_table.campo_tsrange IS 'Range de timestamp';
COMMENT ON COLUMN generic_table.campo_tstzrange IS 'Range de timestamp com timezone';
COMMENT ON COLUMN generic_table.campo_daterange IS 'Range de datas';
COMMENT ON COLUMN generic_table.created_at IS 'Data e hora de criação do registro';
COMMENT ON COLUMN generic_table.updated_at IS 'Data e hora da última atualização';

-- Comentários para os novos campos adicionados
COMMENT ON COLUMN generic_table.campo_serial IS 'Tipo serial (auto incremento de 4 bytes)';
COMMENT ON COLUMN generic_table.campo_bigserial IS 'Tipo big serial (auto incremento de 8 bytes)';
COMMENT ON COLUMN generic_table.campo_name IS 'Tipo name (identificador interno do PostgreSQL)';
COMMENT ON COLUMN generic_table.campo_timetz IS 'Hora com timezone (HH:MM:SS+TZ)';
COMMENT ON COLUMN generic_table.campo_tsvector IS 'Vetor de busca textual (full text search)';
COMMENT ON COLUMN generic_table.campo_tsquery IS 'Query de busca textual (full text search)';
COMMENT ON COLUMN generic_table.campo_oid IS 'Identificador de objeto (OID)';
COMMENT ON COLUMN generic_table.campo_tid IS 'Identificador de tupla (TID)';
COMMENT ON COLUMN generic_table.campo_xid IS 'Identificador de transação (XID)';
COMMENT ON COLUMN generic_table.campo_pg_lsn IS 'Log Sequence Number (PostgreSQL LSN)';

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

CREATE TRIGGER update_generic_table_updated_at 
    BEFORE UPDATE ON generic_table 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();