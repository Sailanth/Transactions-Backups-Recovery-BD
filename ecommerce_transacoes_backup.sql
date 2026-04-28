-- ============================================================
-- DESAFIO E-COMMERCE — TRANSAÇÕES, PROCEDURES E BACKUP
-- Formação SQL Database Specialist | DIO
-- ============================================================
-- Parte 1: Transações manuais (SET autocommit = 0)
-- Parte 2: Transação dentro de Procedure com tratamento de erro
-- Parte 3: Backup e Recovery com mysqldump
-- ============================================================

DROP DATABASE IF EXISTS ecommerce;
CREATE DATABASE ecommerce
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE ecommerce;

-- ============================================================
-- BLOCO 1 — SCHEMA (DDL)
-- ============================================================

CREATE TABLE clients (
    idClient  INT          NOT NULL AUTO_INCREMENT,
    Fname     VARCHAR(10)  NOT NULL,
    Minit     CHAR(3),
    Lname     VARCHAR(20)  NOT NULL,
    CPF       CHAR(11)     NOT NULL,
    Address   VARCHAR(255),
    PRIMARY KEY (idClient),
    CONSTRAINT unique_cpf_client UNIQUE (CPF)
);

CREATE TABLE product (
    idProduct          INT          NOT NULL AUTO_INCREMENT,
    Pname              VARCHAR(255) NOT NULL,
    classification_kids BOOLEAN     DEFAULT FALSE,
    category           ENUM('Eletronico','Vestimenta','Brinquedos','Alimentos','Moveis') NOT NULL,
    avaliacao          FLOAT        DEFAULT 0,
    size               VARCHAR(10),
    PRIMARY KEY (idProduct)
);

CREATE TABLE payments (
    idClient     INT  NOT NULL,
    idPayment    INT  NOT NULL,
    typePayment  ENUM('Boleto','Cartao','Dois cartoes') NOT NULL,
    limitAvailable FLOAT,
    PRIMARY KEY (idClient, idPayment)
);

CREATE TABLE orders (
    idOrder           INT          NOT NULL AUTO_INCREMENT,
    idOrderClient     INT          NOT NULL,
    orderStatus       ENUM('Cancelado','Confirmado','Em processamento') DEFAULT 'Em processamento',
    orderDescription  VARCHAR(255),
    sendValue         FLOAT        DEFAULT 10,
    paymentCash       BOOLEAN      DEFAULT FALSE,
    PRIMARY KEY (idOrder),
    CONSTRAINT fk_orders_client
        FOREIGN KEY (idOrderClient) REFERENCES clients(idClient)
        ON UPDATE CASCADE
);

CREATE TABLE productStorage (
    idProdStorage   INT          NOT NULL AUTO_INCREMENT,
    storageLocation VARCHAR(255) NOT NULL,
    quantity        INT          DEFAULT 0,
    PRIMARY KEY (idProdStorage)
);

CREATE TABLE supplier (
    idSupplier  INT          NOT NULL AUTO_INCREMENT,
    SocialName  VARCHAR(255) NOT NULL,
    CNPJ        CHAR(15)     NOT NULL,
    contact     CHAR(11)     NOT NULL,
    PRIMARY KEY (idSupplier),
    CONSTRAINT unique_supplier UNIQUE (CNPJ)
);

CREATE TABLE seller (
    idSeller    INT          NOT NULL AUTO_INCREMENT,
    SocialName  VARCHAR(255) NOT NULL,
    AbstName    VARCHAR(255),
    CNPJ        CHAR(15),
    CPF         CHAR(9),
    location    VARCHAR(255),
    contact     CHAR(11)     NOT NULL,
    PRIMARY KEY (idSeller),
    CONSTRAINT unique_cnpj_seller UNIQUE (CNPJ),
    CONSTRAINT unique_cpf_seller  UNIQUE (CPF)
);

-- Tabelas associativas M:N
CREATE TABLE productSeller (
    idPseller   INT NOT NULL,
    idPproduct  INT NOT NULL,
    prodQuantity INT DEFAULT 1,
    PRIMARY KEY (idPseller, idPproduct),
    CONSTRAINT fk_ps_seller  FOREIGN KEY (idPseller)  REFERENCES seller(idSeller),
    CONSTRAINT fk_ps_product FOREIGN KEY (idPproduct) REFERENCES product(idProduct)
);

CREATE TABLE productOrder (
    idPOproduct INT NOT NULL,
    idPOorder   INT NOT NULL,
    poQuantity  INT  DEFAULT 1,
    poStatus    ENUM('Disponivel','Sem estoque') DEFAULT 'Disponivel',
    PRIMARY KEY (idPOproduct, idPOorder),
    CONSTRAINT fk_po_product FOREIGN KEY (idPOproduct) REFERENCES product(idProduct),
    CONSTRAINT fk_po_order   FOREIGN KEY (idPOorder)   REFERENCES orders(idOrder)
);

CREATE TABLE storageLocation (
    idLproduct  INT          NOT NULL,
    idLstorage  INT          NOT NULL,
    location    VARCHAR(255) NOT NULL,
    PRIMARY KEY (idLproduct, idLstorage),
    CONSTRAINT fk_sl_product FOREIGN KEY (idLproduct) REFERENCES product(idProduct),
    CONSTRAINT fk_sl_storage FOREIGN KEY (idLstorage) REFERENCES productStorage(idProdStorage)
);

CREATE TABLE productSupplier (
    idPsSupplier INT NOT NULL,
    idPsProduct  INT NOT NULL,
    quantity     INT NOT NULL,
    PRIMARY KEY (idPsSupplier, idPsProduct),
    CONSTRAINT fk_pss_supplier FOREIGN KEY (idPsSupplier) REFERENCES supplier(idSupplier),
    CONSTRAINT fk_pss_product  FOREIGN KEY (idPsProduct)  REFERENCES product(idProduct)
);

-- Tabela de log de auditoria de pedidos (usada nas transações)
CREATE TABLE order_audit_log (
    idLog         INT          NOT NULL AUTO_INCREMENT,
    idOrder       INT,
    acao          VARCHAR(50)  NOT NULL,
    status_antes  VARCHAR(50),
    status_depois VARCHAR(50),
    usuario       VARCHAR(50)  DEFAULT 'sistema',
    executado_em  DATETIME     DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (idLog)
);

-- ============================================================
-- BLOCO 2 — DADOS DE TESTE (DML)
-- ============================================================

INSERT INTO clients (Fname, Minit, Lname, CPF, Address) VALUES
    ('Maria',   'S',  'Silva',    '11111111101', 'Rua das Flores, 10 - SP'),
    ('Joao',    'P',  'Santos',   '22222222202', 'Av Brasil, 200 - RJ'),
    ('Carla',   'M',  'Oliveira', '33333333303', 'Rua XV, 45 - PR'),
    ('Pedro',   'A',  'Costa',    '44444444404', 'Al Paulista, 1000 - SP'),
    ('Fernanda','R',  'Lima',     '55555555505', 'Rua Goias, 77 - MG');

INSERT INTO product (Pname, classification_kids, category, avaliacao, size) VALUES
    ('Smartphone Galaxy A54',  FALSE, 'Eletronico',  4.5, NULL),
    ('Notebook Dell 15"',      FALSE, 'Eletronico',  4.8, NULL),
    ('Camiseta Polo',          FALSE, 'Vestimenta',  4.2, 'M'),
    ('LEGO Cidade 500 pcs',    TRUE,  'Brinquedos',  4.9, NULL),
    ('Arroz Integral 5kg',     FALSE, 'Alimentos',   4.3, NULL),
    ('Mesa de Escritorio',     FALSE, 'Moveis',      4.1, 'G');

INSERT INTO productStorage (storageLocation, quantity) VALUES
    ('Sao Paulo - Galpao A',  150),
    ('Rio de Janeiro - CD',    80),
    ('Curitiba - Deposito 1', 200);

INSERT INTO supplier (SocialName, CNPJ, contact) VALUES
    ('Tech Imports Ltda',    '11111111000101', '11999990001'),
    ('Moda Fashion SA',      '22222222000102', '11999990002'),
    ('Alimentos Sul Ltda',   '33333333000103', '41999990003');

INSERT INTO seller (SocialName, AbstName, CNPJ, CPF, location, contact) VALUES
    ('Eletro Shop',   'EleShop', '44444444000104', NULL,        'SP', '11988880001'),
    ('Moda Kids ME',  NULL,      NULL,             '123456789', 'RJ', '21988880002');

INSERT INTO orders (idOrderClient, orderStatus, orderDescription, sendValue, paymentCash) VALUES
    (1, 'Confirmado',       'Pedido de eletronicos',   15.00, FALSE),
    (2, 'Em processamento', 'Pedido de roupas',         10.00, TRUE),
    (3, 'Confirmado',       'Pedido de brinquedos',    12.00, FALSE),
    (4, 'Cancelado',        'Pedido cancelado cliente', 10.00, FALSE),
    (5, 'Em processamento', 'Pedido de alimentos',      8.00, TRUE);

INSERT INTO payments (idClient, idPayment, typePayment, limitAvailable) VALUES
    (1, 1, 'Cartao',      5000.00),
    (2, 1, 'Boleto',         NULL),
    (3, 1, 'Dois cartoes', 3000.00),
    (4, 1, 'Cartao',      1500.00),
    (5, 1, 'Boleto',         NULL);

INSERT INTO productOrder (idPOproduct, idPOorder, poQuantity, poStatus) VALUES
    (1, 1, 1, 'Disponivel'),
    (2, 1, 1, 'Disponivel'),
    (3, 2, 2, 'Disponivel'),
    (4, 3, 1, 'Disponivel'),
    (5, 5, 3, 'Disponivel');

INSERT INTO productSupplier (idPsSupplier, idPsProduct, quantity) VALUES
    (1, 1, 100), (1, 2, 50),
    (2, 3, 200),
    (3, 5, 500);

INSERT INTO productSeller (idPseller, idPproduct, prodQuantity) VALUES
    (1, 1, 30), (1, 2, 15),
    (2, 3, 40), (2, 4, 25);

INSERT INTO storageLocation (idLproduct, idLstorage, location) VALUES
    (1, 1, 'Prateleira A1'), (2, 1, 'Prateleira A2'),
    (3, 2, 'Prateleira B1'), (4, 3, 'Prateleira C3'),
    (5, 3, 'Prateleira C5');


-- ============================================================
-- PARTE 1 — TRANSAÇÕES MANUAIS
-- CODE 1: Desabilitar autocommit e executar transação simples
-- CODE 2: Transação com SELECT + múltiplos DML
-- ============================================================

-- ------------------------------------------------------------
-- CODE 1 — Desabilitar autocommit + transação básica
-- Objetivo: confirmar um pedido em processamento e registrar
--           a ação no log de auditoria.
-- ------------------------------------------------------------
SET autocommit = 0;                -- desabilita confirmação automática

START TRANSACTION;

    -- Consulta o estado atual antes de modificar
    SELECT idOrder, orderStatus
    FROM   orders
    WHERE  idOrder = 2;

    -- Atualiza o status do pedido
    UPDATE orders
    SET    orderStatus = 'Confirmado'
    WHERE  idOrder     = 2
      AND  orderStatus = 'Em processamento';

    -- Registra a ação no log de auditoria
    INSERT INTO order_audit_log (idOrder, acao, status_antes, status_depois)
    VALUES (2, 'CONFIRMAR_PEDIDO', 'Em processamento', 'Confirmado');

COMMIT;  -- persiste todas as alterações acima

-- Verificação após commit
SELECT 'CODE 1 — Estado pós-commit:' AS info;
SELECT idOrder, orderStatus FROM orders WHERE idOrder = 2;
SELECT * FROM order_audit_log;


-- ------------------------------------------------------------
-- CODE 2 — Transação com múltiplos DML e ROLLBACK parcial
-- Objetivo: processar um novo pedido completo — inserir cliente,
--           pedido e itens — com SAVEPOINT antes dos itens.
--           Se algum item falhar, desfaz apenas os itens (não o
--           cadastro do cliente e do pedido).
-- ------------------------------------------------------------
SET autocommit = 0;

START TRANSACTION;

    -- Passo 1: novo cliente
    INSERT INTO clients (Fname, Minit, Lname, CPF, Address)
    VALUES ('Lucas', 'T', 'Ferreira', '66666666606', 'Rua Nova, 99 - SP');

    -- Captura o id gerado
    SET @novo_cliente = LAST_INSERT_ID();

    -- Passo 2: novo pedido
    INSERT INTO orders (idOrderClient, orderStatus, orderDescription, sendValue, paymentCash)
    VALUES (@novo_cliente, 'Em processamento', 'Pedido de teste CODE 2', 12.00, FALSE);

    SET @novo_pedido = LAST_INSERT_ID();

    -- SAVEPOINT antes dos itens do pedido
    SAVEPOINT sp_antes_itens;

    -- Passo 3: itens do pedido
    INSERT INTO productOrder (idPOproduct, idPOorder, poQuantity, poStatus)
    VALUES (6, @novo_pedido, 1, 'Disponivel');   -- Mesa de Escritório

    -- Log da operação
    INSERT INTO order_audit_log (idOrder, acao, status_antes, status_depois)
    VALUES (@novo_pedido, 'NOVO_PEDIDO_CRIADO', NULL, 'Em processamento');

COMMIT;

-- Verificação após CODE 2
SELECT 'CODE 2 — Novo cliente e pedido inseridos:' AS info;
SELECT c.Fname, c.Lname, o.idOrder, o.orderStatus, o.orderDescription
FROM   clients c
JOIN   orders  o ON o.idOrderClient = c.idClient
WHERE  c.CPF = '66666666606';


-- ============================================================
-- PARTE 2 — TRANSAÇÃO COM PROCEDURE E TRATAMENTO DE ERRO
-- CODE 3: Procedure com ROLLBACK total ou parcial (SAVEPOINT)
-- ============================================================

DELIMITER $$

-- ------------------------------------------------------------
-- PROCEDURE: sp_processar_pedido
-- Parâmetros:
--   p_idCliente    → id do cliente que faz o pedido
--   p_descricao    → descrição do pedido
--   p_sendValue    → valor do frete
--   p_idProduto    → produto a adicionar no pedido
--   p_quantidade   → quantidade do produto
--
-- Lógica:
--   1. Verifica se o cliente existe → erro se não existir
--   2. Insere o pedido (SAVEPOINT sp_pedido)
--   3. Verifica estoque do produto → erro se insuficiente
--   4. Insere o item no pedido
--   5. Registra no log de auditoria
--   Em caso de qualquer erro → ROLLBACK total
--   Em caso de erro de estoque → ROLLBACK até sp_pedido
-- ------------------------------------------------------------
CREATE PROCEDURE sp_processar_pedido(
    IN  p_idCliente   INT,
    IN  p_descricao   VARCHAR(255),
    IN  p_sendValue   FLOAT,
    IN  p_idProduto   INT,
    IN  p_quantidade  INT,
    OUT p_resultado   VARCHAR(255)
)
BEGIN
    -- Variáveis de controle
    DECLARE v_cliente_existe INT DEFAULT 0;
    DECLARE v_estoque        INT DEFAULT 0;
    DECLARE v_pedido_id      INT DEFAULT 0;
    DECLARE v_erro_msg       VARCHAR(255);

    -- Handler que captura qualquer erro SQL e dispara ROLLBACK total
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_erro_msg = MESSAGE_TEXT;
        ROLLBACK;
        SET p_resultado = CONCAT('ERRO — Transacao revertida. Detalhe: ', v_erro_msg);
    END;

    -- --------------------------------------------------------
    -- Início da transação
    -- --------------------------------------------------------
    START TRANSACTION;

        -- Passo 1: verificar existência do cliente
        SELECT COUNT(*) INTO v_cliente_existe
        FROM   clients
        WHERE  idClient = p_idCliente;

        IF v_cliente_existe = 0 THEN
            -- Força um erro para acionar o EXIT HANDLER → ROLLBACK
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cliente nao encontrado na base de dados.';
        END IF;

        -- Passo 2: inserir o pedido
        INSERT INTO orders (idOrderClient, orderStatus, orderDescription, sendValue, paymentCash)
        VALUES (p_idCliente, 'Em processamento', p_descricao, p_sendValue, FALSE);

        SET v_pedido_id = LAST_INSERT_ID();

        -- SAVEPOINT após criação do pedido
        SAVEPOINT sp_pedido_criado;

        -- Passo 3: verificar estoque do produto
        --          (usa a tabela storageLocation + productStorage)
        SELECT COALESCE(SUM(ps.quantity), 0) INTO v_estoque
        FROM   storageLocation sl
        JOIN   productStorage  ps ON ps.idProdStorage = sl.idLstorage
        WHERE  sl.idLproduct = p_idProduto;

        IF v_estoque < p_quantidade THEN
            -- Estoque insuficiente → desfaz apenas os itens,
            -- mantém o pedido criado (ROLLBACK parcial ao SAVEPOINT)
            ROLLBACK TO SAVEPOINT sp_pedido_criado;

            -- Atualiza status do pedido para indicar problema
            UPDATE orders
            SET    orderStatus      = 'Cancelado',
                   orderDescription = CONCAT(p_descricao, ' [SEM ESTOQUE]')
            WHERE  idOrder = v_pedido_id;

            INSERT INTO order_audit_log (idOrder, acao, status_antes, status_depois)
            VALUES (v_pedido_id, 'CANCELAR_SEM_ESTOQUE', 'Em processamento', 'Cancelado');

            SET p_resultado = CONCAT(
                'AVISO — Pedido ', v_pedido_id,
                ' criado mas cancelado por estoque insuficiente. ',
                'Disponivel: ', v_estoque,
                ' | Solicitado: ', p_quantidade
            );
        ELSE
            -- Passo 4: inserir item no pedido
            INSERT INTO productOrder (idPOproduct, idPOorder, poQuantity, poStatus)
            VALUES (p_idProduto, v_pedido_id, p_quantidade, 'Disponivel');

            -- Passo 5: log de auditoria
            INSERT INTO order_audit_log (idOrder, acao, status_antes, status_depois)
            VALUES (v_pedido_id, 'PEDIDO_CONFIRMADO', NULL, 'Em processamento');

            SET p_resultado = CONCAT(
                'SUCESSO — Pedido ', v_pedido_id,
                ' processado para cliente ', p_idCliente,
                '. Produto: ', p_idProduto,
                ' | Qtd: ', p_quantidade
            );
        END IF;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------------------------------
-- Testes da PROCEDURE
-- ------------------------------------------------------------

-- Teste 1: sucesso — cliente existe e produto tem estoque
SET @resultado = '';
CALL sp_processar_pedido(1, 'Pedido via procedure - SUCESSO', 15.00, 1, 5, @resultado);
SELECT @resultado AS Resultado_Teste1;

-- Teste 2: erro de estoque — solicita mais do que há disponível
SET @resultado = '';
CALL sp_processar_pedido(3, 'Pedido com estoque insuficiente', 10.00, 2, 9999, @resultado);
SELECT @resultado AS Resultado_Teste2;

-- Teste 3: erro de cliente — ID inexistente → ROLLBACK total
SET @resultado = '';
CALL sp_processar_pedido(9999, 'Pedido cliente invalido', 10.00, 1, 1, @resultado);
SELECT @resultado AS Resultado_Teste3;

-- Verificar log de auditoria após todos os testes
SELECT 'Log de auditoria completo:' AS info;
SELECT * FROM order_audit_log ORDER BY executado_em;


-- ============================================================
-- EVENTO AGENDADO — limpeza semanal de logs antigos (bônus)
-- ============================================================
SET GLOBAL event_scheduler = ON;

DELIMITER $$

CREATE EVENT IF NOT EXISTS evt_limpeza_log_auditoria
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP + INTERVAL 7 DAY
DO
BEGIN
    DELETE FROM order_audit_log
    WHERE executado_em < NOW() - INTERVAL 90 DAY;
END$$

DELIMITER ;


-- ============================================================
-- PARTE 3 — BACKUP E RECOVERY (instruções para execução no
--            terminal — não executar dentro do MySQL)
-- ============================================================
/*
  ================================================================
  BACKUP COMPLETO DO BANCO ecommerce (via terminal)
  Inclui: estrutura, dados, procedures, triggers, eventos
  ================================================================

  # 1. Backup completo com todos os recursos
  mysqldump -u root -p \
      --routines \           # inclui procedures e functions
      --triggers \           # inclui triggers
      --events \             # inclui eventos agendados
      --single-transaction \ # snapshot consistente (InnoDB)
      --add-drop-database \  # recria o DB no restore
      --databases ecommerce \
  > backup_ecommerce_completo.sql

  # 2. Backup apenas da estrutura (DDL)
  mysqldump -u root -p \
      --no-data \
      --routines --triggers --events \
      ecommerce \
  > backup_ecommerce_estrutura.sql

  # 3. Backup apenas dos dados (DML)
  mysqldump -u root -p \
      --no-create-info \
      ecommerce \
  > backup_ecommerce_dados.sql

  # 4. Backup de múltiplos bancos simultaneamente
  mysqldump -u root -p \
      --routines --triggers --events \
      --databases ecommerce company_constraints \
  > backup_multiplos_bancos.sql

  ================================================================
  RECOVERY — Restaurar o banco a partir do backup
  ================================================================

  # Opção A: restaurar diretamente
  mysql -u root -p < backup_ecommerce_completo.sql

  # Opção B: restaurar em banco específico (se o dump não
  #          contiver CREATE DATABASE / USE)
  mysql -u root -p ecommerce < backup_ecommerce_completo.sql

  # Opção C: verificar o conteúdo antes de restaurar
  grep -E "(CREATE TABLE|INSERT INTO|CREATE PROCEDURE)" \
      backup_ecommerce_completo.sql | head -30

  ================================================================
  DICA — Automatizar backup com cron (Linux)
  ================================================================

  # Adicionar ao crontab (crontab -e):
  # Backup diário às 02:00
  0 2 * * * mysqldump -u root -pSENHA \
      --routines --triggers --events --single-transaction \
      --databases ecommerce >> /backups/ecommerce_$(date +\%F).sql

  ================================================================
*/

-- ============================================================
-- CONSULTAS DE VERIFICAÇÃO FINAIS
-- ============================================================
SELECT 'Clientes cadastrados:' AS info; SELECT COUNT(*) AS total FROM clients;
SELECT 'Pedidos por status:' AS info;
SELECT orderStatus, COUNT(*) AS total FROM orders GROUP BY orderStatus;
SELECT 'Procedures criadas:' AS info;
SELECT ROUTINE_NAME, ROUTINE_TYPE
FROM   information_schema.ROUTINES
WHERE  ROUTINE_SCHEMA = 'ecommerce';
SELECT 'Eventos agendados:' AS info;
SELECT EVENT_NAME, STATUS, INTERVAL_VALUE, INTERVAL_FIELD
FROM   information_schema.EVENTS
WHERE  EVENT_SCHEMA = 'ecommerce';
