-- MySQL dump 10.13  Distrib 8.0.45, for Linux (x86_64)
--
-- Host: localhost    Database: ecommerce
-- ------------------------------------------------------
-- Server version	8.0.45-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `ecommerce`
--

/*!40000 DROP DATABASE IF EXISTS `ecommerce`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `ecommerce` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `ecommerce`;

--
-- Table structure for table `clients`
--

DROP TABLE IF EXISTS `clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clients` (
  `idClient` int NOT NULL AUTO_INCREMENT,
  `Fname` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Minit` char(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Lname` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `CPF` char(11) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`idClient`),
  UNIQUE KEY `unique_cpf_client` (`CPF`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clients`
--

LOCK TABLES `clients` WRITE;
/*!40000 ALTER TABLE `clients` DISABLE KEYS */;
INSERT INTO `clients` VALUES (1,'Maria','S','Silva','11111111101','Rua das Flores, 10 - SP'),(2,'Joao','P','Santos','22222222202','Av Brasil, 200 - RJ'),(3,'Carla','M','Oliveira','33333333303','Rua XV, 45 - PR'),(4,'Pedro','A','Costa','44444444404','Al Paulista, 1000 - SP'),(5,'Fernanda','R','Lima','55555555505','Rua Goias, 77 - MG'),(6,'Lucas','T','Ferreira','66666666606','Rua Nova, 99 - SP');
/*!40000 ALTER TABLE `clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_audit_log`
--

DROP TABLE IF EXISTS `order_audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_audit_log` (
  `idLog` int NOT NULL AUTO_INCREMENT,
  `idOrder` int DEFAULT NULL,
  `acao` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status_antes` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status_depois` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `usuario` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'sistema',
  `executado_em` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idLog`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_audit_log`
--

LOCK TABLES `order_audit_log` WRITE;
/*!40000 ALTER TABLE `order_audit_log` DISABLE KEYS */;
INSERT INTO `order_audit_log` VALUES (1,2,'CONFIRMAR_PEDIDO','Em processamento','Confirmado','sistema','2026-04-28 00:10:17'),(2,6,'NOVO_PEDIDO_CRIADO',NULL,'Em processamento','sistema','2026-04-28 00:10:17'),(3,7,'PEDIDO_CONFIRMADO',NULL,'Em processamento','sistema','2026-04-28 00:10:17'),(4,8,'CANCELAR_SEM_ESTOQUE','Em processamento','Cancelado','sistema','2026-04-28 00:10:17');
/*!40000 ALTER TABLE `order_audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `idOrder` int NOT NULL AUTO_INCREMENT,
  `idOrderClient` int NOT NULL,
  `orderStatus` enum('Cancelado','Confirmado','Em processamento') COLLATE utf8mb4_unicode_ci DEFAULT 'Em processamento',
  `orderDescription` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sendValue` float DEFAULT '10',
  `paymentCash` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`idOrder`),
  KEY `fk_orders_client` (`idOrderClient`),
  CONSTRAINT `fk_orders_client` FOREIGN KEY (`idOrderClient`) REFERENCES `clients` (`idClient`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,1,'Confirmado','Pedido de eletronicos',15,0),(2,2,'Confirmado','Pedido de roupas',10,1),(3,3,'Confirmado','Pedido de brinquedos',12,0),(4,4,'Cancelado','Pedido cancelado cliente',10,0),(5,5,'Em processamento','Pedido de alimentos',8,1),(6,6,'Em processamento','Pedido de teste CODE 2',12,0),(7,1,'Em processamento','Pedido via procedure - SUCESSO',15,0),(8,3,'Cancelado','Pedido com estoque insuficiente [SEM ESTOQUE]',10,0);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `idClient` int NOT NULL,
  `idPayment` int NOT NULL,
  `typePayment` enum('Boleto','Cartao','Dois cartoes') COLLATE utf8mb4_unicode_ci NOT NULL,
  `limitAvailable` float DEFAULT NULL,
  PRIMARY KEY (`idClient`,`idPayment`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,1,'Cartao',5000),(2,1,'Boleto',NULL),(3,1,'Dois cartoes',3000),(4,1,'Cartao',1500),(5,1,'Boleto',NULL);
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product` (
  `idProduct` int NOT NULL AUTO_INCREMENT,
  `Pname` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `classification_kids` tinyint(1) DEFAULT '0',
  `category` enum('Eletronico','Vestimenta','Brinquedos','Alimentos','Moveis') COLLATE utf8mb4_unicode_ci NOT NULL,
  `avaliacao` float DEFAULT '0',
  `size` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`idProduct`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (1,'Smartphone Galaxy A54',0,'Eletronico',4.5,NULL),(2,'Notebook Dell 15\"',0,'Eletronico',4.8,NULL),(3,'Camiseta Polo',0,'Vestimenta',4.2,'M'),(4,'LEGO Cidade 500 pcs',1,'Brinquedos',4.9,NULL),(5,'Arroz Integral 5kg',0,'Alimentos',4.3,NULL),(6,'Mesa de Escritorio',0,'Moveis',4.1,'G');
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productOrder`
--

DROP TABLE IF EXISTS `productOrder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productOrder` (
  `idPOproduct` int NOT NULL,
  `idPOorder` int NOT NULL,
  `poQuantity` int DEFAULT '1',
  `poStatus` enum('Disponivel','Sem estoque') COLLATE utf8mb4_unicode_ci DEFAULT 'Disponivel',
  PRIMARY KEY (`idPOproduct`,`idPOorder`),
  KEY `fk_po_order` (`idPOorder`),
  CONSTRAINT `fk_po_order` FOREIGN KEY (`idPOorder`) REFERENCES `orders` (`idOrder`),
  CONSTRAINT `fk_po_product` FOREIGN KEY (`idPOproduct`) REFERENCES `product` (`idProduct`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productOrder`
--

LOCK TABLES `productOrder` WRITE;
/*!40000 ALTER TABLE `productOrder` DISABLE KEYS */;
INSERT INTO `productOrder` VALUES (1,1,1,'Disponivel'),(1,7,5,'Disponivel'),(2,1,1,'Disponivel'),(3,2,2,'Disponivel'),(4,3,1,'Disponivel'),(5,5,3,'Disponivel'),(6,6,1,'Disponivel');
/*!40000 ALTER TABLE `productOrder` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productSeller`
--

DROP TABLE IF EXISTS `productSeller`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productSeller` (
  `idPseller` int NOT NULL,
  `idPproduct` int NOT NULL,
  `prodQuantity` int DEFAULT '1',
  PRIMARY KEY (`idPseller`,`idPproduct`),
  KEY `fk_ps_product` (`idPproduct`),
  CONSTRAINT `fk_ps_product` FOREIGN KEY (`idPproduct`) REFERENCES `product` (`idProduct`),
  CONSTRAINT `fk_ps_seller` FOREIGN KEY (`idPseller`) REFERENCES `seller` (`idSeller`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productSeller`
--

LOCK TABLES `productSeller` WRITE;
/*!40000 ALTER TABLE `productSeller` DISABLE KEYS */;
INSERT INTO `productSeller` VALUES (1,1,30),(1,2,15),(2,3,40),(2,4,25);
/*!40000 ALTER TABLE `productSeller` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productStorage`
--

DROP TABLE IF EXISTS `productStorage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productStorage` (
  `idProdStorage` int NOT NULL AUTO_INCREMENT,
  `storageLocation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` int DEFAULT '0',
  PRIMARY KEY (`idProdStorage`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productStorage`
--

LOCK TABLES `productStorage` WRITE;
/*!40000 ALTER TABLE `productStorage` DISABLE KEYS */;
INSERT INTO `productStorage` VALUES (1,'Sao Paulo - Galpao A',150),(2,'Rio de Janeiro - CD',80),(3,'Curitiba - Deposito 1',200);
/*!40000 ALTER TABLE `productStorage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productSupplier`
--

DROP TABLE IF EXISTS `productSupplier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productSupplier` (
  `idPsSupplier` int NOT NULL,
  `idPsProduct` int NOT NULL,
  `quantity` int NOT NULL,
  PRIMARY KEY (`idPsSupplier`,`idPsProduct`),
  KEY `fk_pss_product` (`idPsProduct`),
  CONSTRAINT `fk_pss_product` FOREIGN KEY (`idPsProduct`) REFERENCES `product` (`idProduct`),
  CONSTRAINT `fk_pss_supplier` FOREIGN KEY (`idPsSupplier`) REFERENCES `supplier` (`idSupplier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productSupplier`
--

LOCK TABLES `productSupplier` WRITE;
/*!40000 ALTER TABLE `productSupplier` DISABLE KEYS */;
INSERT INTO `productSupplier` VALUES (1,1,100),(1,2,50),(2,3,200),(3,5,500);
/*!40000 ALTER TABLE `productSupplier` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller`
--

DROP TABLE IF EXISTS `seller`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller` (
  `idSeller` int NOT NULL AUTO_INCREMENT,
  `SocialName` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `AbstName` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `CNPJ` char(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `CPF` char(9) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact` char(11) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`idSeller`),
  UNIQUE KEY `unique_cnpj_seller` (`CNPJ`),
  UNIQUE KEY `unique_cpf_seller` (`CPF`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller`
--

LOCK TABLES `seller` WRITE;
/*!40000 ALTER TABLE `seller` DISABLE KEYS */;
INSERT INTO `seller` VALUES (1,'Eletro Shop','EleShop','44444444000104',NULL,'SP','11988880001'),(2,'Moda Kids ME',NULL,NULL,'123456789','RJ','21988880002');
/*!40000 ALTER TABLE `seller` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `storageLocation`
--

DROP TABLE IF EXISTS `storageLocation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `storageLocation` (
  `idLproduct` int NOT NULL,
  `idLstorage` int NOT NULL,
  `location` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`idLproduct`,`idLstorage`),
  KEY `fk_sl_storage` (`idLstorage`),
  CONSTRAINT `fk_sl_product` FOREIGN KEY (`idLproduct`) REFERENCES `product` (`idProduct`),
  CONSTRAINT `fk_sl_storage` FOREIGN KEY (`idLstorage`) REFERENCES `productStorage` (`idProdStorage`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `storageLocation`
--

LOCK TABLES `storageLocation` WRITE;
/*!40000 ALTER TABLE `storageLocation` DISABLE KEYS */;
INSERT INTO `storageLocation` VALUES (1,1,'Prateleira A1'),(2,1,'Prateleira A2'),(3,2,'Prateleira B1'),(4,3,'Prateleira C3'),(5,3,'Prateleira C5');
/*!40000 ALTER TABLE `storageLocation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supplier`
--

DROP TABLE IF EXISTS `supplier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `supplier` (
  `idSupplier` int NOT NULL AUTO_INCREMENT,
  `SocialName` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `CNPJ` char(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact` char(11) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`idSupplier`),
  UNIQUE KEY `unique_supplier` (`CNPJ`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier`
--

LOCK TABLES `supplier` WRITE;
/*!40000 ALTER TABLE `supplier` DISABLE KEYS */;
INSERT INTO `supplier` VALUES (1,'Tech Imports Ltda','11111111000101','11999990001'),(2,'Moda Fashion SA','22222222000102','11999990002'),(3,'Alimentos Sul Ltda','33333333000103','41999990003');
/*!40000 ALTER TABLE `supplier` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'ecommerce'
--
/*!50106 SET @save_time_zone= @@TIME_ZONE */ ;
/*!50106 DROP EVENT IF EXISTS `evt_limpeza_log_auditoria` */;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8mb4 */ ;;
/*!50003 SET character_set_results = utf8mb4 */ ;;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `evt_limpeza_log_auditoria` ON SCHEDULE EVERY 1 WEEK STARTS '2026-05-05 00:10:17' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    DELETE FROM order_audit_log
    WHERE executado_em < NOW() - INTERVAL 90 DAY;
END */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
DELIMITER ;
/*!50106 SET TIME_ZONE= @save_time_zone */ ;

--
-- Dumping routines for database 'ecommerce'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_processar_pedido` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_processar_pedido`(
    IN  p_idCliente   INT,
    IN  p_descricao   VARCHAR(255),
    IN  p_sendValue   FLOAT,
    IN  p_idProduto   INT,
    IN  p_quantidade  INT,
    OUT p_resultado   VARCHAR(255)
)
BEGIN
    
    DECLARE v_cliente_existe INT DEFAULT 0;
    DECLARE v_estoque        INT DEFAULT 0;
    DECLARE v_pedido_id      INT DEFAULT 0;
    DECLARE v_erro_msg       VARCHAR(255);

    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_erro_msg = MESSAGE_TEXT;
        ROLLBACK;
        SET p_resultado = CONCAT('ERRO — Transacao revertida. Detalhe: ', v_erro_msg);
    END;

    
    
    
    START TRANSACTION;

        
        SELECT COUNT(*) INTO v_cliente_existe
        FROM   clients
        WHERE  idClient = p_idCliente;

        IF v_cliente_existe = 0 THEN
            
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cliente nao encontrado na base de dados.';
        END IF;

        
        INSERT INTO orders (idOrderClient, orderStatus, orderDescription, sendValue, paymentCash)
        VALUES (p_idCliente, 'Em processamento', p_descricao, p_sendValue, FALSE);

        SET v_pedido_id = LAST_INSERT_ID();

        
        SAVEPOINT sp_pedido_criado;

        
        
        SELECT COALESCE(SUM(ps.quantity), 0) INTO v_estoque
        FROM   storageLocation sl
        JOIN   productStorage  ps ON ps.idProdStorage = sl.idLstorage
        WHERE  sl.idLproduct = p_idProduto;

        IF v_estoque < p_quantidade THEN
            
            
            ROLLBACK TO SAVEPOINT sp_pedido_criado;

            
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
            
            INSERT INTO productOrder (idPOproduct, idPOorder, poQuantity, poStatus)
            VALUES (p_idProduto, v_pedido_id, p_quantidade, 'Disponivel');

            
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-28  0:10:20
