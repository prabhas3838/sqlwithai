-- MySQL dump 10.13  Distrib 9.7.1, for macos15.7 (arm64)
--
-- Host: localhost    Database: atliq_tshirts
-- ------------------------------------------------------
-- Server version	9.0.1

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
-- Table structure for table `discounts`
--

DROP TABLE IF EXISTS `discounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `discounts` (
  `discount_id` int NOT NULL AUTO_INCREMENT,
  `t_shirt_id` int NOT NULL,
  `pct_discount` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`discount_id`),
  KEY `t_shirt_id` (`t_shirt_id`),
  CONSTRAINT `discounts_ibfk_1` FOREIGN KEY (`t_shirt_id`) REFERENCES `t_shirts` (`t_shirt_id`),
  CONSTRAINT `discounts_chk_1` CHECK ((`pct_discount` between 0 and 100))
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `discounts`
--

LOCK TABLES `discounts` WRITE;
/*!40000 ALTER TABLE `discounts` DISABLE KEYS */;
INSERT INTO `discounts` VALUES (1,1,10.00),(2,2,15.00),(3,3,20.00),(4,4,5.00),(5,5,25.00),(6,6,10.00),(7,7,30.00),(8,8,35.00),(9,9,40.00),(10,10,45.00);
/*!40000 ALTER TABLE `discounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_shirts`
--

DROP TABLE IF EXISTS `t_shirts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_shirts` (
  `t_shirt_id` int NOT NULL AUTO_INCREMENT,
  `brand` enum('Van Huesen','Levi','Nike','Adidas') NOT NULL,
  `color` enum('Red','Blue','Black','White') NOT NULL,
  `size` enum('XS','S','M','L','XL') NOT NULL,
  `price` int DEFAULT NULL,
  `stock_quantity` int NOT NULL,
  PRIMARY KEY (`t_shirt_id`),
  UNIQUE KEY `brand_color_size` (`brand`,`color`,`size`),
  CONSTRAINT `t_shirts_chk_1` CHECK ((`price` between 10 and 50))
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_shirts`
--

LOCK TABLES `t_shirts` WRITE;
/*!40000 ALTER TABLE `t_shirts` DISABLE KEYS */;
INSERT INTO `t_shirts` VALUES (1,'Van Huesen','Red','S',12,33),(2,'Van Huesen','White','XS',49,48),(3,'Van Huesen','White','L',31,82),(4,'Levi','Black','M',46,96),(5,'Van Huesen','Black','XL',39,80),(6,'Nike','Blue','S',34,18),(7,'Nike','Red','M',18,56),(8,'Adidas','Red','L',47,69),(9,'Nike','White','S',43,48),(10,'Nike','White','L',27,37),(11,'Van Huesen','White','S',49,71),(12,'Levi','Blue','XS',41,46),(13,'Nike','Blue','XS',43,11),(14,'Nike','White','XS',23,52),(15,'Levi','Blue','XL',29,58),(16,'Levi','Black','L',19,31),(18,'Van Huesen','White','XL',16,44),(19,'Levi','White','M',11,49),(20,'Van Huesen','Red','XL',14,12),(21,'Adidas','Red','XS',32,24),(22,'Van Huesen','Red','M',14,97),(24,'Levi','Red','S',17,20),(27,'Nike','Black','M',23,18),(28,'Nike','Blue','XL',12,34),(30,'Adidas','Red','M',41,44),(32,'Van Huesen','Red','L',49,95),(33,'Adidas','Blue','S',41,73),(36,'Levi','Red','XL',17,21),(37,'Van Huesen','White','M',21,29),(38,'Van Huesen','Blue','L',22,30),(47,'Nike','Black','XS',48,24),(48,'Adidas','Blue','L',32,69),(49,'Nike','Red','XL',28,36),(50,'Van Huesen','Black','L',22,74),(51,'Nike','Red','XS',37,98),(53,'Adidas','Black','XL',36,50),(54,'Levi','Red','XS',19,61),(56,'Nike','Blue','M',32,97),(58,'Nike','Red','S',21,63),(59,'Van Huesen','Black','M',37,97),(62,'Levi','Black','XS',24,71),(63,'Levi','Black','XL',32,25),(64,'Van Huesen','Black','XS',48,36),(65,'Nike','Black','L',48,61),(67,'Levi','Black','S',20,51),(68,'Levi','White','S',41,94),(69,'Levi','White','XL',10,53),(70,'Levi','Blue','M',10,30),(77,'Van Huesen','Blue','XL',17,20),(80,'Van Huesen','Blue','S',30,57),(83,'Levi','Blue','S',37,70),(89,'Adidas','Blue','XS',18,89),(91,'Van Huesen','Black','S',37,35),(93,'Adidas','Black','XS',38,12),(98,'Adidas','Blue','M',16,32),(99,'Nike','White','M',46,81),(100,'Levi','Red','M',32,17);
/*!40000 ALTER TABLE `t_shirts` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-23 17:06:56
