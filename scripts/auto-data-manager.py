#!/usr/bin/env python3
"""
Sistema de Gerenciamento Automático de Dados
============================================

Este script executa operações automáticas de INSERT e UPDATE nas tabelas do banco de dados
a cada 30 segundos. Suporta MySQL, PostgreSQL e SQL Server.

Autor: Sistema Automático
Data: 2025-10-21
"""

import time
import random
import datetime
import logging
from typing import Dict, List, Any
import os
import sys
import signal
import threading

# Dependências necessárias (instalar com: pip install pymysql psycopg2-binary pymssql)
try:
    import pymysql
    import psycopg2
    import pymssql  # Alternativa mais simples ao pyodbc
except ImportError as e:
    print(f"❌ Erro: Dependência não encontrada: {e}")
    print("📦 Instale as dependências com:")
    print("   pip install pymysql psycopg2-binary pymssql")
    sys.exit(1)

# Configuração de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/Users/jonatasonca/Desktop/TecOnca/Projetos/databases-local/logs/auto-data-manager.log'),
        logging.StreamHandler()
    ]
)

class DatabaseConfig:
    """Configuração de conexão com os bancos de dados"""
    
    MYSQL = {
        'host': 'localhost',
        'port': 3306,
        'user': 'devuser',
        'password': 'DevP@ssw0rd!',
        'database': 'testdb',
        'charset': 'utf8mb4'
    }
    
    POSTGRES = {
        'host': 'localhost',
        'port': 5432,
        'user': 'devuser',
        'password': 'DevP@ssw0rd!',
        'database': 'testdb'
    }
    
    SQLSERVER = {
        'server': 'localhost',
        'port': 1433,
        'user': 'SA',
        'password': 'SuperSecureP@ssword!',
        'database': 'testdb'
    }

class DataManager:
    """Gerenciador automático de dados"""
    
    def __init__(self, database_type: str = 'mysql'):
        self.database_type = database_type
        self.connection = None
        self.running = False
        self.thread = None
        
        # Dados para simulação
        self.sample_names = [
            'Ana Costa', 'Bruno Lima', 'Carlos Pereira', 'Diana Silva', 'Eduardo Santos',
            'Fernanda Oliveira', 'Gabriel Ferreira', 'Helena Rodrigues', 'Igor Almeida',
            'Juliana Nascimento', 'Kevin Barbosa', 'Larissa Cardoso', 'Marcos Vieira',
            'Natália Sousa', 'Otávio Ribeiro', 'Paula Gonçalves', 'Quirino Martins',
            'Raquel Campos', 'Sandro Araújo', 'Tatiane Moreira'
        ]
        
        self.sample_products = [
            ('Smartphone Samsung', 1200.00), ('iPhone 15', 5000.00), ('Tablet iPad', 3000.00),
            ('Notebook Gamer', 4500.00), ('Headset Bluetooth', 250.00), ('Smartwatch', 800.00),
            ('Camera Digital', 1800.00), ('Console PS5', 3500.00), ('Drone DJI', 2200.00),
            ('Home Theater', 1500.00), ('Roteador WiFi 6', 400.00), ('SSD 1TB', 600.00),
            ('Placa de Vídeo', 2800.00), ('Processador Intel', 1600.00), ('Memória RAM 32GB', 900.00)
        ]
        
        self.sample_messages = [
            'Operação automática executada', 'Dados atualizados pelo sistema',
            'Sincronização de dados realizada', 'Manutenção automática executada',
            'Sistema operando normalmente', 'Dados inseridos automaticamente',
            'Atualização de registros concluída', 'Processo automático executado'
        ]
    
    def connect(self) -> bool:
        """Estabelece conexão com o banco de dados"""
        try:
            if self.database_type == 'mysql':
                self.connection = pymysql.connect(**DatabaseConfig.MYSQL)
            elif self.database_type == 'postgres':
                self.connection = psycopg2.connect(**DatabaseConfig.POSTGRES)
            elif self.database_type == 'sqlserver':
                self.connection = pymssql.connect(
                    server=DatabaseConfig.SQLSERVER['server'],
                    port=DatabaseConfig.SQLSERVER['port'],
                    user=DatabaseConfig.SQLSERVER['user'],
                    password=DatabaseConfig.SQLSERVER['password'],
                    database=DatabaseConfig.SQLSERVER['database']
                )
            
            logging.info(f"✅ Conectado ao {self.database_type.upper()}")
            return True
            
        except Exception as e:
            logging.error(f"❌ Erro ao conectar com {self.database_type}: {e}")
            return False
    
    def disconnect(self):
        """Fecha a conexão com o banco de dados"""
        if self.connection:
            self.connection.close()
            logging.info(f"🔌 Desconectado do {self.database_type.upper()}")
    
    def execute_query(self, query: str, params: tuple = None) -> Dict[str, Any]:
        """Executa uma query no banco de dados"""
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, params or ())
            
            result = {
                'success': True,
                'rowcount': cursor.rowcount,
                'lastrowid': None
            }
            
            # Para MySQL, capturar o último ID inserido
            if self.database_type == 'mysql' and 'INSERT' in query.upper():
                result['lastrowid'] = cursor.lastrowid
            
            self.connection.commit()
            cursor.close()
            
            return result
            
        except Exception as e:
            logging.error(f"❌ Erro ao executar query: {e}")
            self.connection.rollback()
            return {'success': False, 'error': str(e)}
    
    def get_random_existing_id(self, table: str, id_column: str = 'id') -> int:
        """Obtém um ID aleatório existente de uma tabela"""
        try:
            cursor = self.connection.cursor()
            if self.database_type == 'postgres':
                query = f"SELECT {id_column} FROM {table} ORDER BY RANDOM() LIMIT 1"
            elif self.database_type == 'sqlserver':
                query = f"SELECT TOP 1 {id_column} FROM {table} ORDER BY NEWID()"
            else:  # mysql
                query = f"SELECT {id_column} FROM {table} ORDER BY RAND() LIMIT 1"
            
            cursor.execute(query)
            result = cursor.fetchone()
            cursor.close()
            return result[0] if result else None
        except Exception as e:
            logging.error(f"❌ Erro ao obter ID aleatório da tabela {table}: {e}")
            return None
    
    def insert_cliente(self) -> bool:
        """Insere um novo cliente"""
        nome = random.choice(self.sample_names)
        email = f"{nome.lower().replace(' ', '.')}_{random.randint(1000, 9999)}@email.com"
        
        query = "INSERT INTO clientes (nome, email) VALUES (%s, %s)"
        result = self.execute_query(query, (nome, email))
        
        if result['success']:
            logging.info(f"➕ Cliente inserido: {nome} ({email})")
            return True
        return False
    
    def update_cliente(self) -> bool:
        """Atualiza um cliente existente"""
        cliente_id = self.get_random_existing_id('clientes')
        if not cliente_id:
            return False
        
        novo_nome = random.choice(self.sample_names) + " (Atualizado)"
        
        query = "UPDATE clientes SET nome = %s WHERE id = %s"
        result = self.execute_query(query, (novo_nome, cliente_id))
        
        if result['success'] and result['rowcount'] > 0:
            logging.info(f"🔄 Cliente atualizado: ID {cliente_id} -> {novo_nome}")
            return True
        return False
    
    def insert_produto(self) -> bool:
        """Insere um novo produto"""
        nome, preco_base = random.choice(self.sample_products)
        # Adiciona variação no preço
        preco = round(preco_base * random.uniform(0.8, 1.2), 2)
        
        query = "INSERT INTO produtos (nome, preco) VALUES (%s, %s)"
        result = self.execute_query(query, (nome, preco))
        
        if result['success']:
            logging.info(f"➕ Produto inserido: {nome} (R$ {preco})")
            return True
        return False
    
    def update_produto(self) -> bool:
        """Atualiza um produto existente"""
        produto_id = self.get_random_existing_id('produtos')
        if not produto_id:
            return False
        
        # Atualiza o preço com uma variação de -10% a +15%
        variacao = random.uniform(0.9, 1.15)
        
        # Para diferentes bancos, a sintaxe pode variar
        if self.database_type == 'mysql':
            query = "UPDATE produtos SET preco = preco * %s WHERE id = %s"
        else:
            query = "UPDATE produtos SET preco = preco * %s WHERE id = %s"
        
        result = self.execute_query(query, (variacao, produto_id))
        
        if result['success'] and result['rowcount'] > 0:
            logging.info(f"🔄 Produto atualizado: ID {produto_id} (preço ajustado em {(variacao-1)*100:.1f}%)")
            return True
        return False
    
    def insert_pedido(self) -> bool:
        """Insere um novo pedido"""
        cliente_id = self.get_random_existing_id('clientes')
        if not cliente_id:
            return False
        
        data_pedido = datetime.date.today() - datetime.timedelta(days=random.randint(0, 30))
        
        query = "INSERT INTO pedidos (cliente_id, data_pedido) VALUES (%s, %s)"
        result = self.execute_query(query, (cliente_id, data_pedido))
        
        if result['success']:
            pedido_id = result.get('lastrowid')
            logging.info(f"➕ Pedido inserido: ID {pedido_id}, Cliente {cliente_id}")
            
            # Inserir itens do pedido
            self.insert_itens_pedido(pedido_id or self.get_random_existing_id('pedidos'))
            return True
        return False
    
    def insert_itens_pedido(self, pedido_id: int) -> bool:
        """Insere itens para um pedido"""
        if not pedido_id:
            return False
        
        # Inserir 1-3 itens aleatórios
        num_itens = random.randint(1, 3)
        
        for _ in range(num_itens):
            produto_id = self.get_random_existing_id('produtos')
            if produto_id:
                quantidade = random.randint(1, 5)
                
                # Verificar se o item já existe (evitar duplicatas na chave primária composta)
                cursor = self.connection.cursor()
                cursor.execute("SELECT 1 FROM itens_pedido WHERE pedido_id = %s AND produto_id = %s", (pedido_id, produto_id))
                exists = cursor.fetchone()
                cursor.close()
                
                if not exists:
                    query = "INSERT INTO itens_pedido (pedido_id, produto_id, quantidade) VALUES (%s, %s, %s)"
                    result = self.execute_query(query, (pedido_id, produto_id, quantidade))
                    
                    if result['success']:
                        logging.info(f"➕ Item inserido: Pedido {pedido_id}, Produto {produto_id}, Qtd {quantidade}")
        
        return True
    
    def update_pedido(self) -> bool:
        """Atualiza a data de um pedido existente"""
        pedido_id = self.get_random_existing_id('pedidos')
        if not pedido_id:
            return False
        
        nova_data = datetime.date.today() - datetime.timedelta(days=random.randint(0, 60))
        
        query = "UPDATE pedidos SET data_pedido = %s WHERE id = %s"
        result = self.execute_query(query, (nova_data, pedido_id))
        
        if result['success'] and result['rowcount'] > 0:
            logging.info(f"🔄 Pedido atualizado: ID {pedido_id} -> nova data: {nova_data}")
            return True
        return False
    
    def insert_log(self) -> bool:
        """Insere uma entrada no log"""
        mensagem = random.choice(self.sample_messages)
        
        query = "INSERT INTO logs (mensagem) VALUES (%s)"
        result = self.execute_query(query, (mensagem,))
        
        if result['success']:
            logging.info(f"📝 Log inserido: {mensagem}")
            return True
        return False
    
    def update_log(self) -> bool:
        """Atualiza uma entrada de log existente"""
        log_id = self.get_random_existing_id('logs')
        if not log_id:
            return False
        
        nova_mensagem = f"{random.choice(self.sample_messages)} [ATUALIZADO]"
        
        query = "UPDATE logs SET mensagem = %s WHERE id = %s"
        result = self.execute_query(query, (nova_mensagem, log_id))
        
        if result['success'] and result['rowcount'] > 0:
            logging.info(f"🔄 Log atualizado: ID {log_id}")
            return True
        return False
    
    def execute_operations_cycle(self):
        """Executa um ciclo completo de operações"""
        operations = [
            ('INSERT Cliente', self.insert_cliente),
            ('UPDATE Cliente', self.update_cliente),
            ('INSERT Produto', self.insert_produto),
            ('UPDATE Produto', self.update_produto),
            ('INSERT Pedido', self.insert_pedido),
            ('UPDATE Pedido', self.update_pedido),
            ('INSERT Log', self.insert_log),
            ('UPDATE Log', self.update_log)
        ]
        
        # Executar 2-4 operações aleatórias por ciclo
        num_operations = random.randint(2, 4)
        selected_operations = random.sample(operations, num_operations)
        
        success_count = 0
        for operation_name, operation_func in selected_operations:
            try:
                if operation_func():
                    success_count += 1
                time.sleep(1)  # Pequena pausa entre operações
            except Exception as e:
                logging.error(f"❌ Erro na operação {operation_name}: {e}")
        
        logging.info(f"✅ Ciclo concluído: {success_count}/{len(selected_operations)} operações executadas com sucesso")
    
    def run_continuous(self):
        """Executa o gerenciador de forma contínua"""
        logging.info(f"🚀 Iniciando gerenciamento automático de dados ({self.database_type.upper()})")
        
        while self.running:
            try:
                self.execute_operations_cycle()
                
                # Aguardar 30 segundos
                for i in range(30):
                    if not self.running:
                        break
                    time.sleep(1)
                    
            except Exception as e:
                logging.error(f"❌ Erro no ciclo principal: {e}")
                time.sleep(5)  # Pausa menor em caso de erro
    
    def start(self):
        """Inicia o gerenciador em thread separada"""
        if not self.connect():
            return False
        
        self.running = True
        self.thread = threading.Thread(target=self.run_continuous)
        self.thread.daemon = True
        self.thread.start()
        
        logging.info("✅ Gerenciador automático iniciado!")
        return True
    
    def stop(self):
        """Para o gerenciador"""
        self.running = False
        if self.thread:
            self.thread.join(timeout=5)
        self.disconnect()
        logging.info("⏹️  Gerenciador automático parado!")

def signal_handler(signum, frame):
    """Handler para sinais do sistema (Ctrl+C)"""
    print("\n⏹️  Parando o gerenciador automático...")
    global manager
    if 'manager' in globals():
        manager.stop()
    sys.exit(0)

def main():
    """Função principal"""
    global manager
    
    # Configurar handler para Ctrl+C
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Verificar argumentos
    database_type = sys.argv[1] if len(sys.argv) > 1 else 'mysql'
    
    if database_type not in ['mysql', 'postgres', 'sqlserver']:
        print("❌ Tipo de banco inválido. Use: mysql, postgres ou sqlserver")
        sys.exit(1)
    
    print(f"""
🗄️  Sistema de Gerenciamento Automático de Dados
===============================================
🎯 Banco: {database_type.upper()}
⏰ Intervalo: 30 segundos
📊 Operações: INSERT e UPDATE automáticos
🔄 Pressione Ctrl+C para parar
===============================================
    """)
    
    # Criar e iniciar o gerenciador
    manager = DataManager(database_type)
    
    if manager.start():
        try:
            # Manter o programa rodando
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            pass
    else:
        print("❌ Falha ao iniciar o gerenciador!")
        sys.exit(1)

if __name__ == "__main__":
    main()