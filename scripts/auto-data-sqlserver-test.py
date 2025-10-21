#!/usr/bin/env python3
"""
Sistema de Gerenciamento Automático de Dados - Teste SQL Server
===============================================================

Teste específico para SQL Server usando pymssql
"""

import time
import random
import datetime
import logging
from typing import Dict, List, Any
import sys

# Dependências necessárias
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
        logging.FileHandler('/Users/jonatasonca/Desktop/TecOnca/Projetos/databases-local/logs/auto-data-sqlserver-test.log'),
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
        'database': 'master'  # Iniciar com master depois trocar
    }

class DataManager:
    """Gerenciador automático de dados"""
    
    def __init__(self, database_type: str = 'mysql'):
        self.database_type = database_type
        self.connection = None
        
        # Dados para simulação
        self.sample_names = [
            'Ana Costa', 'Bruno Lima', 'Carlos Pereira', 'Diana Silva', 'Eduardo Santos',
            'Fernanda Oliveira', 'Gabriel Ferreira', 'Helena Rodrigues', 'Igor Almeida',
            'Juliana Nascimento'
        ]
        
        self.sample_products = [
            ('Smartphone Samsung', 1200.00), ('iPhone 15', 5000.00), ('Tablet iPad', 3000.00),
            ('Notebook Gamer', 4500.00), ('Headset Bluetooth', 250.00), ('Smartwatch', 800.00)
        ]
        
        self.sample_messages = [
            'Operação automática executada', 'Dados atualizados pelo sistema',
            'Sincronização de dados realizada', 'Sistema operando normalmente'
        ]
    
    def connect(self) -> bool:
        """Estabelece conexão com o banco de dados"""
        try:
            if self.database_type == 'mysql':
                self.connection = pymysql.connect(**DatabaseConfig.MYSQL)
            elif self.database_type == 'postgres':
                self.connection = psycopg2.connect(**DatabaseConfig.POSTGRES)
            elif self.database_type == 'sqlserver':
                # Conectar usando pymssql
                self.connection = pymssql.connect(
                    server=DatabaseConfig.SQLSERVER['server'],
                    port=DatabaseConfig.SQLSERVER['port'],
                    user=DatabaseConfig.SQLSERVER['user'],
                    password=DatabaseConfig.SQLSERVER['password'],
                    database=DatabaseConfig.SQLSERVER['database']
                )
                
                # Criar/usar database testdb
                cursor = self.connection.cursor()
                try:
                    cursor.execute("IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'testdb') CREATE DATABASE testdb")
                    self.connection.commit()
                    cursor.execute("USE testdb")
                    self.connection.commit()
                    logging.info("✅ Database testdb preparado")
                except Exception as e:
                    logging.warning(f"⚠️ Aviso ao preparar database: {e}")
                cursor.close()
            
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
            
            if params:
                cursor.execute(query, params)
            else:
                cursor.execute(query)
            
            result = {
                'success': True,
                'rowcount': cursor.rowcount if hasattr(cursor, 'rowcount') else 0
            }
            
            self.connection.commit()
            cursor.close()
            
            return result
            
        except Exception as e:
            logging.error(f"❌ Erro ao executar query: {e}")
            try:
                self.connection.rollback()
            except:
                pass
            return {'success': False, 'error': str(e)}
    
    def get_random_existing_id(self, table: str, id_column: str = 'id') -> int:
        """Obtém um ID aleatório existente de uma tabela"""
        try:
            cursor = self.connection.cursor()
            
            if self.database_type == 'postgres':
                cursor.execute(f"SELECT {id_column} FROM {table} ORDER BY RANDOM() LIMIT 1")
            elif self.database_type == 'sqlserver':
                cursor.execute(f"SELECT TOP 1 {id_column} FROM {table} ORDER BY NEWID()")
            else:  # MySQL
                cursor.execute(f"SELECT {id_column} FROM {table} ORDER BY RAND() LIMIT 1")
                
            result = cursor.fetchone()
            cursor.close()
            return result[0] if result else None
        except Exception as e:
            logging.error(f"❌ Erro ao buscar ID aleatório: {e}")
            return None
    
    def check_tables_exist(self) -> bool:
        """Verifica se as tabelas existem e as cria se necessário"""
        try:
            cursor = self.connection.cursor()
            
            if self.database_type == 'sqlserver':
                # Verificar se as tabelas existem
                cursor.execute("""
                    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='clientes' AND xtype='U')
                    CREATE TABLE clientes (
                        id INT IDENTITY(1,1) PRIMARY KEY,
                        nome NVARCHAR(100) NOT NULL,
                        email NVARCHAR(100),
                        created_at DATETIME2 DEFAULT GETDATE(),
                        updated_at DATETIME2 DEFAULT GETDATE()
                    )
                """)
                
                cursor.execute("""
                    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='produtos' AND xtype='U')
                    CREATE TABLE produtos (
                        id INT IDENTITY(1,1) PRIMARY KEY,
                        nome NVARCHAR(100) NOT NULL,
                        preco DECIMAL(10,2) NOT NULL,
                        created_at DATETIME2 DEFAULT GETDATE(),
                        updated_at DATETIME2 DEFAULT GETDATE()
                    )
                """)
                
                cursor.execute("""
                    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='logs' AND xtype='U')
                    CREATE TABLE logs (
                        id INT IDENTITY(1,1) PRIMARY KEY,
                        timestamp DATETIME2 DEFAULT GETDATE(),
                        mensagem NVARCHAR(255),
                        created_at DATETIME2 DEFAULT GETDATE(),
                        updated_at DATETIME2 DEFAULT GETDATE()
                    )
                """)
                
                self.connection.commit()
                logging.info("✅ Tabelas verificadas/criadas no SQL Server")
            
            cursor.close()
            return True
            
        except Exception as e:
            logging.error(f"❌ Erro ao verificar/criar tabelas: {e}")
            return False
    
    def insert_cliente(self) -> bool:
        """Insere um novo cliente"""
        nome = random.choice(self.sample_names)
        email = f"{nome.lower().replace(' ', '.')}_{random.randint(1000, 9999)}@email.com"
        
        if self.database_type == 'sqlserver':
            query = "INSERT INTO clientes (nome, email) VALUES (%s, %s)"
        else:
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
        
        variacao = random.uniform(0.9, 1.15)
        query = "UPDATE produtos SET preco = preco * %s WHERE id = %s"
        result = self.execute_query(query, (variacao, produto_id))
        
        if result['success'] and result['rowcount'] > 0:
            logging.info(f"🔄 Produto atualizado: ID {produto_id} (preço ajustado em {(variacao-1)*100:.1f}%)")
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
    
    def execute_operations_cycle(self):
        """Executa um ciclo completo de operações"""
        operations = [
            ('INSERT Cliente', self.insert_cliente),
            ('UPDATE Cliente', self.update_cliente),
            ('INSERT Produto', self.insert_produto),
            ('UPDATE Produto', self.update_produto),
            ('INSERT Log', self.insert_log)
        ]
        
        # Executar 2-3 operações aleatórias por ciclo
        num_operations = random.randint(2, 3)
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
    
    def run_demo(self, duration_seconds: int = 20):
        """Executa uma demonstração por tempo limitado"""
        logging.info(f"🚀 Iniciando demonstração do gerenciamento automático ({self.database_type.upper()})")
        logging.info(f"⏰ Duração: {duration_seconds} segundos")
        
        if self.database_type == 'sqlserver':
            if not self.check_tables_exist():
                logging.error("❌ Falha ao verificar/criar tabelas")
                return
        
        start_time = time.time()
        cycles = 0
        
        while time.time() - start_time < duration_seconds:
            try:
                cycles += 1
                logging.info(f"🔄 Executando ciclo {cycles}")
                self.execute_operations_cycle()
                
                # Aguardar próximo ciclo (máximo 8 segundos)
                wait_time = min(8, duration_seconds - (time.time() - start_time))
                if wait_time > 0:
                    time.sleep(wait_time)
                    
            except Exception as e:
                logging.error(f"❌ Erro no ciclo {cycles}: {e}")
                time.sleep(2)
        
        logging.info(f"🎉 Demonstração concluída! Executados {cycles} ciclos em {duration_seconds} segundos")

def main():
    """Função principal"""
    
    # Verificar argumentos
    database_type = sys.argv[1] if len(sys.argv) > 1 else 'sqlserver'
    duration = int(sys.argv[2]) if len(sys.argv) > 2 else 20
    
    if database_type not in ['mysql', 'postgres', 'sqlserver']:
        print("❌ Tipo de banco inválido. Use: mysql, postgres ou sqlserver")
        sys.exit(1)
    
    print(f"""
🗄️  Sistema de Gerenciamento Automático - TESTE SQL SERVER
=========================================================
🎯 Banco: {database_type.upper()}
⏰ Duração: {duration} segundos
📊 Operações: INSERT e UPDATE automáticos
🔧 Driver: pymssql (alternativa ao pyodbc)
=========================================================
    """)
    
    # Criar e iniciar o gerenciador
    manager = DataManager(database_type)
    
    if manager.connect():
        try:
            manager.run_demo(duration)
        except KeyboardInterrupt:
            print("\n⏹️  Demo interrompida pelo usuário")
        finally:
            manager.disconnect()
    else:
        print("❌ Falha ao conectar ao banco!")
        sys.exit(1)

if __name__ == "__main__":
    main()