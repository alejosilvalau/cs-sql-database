CREATE DATABASE  IF NOT EXISTS `afatse_mod` /*!40100 DEFAULT CHARACTER SET utf8mb3 */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `afatse_mod`;
-- MySQL dump 10.13  Distrib 8.0.43, for Linux (x86_64)
--
-- Host: localhost    Database: afatse_mod
-- ------------------------------------------------------
-- Server version	8.0.43-0ubuntu0.24.04.2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `alumnos`
--

DROP TABLE IF EXISTS `alumnos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alumnos` (
  `dni` int NOT NULL,
  `nombre` varchar(20) NOT NULL,
  `apellido` varchar(20) NOT NULL,
  `tel` varchar(20) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `direccion` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`dni`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alumnos`
--

LOCK TABLES `alumnos` WRITE;
/*!40000 ALTER TABLE `alumnos` DISABLE KEYS */;
INSERT INTO `alumnos` VALUES (10101010,'Ruben','Dario','1010101','rdario@gmail.com','Rio de Janeiro 1010'),(11111111,'Casimiro','Cegado','1111111','casimirocegado9B@yahoo.com.ar','9 de julio 111 9B'),(12121212,'Maria','Asquerino','1212121','masqu@gmail.com','Salta 1212'),(13131313,'Antoine de','Saint-Exupery','1313131','anto_saex@gmail.com','Francia 1313'),(14141414,'Jose','Echegaray','1414141','joseche@uol.com','Entre Rios 1414'),(15151515,'Isabel','Gemio','1515151','igemio@yahoo.com.ar','Garay 1515'),(16161616,'Gertrudis','Gomez de Avellaneda','1616161','gertygomez@gmail.com','Rodriguez 1616'),(17171717,'Ana Maria','Matute','1717171','ana_m_matute@gmail.com','Salta 1717'),(17817615,'Beatriz','Repetti','0314-444444','berep@hotmail.com','Rioja 1111'),(18181818,'Victor','Montenegro','1818181','v_monte_negro@hotmail.com','Lavalle 1818'),(19191919,'Blaise','Pascal','1919191','blaise@pascal.com.ar','Entre Rios 1919'),(20202020,'Bella','Abzug','2020202','babzug333@yahoo.com','Anchorena 2020'),(21212121,'Jorge','Bucay','2121212','totobuca@hotmail.com','Mendoza 2121'),(22222222,'Laura','Morante','2222222','lau_morante22@gmail.com','Italia 2222'),(23232323,'Victor','Hugo','2323232','vichugo@gmail.com','Pellegrini 2323'),(24242424,'José','Ortega y Gasset','2424242','pepe_oys@hotmail.com','Francia 2424');
/*!40000 ALTER TABLE `alumnos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `alumnos_after_ins_tr` AFTER INSERT ON `alumnos` FOR EACH ROW BEGIN
insert into
  alumnos_historico(
    dni,
    fecha_hora_cambio,
    nombre,
    apellido,
    tel,
    email,
    direccion,
    usuario_modificacion
  )
values
  (
    new.dni,
    current_timestamp,
    new.nombre,
    new.apellido,
    new.tel,
	new.email,
    new.direccion,
    current_user
  );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `alumnos_before_upd_tr` BEFORE UPDATE ON `alumnos` FOR EACH ROW BEGIN
insert into
  alumnos_historico(
    dni,
    fecha_hora_cambio,
    nombre,
    apellido,
    tel,
    email,
    direccion,
    usuario_modificacion
  )
values
  (
    new.dni,
    current_timestamp,
    new.nombre,
    new.apellido,
    new.tel,
    new.email,
    new.direccion,
    current_user
  );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `alumnos_historico`
--

DROP TABLE IF EXISTS `alumnos_historico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alumnos_historico` (
  `dni` int NOT NULL,
  `fecha_hora_cambio` datetime NOT NULL,
  `nombre` varchar(20) DEFAULT NULL,
  `apellido` varchar(20) DEFAULT NULL,
  `tel` varchar(20) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `direccion` varchar(50) DEFAULT NULL,
  `usuario_modificacion` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`dni`,`fecha_hora_cambio`),
  CONSTRAINT `alumnos_historico_alumnos_fk` FOREIGN KEY (`dni`) REFERENCES `alumnos` (`dni`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alumnos_historico`
--

LOCK TABLES `alumnos_historico` WRITE;
/*!40000 ALTER TABLE `alumnos_historico` DISABLE KEYS */;
INSERT INTO `alumnos_historico` VALUES (17817615,'2025-10-25 17:36:23','Beatriz','Repetti','0314-444444','berep@hotmail.com','Rioja 1212','root@localhost'),(17817615,'2025-10-25 17:40:59','Beatriz','Repetti','0314-444444','berep@hotmail.com','Rioja 1111','root@localhost');
/*!40000 ALTER TABLE `alumnos_historico` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cuotas`
--

DROP TABLE IF EXISTS `cuotas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cuotas` (
  `nom_plan` char(20) NOT NULL,
  `nro_curso` int NOT NULL,
  `dni` int NOT NULL,
  `anio` int NOT NULL,
  `mes` int NOT NULL,
  `fecha_emision` date DEFAULT NULL,
  `fecha_pago` date DEFAULT NULL,
  `importe_pagado` decimal(9,3) DEFAULT NULL,
  PRIMARY KEY (`nom_plan`,`nro_curso`,`dni`,`anio`,`mes`),
  CONSTRAINT `cuotas_inscripciones_fk` FOREIGN KEY (`nom_plan`, `nro_curso`, `dni`) REFERENCES `inscripciones` (`nom_plan`, `nro_curso`, `dni`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cuotas`
--

LOCK TABLES `cuotas` WRITE;
/*!40000 ALTER TABLE `cuotas` DISABLE KEYS */;
INSERT INTO `cuotas` VALUES ('Marketing 1',1,10101010,2013,4,'2013-04-01','2013-04-05',25.000),('Marketing 1',1,10101010,2013,5,'2013-05-01','2013-05-14',31.250),('Marketing 1',1,10101010,2013,6,'2013-06-01','2013-06-24',35.000),('Marketing 1',1,10101010,2013,7,'2013-07-01','2013-07-20',35.000),('Marketing 1',1,10101010,2013,8,'2013-08-01','2013-08-27',35.000),('Marketing 1',1,10101010,2013,9,'2013-09-01','2013-09-18',35.000),('Marketing 1',1,11111111,2013,4,'2013-04-01','2013-04-08',25.000),('Marketing 1',1,11111111,2013,5,'2013-05-01','2013-05-12',31.250),('Marketing 1',1,11111111,2013,6,'2013-06-01','2013-06-10',28.000),('Marketing 1',1,11111111,2013,7,'2013-07-01','2013-07-11',35.000),('Marketing 1',1,11111111,2013,8,'2013-08-01','2013-08-25',35.000),('Marketing 1',1,11111111,2013,9,'2013-09-01','2013-09-04',28.000),('Marketing 1',1,12121212,2013,4,'2013-04-01','2013-04-05',25.000),('Marketing 1',1,12121212,2013,5,'2013-05-01','2013-05-10',25.000),('Marketing 1',1,12121212,2013,6,'2013-06-01','2013-06-05',28.000),('Marketing 1',1,12121212,2013,7,'2013-07-01','2013-07-23',35.000),('Marketing 1',1,12121212,2013,8,'2013-08-01','2013-08-14',35.000),('Marketing 1',1,12121212,2013,9,'2013-09-01','2013-09-02',28.000),('Marketing 1',1,13131313,2013,4,'2013-04-01','2013-04-25',31.250),('Marketing 1',1,13131313,2013,5,'2013-05-01','2013-05-03',25.000),('Marketing 1',1,13131313,2013,6,'2013-06-01','2013-06-27',35.000),('Marketing 1',1,13131313,2013,7,'2013-07-01','2013-07-07',28.000),('Marketing 1',1,13131313,2013,8,'2013-08-01','2013-08-11',35.000),('Marketing 1',1,13131313,2013,9,'2013-09-01','2013-09-04',28.000),('Marketing 1',2,20202020,2014,4,'2014-04-01','2014-04-17',46.250),('Marketing 1',2,20202020,2014,5,'2014-05-01','2014-05-15',46.250),('Marketing 1',2,20202020,2014,6,'2014-06-01','2014-06-25',56.250),('Marketing 1',2,20202020,2014,7,'2014-07-01','2014-07-21',56.250),('Marketing 1',2,20202020,2014,8,'2014-08-01','2014-08-27',67.500),('Marketing 1',2,20202020,2014,9,'2014-09-01','2014-09-15',67.500),('Marketing 1',2,21212121,2014,4,'2014-04-01','2014-04-22',46.250),('Marketing 1',2,21212121,2014,5,'2014-05-01','2014-05-08',37.000),('Marketing 1',2,21212121,2014,6,'2014-06-01','2014-06-03',45.000),('Marketing 1',2,21212121,2014,7,'2014-07-01','2014-07-17',56.250),('Marketing 1',2,21212121,2014,8,'2014-08-01','2014-08-19',67.500),('Marketing 1',2,21212121,2014,9,'2014-09-01','2014-09-16',67.500),('Marketing 1',2,22222222,2014,4,'2014-04-01','2014-04-21',46.250),('Marketing 1',2,22222222,2014,5,'2014-05-01','2014-05-28',46.250),('Marketing 1',2,22222222,2014,6,'2014-06-01','2014-06-18',56.250),('Marketing 1',2,22222222,2014,7,'2014-07-01','2014-07-07',45.000),('Marketing 1',2,22222222,2014,8,'2014-08-01','2014-08-07',54.000),('Marketing 1',2,22222222,2014,9,'2014-09-01','2014-09-16',67.500),('Marketing 2',1,10101010,2014,4,'2014-04-01','2014-04-29',75.000),('Marketing 2',1,10101010,2014,5,'2014-05-01','2014-05-09',60.000),('Marketing 2',1,10101010,2014,6,'2014-06-01','2014-06-16',91.250),('Marketing 2',1,10101010,2014,7,'2014-07-01','2014-07-22',91.250),('Marketing 2',1,10101010,2014,8,'2014-08-01','2014-08-03',88.000),('Marketing 2',1,10101010,2014,9,'2014-09-01','2014-09-06',88.000),('Marketing 2',1,10101010,2014,10,'2014-10-01','2014-10-23',110.000),('Marketing 2',1,11111111,2014,4,'2014-04-01','2014-04-10',60.000),('Marketing 2',1,11111111,2014,5,'2014-05-01','2014-05-07',60.000),('Marketing 2',1,11111111,2014,6,'2014-06-01','2014-06-06',73.000),('Marketing 2',1,11111111,2014,7,'2014-07-01','2014-07-09',73.000),('Marketing 2',1,11111111,2014,8,'2014-08-01','2014-08-28',110.000),('Marketing 2',1,11111111,2014,9,'2014-09-01','2014-09-23',110.000),('Marketing 2',1,11111111,2014,10,'2014-10-01','2014-10-01',88.000),('Marketing 2',1,12121212,2014,4,'2014-04-01','2014-04-25',75.000),('Marketing 2',1,12121212,2014,5,'2014-05-01','2014-05-06',60.000),('Marketing 2',1,12121212,2014,6,'2014-06-01','2014-06-11',91.250),('Marketing 2',1,12121212,2014,7,'2014-07-01','2014-07-08',73.000),('Marketing 2',1,12121212,2014,8,'2014-08-01','2014-08-04',88.000),('Marketing 2',1,12121212,2014,9,'2014-09-01','2014-09-27',110.000),('Marketing 2',1,12121212,2014,10,'2014-10-01','2014-10-06',88.000),('Marketing 2',2,23232323,2014,4,'2014-04-01','2014-04-02',60.000),('Marketing 2',2,23232323,2014,5,'2014-05-01','2014-05-01',60.000),('Marketing 2',2,23232323,2014,6,'2014-06-01','2014-06-02',73.000),('Marketing 2',2,23232323,2014,7,'2014-07-01','2014-07-02',73.000),('Marketing 2',2,23232323,2014,8,'2014-08-01','2014-08-02',88.000),('Marketing 2',2,23232323,2014,9,'2014-09-01','2014-09-02',88.000),('Marketing 2',2,23232323,2014,10,'2014-10-01','2014-10-02',88.000),('Marketing 2',2,24242424,2014,4,'2014-04-01','2014-04-02',60.000),('Marketing 2',2,24242424,2014,5,'2014-05-01','2014-05-01',60.000),('Marketing 2',2,24242424,2014,6,'2014-06-01','2014-06-02',73.000),('Marketing 2',2,24242424,2014,7,'2014-07-01',NULL,NULL),('Marketing 2',2,24242424,2014,8,'2014-08-01',NULL,NULL),('Marketing 2',2,24242424,2014,9,'2014-09-01',NULL,NULL),('Marketing 2',2,24242424,2014,10,'2014-10-01',NULL,NULL),('Reparac PC Avanzada',1,15151515,2014,3,'2014-03-01','2014-03-07',80.000),('Reparac PC Avanzada',1,15151515,2014,4,'2014-04-01','2014-04-16',118.750),('Reparac PC Avanzada',1,15151515,2014,5,'2014-05-01','2014-05-01',95.000),('Reparac PC Avanzada',1,15151515,2014,6,'2014-06-01','2014-06-14',150.000),('Reparac PC Avanzada',1,15151515,2014,7,'2014-07-01','2014-07-09',120.000),('Reparac PC Avanzada',1,15151515,2014,8,'2014-08-01','2014-08-03',145.000),('Reparac PC Avanzada',1,15151515,2014,9,'2014-09-01','2014-09-14',181.250),('Reparac PC Avanzada',1,15151515,2014,10,'2014-10-01','2014-10-04',145.000),('Reparac PC Avanzada',1,15151515,2014,11,'2014-11-01','2014-11-08',145.000),('Reparac PC Avanzada',1,15151515,2014,12,'2014-12-01','2014-12-25',181.250),('Reparac PC Avanzada',1,17171717,2014,3,'2014-03-01','2014-03-14',100.000),('Reparac PC Avanzada',1,17171717,2014,4,'2014-04-01','2014-04-22',118.750),('Reparac PC Avanzada',1,17171717,2014,5,'2014-05-01','2014-05-11',118.750),('Reparac PC Avanzada',1,17171717,2014,6,'2014-06-01','2014-06-16',150.000),('Reparac PC Avanzada',1,17171717,2014,7,'2014-07-01','2014-07-17',150.000),('Reparac PC Avanzada',1,17171717,2014,8,'2014-08-01','2014-08-10',145.000),('Reparac PC Avanzada',1,17171717,2014,9,'2014-09-01','2014-09-25',181.250),('Reparac PC Avanzada',1,17171717,2014,10,'2014-10-01','2014-10-07',145.000),('Reparac PC Avanzada',1,17171717,2014,11,'2014-11-01','2014-11-17',181.250),('Reparac PC Avanzada',1,17171717,2014,12,'2014-12-01','2014-12-05',145.000),('Reparacion PC',1,14141414,2013,5,'2013-05-01','2013-05-04',37.000),('Reparacion PC',1,14141414,2013,6,'2013-06-01','2013-06-04',42.000),('Reparacion PC',1,14141414,2013,7,'2013-07-01','2013-07-10',42.000),('Reparacion PC',1,14141414,2013,8,'2013-08-01','2013-08-05',42.000),('Reparacion PC',1,14141414,2013,9,'2013-09-01','2013-09-27',52.500),('Reparacion PC',1,14141414,2013,10,'2013-10-01','2013-10-02',42.000),('Reparacion PC',1,15151515,2013,5,'2013-05-01','2013-05-14',46.250),('Reparacion PC',1,15151515,2013,6,'2013-06-01','2013-06-05',42.000),('Reparacion PC',1,15151515,2013,7,'2013-07-01','2013-07-11',52.500),('Reparacion PC',1,15151515,2013,8,'2013-08-01','2013-08-12',52.500),('Reparacion PC',1,15151515,2013,9,'2013-09-01','2013-09-27',52.500),('Reparacion PC',1,15151515,2013,10,'2013-10-01','2013-10-09',42.000),('Reparacion PC',1,16161616,2013,5,'2013-05-01','2013-05-23',46.250),('Reparacion PC',1,16161616,2013,6,'2013-06-01','2013-06-01',42.000),('Reparacion PC',1,16161616,2013,7,'2013-07-01','2013-07-24',52.500),('Reparacion PC',1,16161616,2013,8,'2013-08-01','2013-08-28',52.500),('Reparacion PC',1,16161616,2013,9,'2013-09-01','2013-09-10',42.000),('Reparacion PC',1,16161616,2013,10,'2013-10-01','2013-10-23',52.500),('Reparacion PC',1,17171717,2013,5,'2013-05-01','2013-05-28',46.250),('Reparacion PC',1,17171717,2013,6,'2013-06-01','2013-06-11',52.500),('Reparacion PC',1,17171717,2013,7,'2013-07-01','2013-07-27',52.500),('Reparacion PC',1,17171717,2013,8,'2013-08-01','2013-08-16',52.500),('Reparacion PC',1,17171717,2013,9,'2013-09-01','2013-09-29',52.500),('Reparacion PC',1,17171717,2013,10,'2013-10-01','2013-10-08',42.000),('Reparacion PC',1,18181818,2013,5,'2013-05-01','2013-05-10',37.000),('Reparacion PC',1,18181818,2013,6,'2013-06-01','2013-06-27',52.500),('Reparacion PC',1,18181818,2013,7,'2013-07-01','2013-07-19',52.500),('Reparacion PC',1,18181818,2013,8,'2013-08-01','2013-08-11',52.500),('Reparacion PC',1,18181818,2013,9,'2013-09-01','2013-09-28',52.500),('Reparacion PC',1,18181818,2013,10,'2013-10-01','2013-10-17',52.500),('Reparacion PC',2,22222222,2014,5,'2014-05-01','2014-05-03',54.000),('Reparacion PC',2,22222222,2014,6,'2014-06-01','2014-06-19',81.250),('Reparacion PC',2,22222222,2014,7,'2014-07-01','2014-07-29',81.250),('Reparacion PC',2,22222222,2014,8,'2014-08-01','2014-08-29',100.000),('Reparacion PC',2,22222222,2014,9,'2014-09-01','2014-09-01',80.000),('Reparacion PC',2,22222222,2014,10,'2014-10-01','2014-10-02',80.000);
/*!40000 ALTER TABLE `cuotas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cursos`
--

DROP TABLE IF EXISTS `cursos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cursos` (
  `nom_plan` char(20) NOT NULL,
  `nro_curso` int NOT NULL,
  `fecha_ini` date NOT NULL,
  `fecha_fin` date NOT NULL,
  `salon` varchar(20) DEFAULT NULL,
  `cupo` int DEFAULT NULL,
  `cant_inscriptos` int NOT NULL,
  PRIMARY KEY (`nom_plan`,`nro_curso`),
  CONSTRAINT `cursos_plan_fk` FOREIGN KEY (`nom_plan`) REFERENCES `plan_capacitacion` (`nom_plan`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cursos`
--

LOCK TABLES `cursos` WRITE;
/*!40000 ALTER TABLE `cursos` DISABLE KEYS */;
INSERT INTO `cursos` VALUES ('Marketing 1',1,'2013-04-01','2013-10-01',NULL,100,4),('Marketing 1',2,'2014-04-01','2014-10-01',NULL,100,3),('Marketing 1',3,'2015-04-01','2015-10-01',NULL,100,0),('Marketing 2',1,'2014-04-01','2014-11-01','1',20,3),('Marketing 2',2,'2014-04-01','2014-11-01','1',20,2),('Marketing 2',3,'2015-04-01','2015-11-01','1',20,5),('Marketing 3',1,'2015-04-01','2015-12-15','2',3,3),('Reparac PC Avanzada',1,'2014-03-01','2014-12-15','3',10,2),('Reparac PC Avanzada',2,'2015-03-01','2015-12-15','3',10,3),('Reparacion PC',1,'2013-05-01','2013-11-01','3',10,5),('Reparacion PC',2,'2014-05-01','2014-11-01','3',10,1),('Reparacion PC',3,'2015-05-01','2015-11-01','3',10,1);
/*!40000 ALTER TABLE `cursos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cursos_horarios`
--

DROP TABLE IF EXISTS `cursos_horarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cursos_horarios` (
  `nom_plan` char(20) NOT NULL,
  `nro_curso` int NOT NULL,
  `nro_dia_semana` int NOT NULL,
  `hora_inicio` time NOT NULL,
  `hora_fin` time NOT NULL,
  PRIMARY KEY (`nom_plan`,`nro_curso`,`nro_dia_semana`),
  CONSTRAINT `cursos_horarios_cursos_fk` FOREIGN KEY (`nom_plan`, `nro_curso`) REFERENCES `cursos` (`nom_plan`, `nro_curso`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cursos_horarios`
--

LOCK TABLES `cursos_horarios` WRITE;
/*!40000 ALTER TABLE `cursos_horarios` DISABLE KEYS */;
INSERT INTO `cursos_horarios` VALUES ('Marketing 1',1,1,'16:00:00','18:00:00'),('Marketing 1',1,3,'16:00:00','18:00:00'),('Marketing 1',2,1,'16:00:00','18:00:00'),('Marketing 1',2,3,'16:00:00','18:00:00'),('Marketing 1',3,1,'16:00:00','18:00:00'),('Marketing 1',3,3,'16:00:00','18:00:00'),('Marketing 2',1,1,'16:00:00','18:30:00'),('Marketing 2',1,3,'16:00:00','18:30:00'),('Marketing 2',2,1,'08:00:00','13:00:00'),('Marketing 2',3,1,'16:00:00','18:30:00'),('Marketing 2',3,3,'16:00:00','18:30:00'),('Marketing 3',1,1,'17:00:00','19:30:00'),('Marketing 3',1,3,'17:00:00','19:30:00'),('Reparac PC Avanzada',1,2,'18:00:00','21:00:00'),('Reparac PC Avanzada',1,4,'18:00:00','21:00:00'),('Reparac PC Avanzada',2,2,'18:00:00','21:00:00'),('Reparac PC Avanzada',2,4,'18:00:00','21:00:00'),('Reparacion PC',1,1,'18:00:00','20:00:00'),('Reparacion PC',1,3,'18:00:00','20:00:00'),('Reparacion PC',2,1,'18:00:00','20:00:00'),('Reparacion PC',2,3,'18:00:00','20:00:00'),('Reparacion PC',3,1,'18:00:00','20:00:00'),('Reparacion PC',3,3,'18:00:00','20:00:00');
/*!40000 ALTER TABLE `cursos_horarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cursos_instructores`
--

DROP TABLE IF EXISTS `cursos_instructores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cursos_instructores` (
  `nom_plan` char(20) NOT NULL,
  `nro_curso` int NOT NULL,
  `cuil` char(20) NOT NULL,
  PRIMARY KEY (`nom_plan`,`nro_curso`,`cuil`),
  KEY `cursos_instructores_instructores_fk` (`cuil`),
  CONSTRAINT `cursos_instructores_curso_fk` FOREIGN KEY (`nom_plan`, `nro_curso`) REFERENCES `cursos` (`nom_plan`, `nro_curso`) ON UPDATE CASCADE,
  CONSTRAINT `cursos_instructores_instructores_fk` FOREIGN KEY (`cuil`) REFERENCES `instructores` (`cuil`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cursos_instructores`
--

LOCK TABLES `cursos_instructores` WRITE;
/*!40000 ALTER TABLE `cursos_instructores` DISABLE KEYS */;
INSERT INTO `cursos_instructores` VALUES ('Marketing 1',1,'55-55555555-5'),('Marketing 1',2,'55-55555555-5'),('Marketing 3',1,'55-55555555-5'),('Marketing 1',3,'66-66666666-6'),('Marketing 2',1,'66-66666666-6'),('Marketing 2',2,'66-66666666-6'),('Marketing 2',3,'66-66666666-6'),('Marketing 3',1,'66-66666666-6'),('Marketing 1',1,'77-77777777-7'),('Marketing 1',2,'77-77777777-7'),('Marketing 1',3,'77-77777777-7'),('Marketing 2',1,'77-77777777-7'),('Marketing 2',3,'77-77777777-7'),('Marketing 3',1,'77-77777777-7'),('Marketing 2',2,'88-88888888-8'),('Reparac PC Avanzada',1,'88-88888888-8'),('Reparac PC Avanzada',2,'88-88888888-8'),('Reparacion PC',1,'88-88888888-8'),('Reparacion PC',3,'88-88888888-8'),('Reparac PC Avanzada',1,'99-99999999-9'),('Reparac PC Avanzada',2,'99-99999999-9'),('Reparacion PC',2,'99-99999999-9'),('Reparacion PC',3,'99-99999999-9');
/*!40000 ALTER TABLE `cursos_instructores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evaluaciones`
--

DROP TABLE IF EXISTS `evaluaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evaluaciones` (
  `nom_plan` char(20) NOT NULL,
  `nro_curso` int NOT NULL,
  `dni` int NOT NULL,
  `nro_examen` int NOT NULL,
  `cuil` char(20) NOT NULL,
  `fecha_evaluacion` date NOT NULL,
  `nota` decimal(9,3) NOT NULL,
  PRIMARY KEY (`nom_plan`,`nro_curso`,`dni`,`nro_examen`),
  KEY `evaluaciones_examenes_fk` (`nom_plan`,`nro_examen`),
  KEY `evaluaciones_instructores_fk` (`cuil`),
  CONSTRAINT `evaluaciones_examenes_fk` FOREIGN KEY (`nom_plan`, `nro_examen`) REFERENCES `examenes` (`nom_plan`, `nro_examen`) ON UPDATE CASCADE,
  CONSTRAINT `evaluaciones_inscripciones_fk` FOREIGN KEY (`nom_plan`, `nro_curso`, `dni`) REFERENCES `inscripciones` (`nom_plan`, `nro_curso`, `dni`) ON UPDATE CASCADE,
  CONSTRAINT `evaluaciones_instructores_fk` FOREIGN KEY (`cuil`) REFERENCES `instructores` (`cuil`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evaluaciones`
--

LOCK TABLES `evaluaciones` WRITE;
/*!40000 ALTER TABLE `evaluaciones` DISABLE KEYS */;
INSERT INTO `evaluaciones` VALUES ('Marketing 1',1,10101010,1,'55-55555555-5','2013-06-15',6.000),('Marketing 1',1,10101010,2,'55-55555555-5','2013-09-29',7.000),('Marketing 1',1,11111111,1,'77-77777777-7','2013-06-15',8.470),('Marketing 1',1,11111111,2,'77-77777777-7','2013-09-29',7.300),('Marketing 1',1,12121212,1,'55-55555555-5','2013-06-15',6.000),('Marketing 1',1,12121212,2,'55-55555555-5','2013-09-29',8.000),('Marketing 1',1,13131313,1,'77-77777777-7','2013-06-15',7.500),('Marketing 1',1,13131313,2,'77-77777777-7','2013-09-29',6.900),('Marketing 1',2,20202020,1,'77-77777777-7','2014-06-15',10.000),('Marketing 1',2,20202020,2,'77-77777777-7','2014-09-29',4.500),('Marketing 1',2,21212121,1,'77-77777777-7','2014-06-15',6.000),('Marketing 1',2,21212121,2,'55-55555555-5','2014-09-29',6.890),('Marketing 1',2,22222222,1,'55-55555555-5','2014-06-15',6.000),('Marketing 1',2,22222222,2,'55-55555555-5','2014-09-29',8.000),('Marketing 2',1,10101010,1,'66-66666666-6','2014-06-30',5.000),('Marketing 2',1,10101010,2,'77-77777777-7','2014-10-31',4.000),('Marketing 2',1,11111111,1,'77-77777777-7','2014-06-30',5.000),('Marketing 2',1,11111111,2,'66-66666666-6','2014-10-31',9.000),('Marketing 2',1,12121212,1,'66-66666666-6','2014-06-30',5.000),('Marketing 2',1,12121212,2,'77-77777777-7','2014-10-31',7.000),('Marketing 2',2,23232323,1,'66-66666666-6','2014-06-29',10.000),('Marketing 2',2,23232323,2,'88-88888888-8','2014-10-27',9.900),('Marketing 2',2,24242424,1,'88-88888888-8','2014-06-29',10.000),('Marketing 2',2,24242424,2,'66-66666666-6','2014-10-27',10.000),('Reparac PC Avanzada',1,15151515,1,'88-88888888-8','2014-05-31',8.440),('Reparac PC Avanzada',1,15151515,2,'99-99999999-9','2014-09-05',9.820),('Reparac PC Avanzada',1,15151515,3,'99-99999999-9','2014-12-14',3.500),('Reparac PC Avanzada',1,17171717,1,'88-88888888-8','2014-05-31',5.420),('Reparac PC Avanzada',1,17171717,2,'88-88888888-8','2014-09-05',4.810),('Reparac PC Avanzada',1,17171717,3,'99-99999999-9','2014-12-14',7.000),('Reparacion PC',1,14141414,1,'99-99999999-9','2013-06-30',6.590),('Reparacion PC',1,14141414,2,'88-88888888-8','2013-10-31',9.000),('Reparacion PC',1,15151515,1,'88-88888888-8','2013-06-30',7.000),('Reparacion PC',1,15151515,2,'99-99999999-9','2013-10-31',8.000),('Reparacion PC',1,16161616,1,'99-99999999-9','2013-06-30',0.000),('Reparacion PC',1,16161616,2,'88-88888888-8','2013-10-31',0.000),('Reparacion PC',1,17171717,1,'88-88888888-8','2013-06-30',10.000),('Reparacion PC',1,17171717,2,'99-99999999-9','2013-10-31',8.000),('Reparacion PC',1,18181818,1,'99-99999999-9','2013-06-30',10.000),('Reparacion PC',1,18181818,2,'88-88888888-8','2013-10-31',10.000),('Reparacion PC',2,22222222,1,'99-99999999-9','2014-06-30',2.000),('Reparacion PC',2,22222222,2,'88-88888888-8','2014-10-31',2.390);
/*!40000 ALTER TABLE `evaluaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `examenes`
--

DROP TABLE IF EXISTS `examenes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `examenes` (
  `nom_plan` char(20) NOT NULL,
  `nro_examen` int NOT NULL,
  PRIMARY KEY (`nom_plan`,`nro_examen`),
  CONSTRAINT `examenes_plan_fk` FOREIGN KEY (`nom_plan`) REFERENCES `plan_capacitacion` (`nom_plan`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `examenes`
--

LOCK TABLES `examenes` WRITE;
/*!40000 ALTER TABLE `examenes` DISABLE KEYS */;
INSERT INTO `examenes` VALUES ('Marketing 1',1),('Marketing 1',2),('Marketing 2',1),('Marketing 2',2),('Marketing 3',1),('Marketing 3',2),('Marketing 3',3),('Marketing 3',4),('Reparac PC Avanzada',1),('Reparac PC Avanzada',2),('Reparac PC Avanzada',3),('Reparacion PC',1),('Reparacion PC',2);
/*!40000 ALTER TABLE `examenes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `examenes_temas`
--

DROP TABLE IF EXISTS `examenes_temas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `examenes_temas` (
  `nom_plan` char(20) NOT NULL,
  `titulo` char(30) NOT NULL,
  `nro_examen` int NOT NULL,
  PRIMARY KEY (`nom_plan`,`titulo`,`nro_examen`),
  KEY `examenes_temas_examenes_fk` (`nom_plan`,`nro_examen`),
  CONSTRAINT `examenes_temas_examenes_fk` FOREIGN KEY (`nom_plan`, `nro_examen`) REFERENCES `examenes` (`nom_plan`, `nro_examen`) ON UPDATE CASCADE,
  CONSTRAINT `examenes_temas_plan_temas_fk` FOREIGN KEY (`nom_plan`, `titulo`) REFERENCES `plan_temas` (`nom_plan`, `titulo`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `examenes_temas`
--

LOCK TABLES `examenes_temas` WRITE;
/*!40000 ALTER TABLE `examenes_temas` DISABLE KEYS */;
INSERT INTO `examenes_temas` VALUES ('Marketing 1','1- Imagen empresarial',1),('Marketing 1','2- Medios de difusion',1),('Marketing 1','3- Publicidad Institucional',2),('Marketing 2','1- Mercados',1),('Marketing 2','2- FODA',1),('Marketing 2','3- Integracion de contenidos',2),('Marketing 3','1-Proteccion de la informacion',1),('Marketing 3','2- Espionage industrial',2),('Marketing 3','3- Difamacion',3),('Marketing 3','4- Robo de cerebros',3),('Marketing 3','5- Sabotaje',4),('Reparac PC Avanzada','1- SO Usuarios',1),('Reparac PC Avanzada','2- SO Avanzados',1),('Reparac PC Avanzada','3- Redes',2),('Reparac PC Avanzada','4- Herramientas Especializadas',3),('Reparac PC Avanzada','5- Reparacion',3),('Reparacion PC','1- Introduccion',1),('Reparacion PC','2- Diagnostico',1),('Reparacion PC','3- Reparacion',2);
/*!40000 ALTER TABLE `examenes_temas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inscripciones`
--

DROP TABLE IF EXISTS `inscripciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inscripciones` (
  `nom_plan` char(20) NOT NULL,
  `nro_curso` int NOT NULL,
  `dni` int NOT NULL,
  `fecha_inscripcion` date NOT NULL,
  PRIMARY KEY (`nom_plan`,`nro_curso`,`dni`),
  KEY `inscripcion_alumnos_fk` (`dni`),
  CONSTRAINT `inscripcion_alumnos_fk` FOREIGN KEY (`dni`) REFERENCES `alumnos` (`dni`) ON UPDATE CASCADE,
  CONSTRAINT `inscripcion_curso_fk` FOREIGN KEY (`nom_plan`, `nro_curso`) REFERENCES `cursos` (`nom_plan`, `nro_curso`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inscripciones`
--

LOCK TABLES `inscripciones` WRITE;
/*!40000 ALTER TABLE `inscripciones` DISABLE KEYS */;
INSERT INTO `inscripciones` VALUES ('Marketing 1',1,10101010,'2013-01-10'),('Marketing 1',1,11111111,'2013-02-20'),('Marketing 1',1,12121212,'2013-01-18'),('Marketing 1',1,13131313,'2013-02-07'),('Marketing 1',2,20202020,'2014-01-15'),('Marketing 1',2,21212121,'2014-01-28'),('Marketing 1',2,22222222,'2014-02-03'),('Marketing 2',1,10101010,'2014-02-11'),('Marketing 2',1,11111111,'2014-01-20'),('Marketing 2',1,12121212,'2014-01-07'),('Marketing 2',2,23232323,'2014-01-14'),('Marketing 2',2,24242424,'2014-02-07'),('Marketing 2',3,10101010,'2015-03-02'),('Marketing 2',3,13131313,'2015-03-09'),('Marketing 2',3,20202020,'2015-01-20'),('Marketing 2',3,22222222,'2015-01-21'),('Marketing 2',3,24242424,'2015-02-28'),('Marketing 3',1,11111111,'2015-01-09'),('Marketing 3',1,12121212,'2015-02-19'),('Marketing 3',1,24242424,'2015-03-28'),('Reparac PC Avanzada',1,15151515,'2014-01-18'),('Reparac PC Avanzada',1,17171717,'2014-01-09'),('Reparac PC Avanzada',2,14141414,'2015-01-28'),('Reparac PC Avanzada',2,17171717,'2015-01-12'),('Reparac PC Avanzada',2,18181818,'2015-01-21'),('Reparacion PC',1,14141414,'2013-02-11'),('Reparacion PC',1,15151515,'2013-02-19'),('Reparacion PC',1,16161616,'2013-01-20'),('Reparacion PC',1,17171717,'2013-01-17'),('Reparacion PC',1,18181818,'2013-01-31'),('Reparacion PC',2,22222222,'2014-01-08'),('Reparacion PC',3,22222222,'2015-01-03');
/*!40000 ALTER TABLE `inscripciones` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `inscripciones_AFTER_INSERT` AFTER INSERT ON `inscripciones` FOR EACH ROW BEGIN
update cursos
set cant_inscriptos=cant_inscriptos + 1
where nom_plan=new.nom_plan and nro_curso=new.nro_curso; 
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `inscripciones_before_del_tr` BEFORE DELETE ON `inscripciones` FOR EACH ROW BEGIN
update cursos
set cant_inscriptos=cant_inscriptos - 1
where nom_plan=old.nom_plan and nro_curso=old.nro_curso;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `instructores`
--

DROP TABLE IF EXISTS `instructores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `instructores` (
  `cuil` char(20) NOT NULL,
  `nombre` varchar(20) NOT NULL,
  `apellido` varchar(20) NOT NULL,
  `tel` varchar(20) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `direccion` varchar(50) DEFAULT NULL,
  `cuil_supervisor` char(20) DEFAULT NULL,
  PRIMARY KEY (`cuil`),
  KEY `instructores_supervisor_fk` (`cuil_supervisor`),
  CONSTRAINT `instructores_supervisor_fk` FOREIGN KEY (`cuil_supervisor`) REFERENCES `instructores` (`cuil`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `instructores`
--

LOCK TABLES `instructores` WRITE;
/*!40000 ALTER TABLE `instructores` DISABLE KEYS */;
INSERT INTO `instructores` VALUES ('30-30303030-3','Rosa','Pelaes','3030303','rpelaes77@afatse_mod.com.ar','9 de Julio 3030','99-99999999-9'),('31-31313131-3','Jacinto','Ibañes','3131313','jibañes@afatse_mod.com.ar','Pte. Roca 3131','99-99999999-9'),('55-55555555-5','Henri','Amiel','5555555','hamiel@afatse_mod.com.ar','Ayacucho 5555',NULL),('66-66666666-6','Franz','Kafka','6666666','fkafka@afatse_mod.com.ar','San Luis 666 6F','55-55555555-5'),('77-77777777-7','Francisco','Umbral','7777777','fumbral@afatse_mod.com.ar','Italia 777','55-55555555-5'),('88-88888888-8','Otto','Wagner','8888888','owagner@afatse_mod.com.ar','Rondeau 888','77-77777777-7'),('99-99999999-9','Elias','Yanes','9999999','eyanes@afatse_mod.com.ar','27 de Febrero 999','88-88888888-8');
/*!40000 ALTER TABLE `instructores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `materiales`
--

DROP TABLE IF EXISTS `materiales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `materiales` (
  `cod_material` char(6) NOT NULL,
  `desc_material` varchar(50) NOT NULL,
  `url_descarga` varchar(50) DEFAULT NULL,
  `autores` varchar(50) DEFAULT NULL,
  `tamanio` decimal(9,3) DEFAULT NULL,
  `fecha_creacion` date DEFAULT NULL,
  `cant_disponible` int DEFAULT NULL,
  `punto_pedido` int DEFAULT NULL,
  `cantidad_a_pedir` int DEFAULT NULL,
  PRIMARY KEY (`cod_material`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `materiales`
--

LOCK TABLES `materiales` WRITE;
/*!40000 ALTER TABLE `materiales` DISABLE KEYS */;
INSERT INTO `materiales` VALUES ('AP-001','Introducción al Marketing','www.afatse_mod.com.ar/apuntes?AP=001','Antonio Gramsci',2.500,'2012-08-01',0,NULL,NULL),('AP-002','Estructura de la PC','www.afatse_mod.com.ar/apuntes?AP=002','Juan Carlos Onetit',3.000,'2012-08-05',0,NULL,NULL),('AP-003','Sectores de Mercado y Trageting','www.afatse_mod.com.ar/apuntes?AP=003','Rafael Alberti',3.900,'2013-05-08',0,NULL,NULL),('AP-004','Sistemas Operativos Modernos','www.afatse_mod.com.ar/apuntes?AP=004','Andrew Tanembaum',4.000,'2013-11-27',0,NULL,NULL),('AP-005','Redes','www.afatse_mod.com.ar/apuntes?AP=005','Andrew Tanembaum',7.300,'2013-12-02',0,NULL,NULL),('AP-006','Imagen y Competencia','www.afatse_mod.com.ar/apuntes?AP=006','Rafael Muñiz Gonzales y Erica de Forifregoro',3.000,'2014-05-04',0,NULL,NULL),('AP-007','Usuarios y Seguridad','www.afatse_mod.com.ar/apuntes?AP=007','Andrew Tanembaum',6.000,'2014-02-08',0,NULL,NULL),('AP-008','Utilidades de diagnostico','www.afatse_mod.com.ar/apuntes?AP=008','Erica de Forifregoro',4.000,'2014-04-09',0,NULL,NULL),('AP-009','Deteccion de hackers','www.afatse_mod.com.ar/apuntes?AP=009','Erica de Forifregoro',5.700,'2014-05-17',0,NULL,NULL),('UT-001','Birome',NULL,NULL,NULL,NULL,98,20,200),('UT-002','Carpeta con metallas',NULL,NULL,NULL,NULL,7,15,100),('UT-003','Hojas A4 lisas',NULL,NULL,NULL,NULL,5500,2000,5000),('UT-004','Diskete 3 1/2',NULL,NULL,NULL,NULL,57,30,100),('UT-005','lapiz negro',NULL,NULL,NULL,NULL,0,30,1000);
/*!40000 ALTER TABLE `materiales` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `materiales_after_ins_tr` AFTER INSERT ON `materiales` FOR EACH ROW BEGIN
if new.cant_disponible is not null then 
	insert into stock_movimientos 
		(cod_material, cantidad_movida, cantidad_restante, usuario_movimiento)
        values
        (new.cod_material, new.cant_disponible, new.cant_disponible, current_user);
end if;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `materiales_before_upd_tr` BEFORE UPDATE ON `materiales` FOR EACH ROW BEGIN
if new.cant_disponible is not null then 
	if old.cant_disponible <> new.cant_disponible then
		insert into
		  stock_movimientos(
			cod_material,
			cantidad_movida,
			cantidad_restante,
			usuario_movimiento
		  )
		values
		  (
			new.cod_material,
			new.cant_disponible - old.cant_disponible,
			new.cant_disponible,
			CURRENT_USER
		  );
	end if;
end if;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `materiales_plan`
--

DROP TABLE IF EXISTS `materiales_plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `materiales_plan` (
  `nom_plan` char(20) NOT NULL,
  `cod_material` char(6) NOT NULL,
  `cant_entrega` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`nom_plan`,`cod_material`),
  KEY `nom_plan` (`nom_plan`),
  KEY `materiales_plan_materiales_fk` (`cod_material`),
  CONSTRAINT `materiales_plan_materiales_fk` FOREIGN KEY (`cod_material`) REFERENCES `materiales` (`cod_material`) ON UPDATE CASCADE,
  CONSTRAINT `materiales_plan_plan_capacitacion_fk` FOREIGN KEY (`nom_plan`) REFERENCES `plan_capacitacion` (`nom_plan`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `materiales_plan`
--

LOCK TABLES `materiales_plan` WRITE;
/*!40000 ALTER TABLE `materiales_plan` DISABLE KEYS */;
INSERT INTO `materiales_plan` VALUES ('Marketing 1','AP-001',0),('Marketing 2','AP-003',0),('Marketing 2','UT-001',1),('Marketing 2','UT-002',1),('Marketing 2','UT-003',20),('Marketing 3','AP-006',0),('Marketing 3','UT-001',1),('Marketing 3','UT-002',1),('Marketing 3','UT-003',20),('Reparac PC Avanzada','AP-004',0),('Reparac PC Avanzada','AP-005',0),('Reparac PC Avanzada','AP-007',0),('Reparac PC Avanzada','UT-001',1),('Reparac PC Avanzada','UT-002',1),('Reparac PC Avanzada','UT-003',20),('Reparacion PC','AP-002',0),('Reparacion PC','UT-001',1),('Reparacion PC','UT-002',1),('Reparacion PC','UT-003',20);
/*!40000 ALTER TABLE `materiales_plan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plan_capacitacion`
--

DROP TABLE IF EXISTS `plan_capacitacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `plan_capacitacion` (
  `nom_plan` char(20) NOT NULL,
  `desc_plan` varchar(100) NOT NULL,
  `hs` int NOT NULL,
  `modalidad` varchar(20) NOT NULL,
  PRIMARY KEY (`nom_plan`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plan_capacitacion`
--

LOCK TABLES `plan_capacitacion` WRITE;
/*!40000 ALTER TABLE `plan_capacitacion` DISABLE KEYS */;
INSERT INTO `plan_capacitacion` VALUES ('Marketing 1','Dar a conocer su empresa, crear la imagen deseada, difusion en medios adecuados',100,'A Distancia'),('Marketing 2','Seleccion del sector de mercado. Matriz FODA.',150,'Semipresencial'),('Marketing 3','Competencia Desleal',180,'Semiresencial'),('Reparac PC Avanzada','Configuración de SO Linux/Windows y de red. Herramientas de diagnostico especializadas y reparacion',240,'Presencial'),('Reparacion PC','Identidifar componentes de una pc, diagnosticar problemas y reemplazo de partes dañadas',100,'Presencial');
/*!40000 ALTER TABLE `plan_capacitacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plan_temas`
--

DROP TABLE IF EXISTS `plan_temas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `plan_temas` (
  `nom_plan` char(20) NOT NULL,
  `titulo` char(30) NOT NULL,
  `detalle` varchar(75) NOT NULL,
  PRIMARY KEY (`nom_plan`,`titulo`),
  CONSTRAINT `plan_temas_plan_fk` FOREIGN KEY (`nom_plan`) REFERENCES `plan_capacitacion` (`nom_plan`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plan_temas`
--

LOCK TABLES `plan_temas` WRITE;
/*!40000 ALTER TABLE `plan_temas` DISABLE KEYS */;
INSERT INTO `plan_temas` VALUES ('Marketing 1','1- Imagen empresarial','Crear la imagen deseada para la empresa'),('Marketing 1','2- Medios de difusion','Evaluacion y análisis de medios de difusion para publicitar'),('Marketing 1','3- Publicidad Institucional','Creacion de mensaje publicitario'),('Marketing 2','1- Mercados','Segmentos de mercado. Targeting'),('Marketing 2','2- FODA','Evaluación de FODA de le empresa y su aplicacion'),('Marketing 2','3- Integracion de contenidos','Targeting basado en matriz FODA y potenciación de la empresa basada en FODA'),('Marketing 3','1-Proteccion de la informacion','Proteccion contra espionaje industrial'),('Marketing 3','2- Espionage industrial','Identificacion de posible espias en competidores'),('Marketing 3','3- Difamacion','Tecnicas de difamacion de competidores'),('Marketing 3','4- Robo de cerebros','Identificar RRHH claves en competidores y traerlos a la empresa'),('Marketing 3','5- Sabotaje','Planificacion y ejecucion de sabotajes. Destruir evidencia comprometedora'),('Reparac PC Avanzada','1- SO Usuarios','Uso e instalacion. Windows 98, XP y Vista'),('Reparac PC Avanzada','2- SO Avanzados','Uso e instalacion. Linux Ubuntu, Debian y Slackware. Windows 2003 y 2014'),('Reparac PC Avanzada','3- Redes','Instalacion y configuracion de redes en todos los SO antes vistos '),('Reparac PC Avanzada','4- Herramientas Especializadas','Uso de herramientas especializadas para detectar errores en redes y SOs'),('Reparac PC Avanzada','5- Reparacion','Reparacion de problemas frecuentes y prevencion'),('Reparacion PC','1- Introduccion','Componentes de una PC. Identificacion y funcion'),('Reparacion PC','2- Diagnostico','Reconocimiento de problemas comunes en el harware y sus causas'),('Reparacion PC','3- Reparacion','Reemplazo de partes defectuosas determinadas durante el diagnostico');
/*!40000 ALTER TABLE `plan_temas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proveedores`
--

DROP TABLE IF EXISTS `proveedores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `proveedores` (
  `cuit` char(20) NOT NULL,
  `razon_social` varchar(50) NOT NULL,
  `direccion` varchar(50) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`cuit`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedores`
--

LOCK TABLES `proveedores` WRITE;
/*!40000 ALTER TABLE `proveedores` DISABLE KEYS */;
INSERT INTO `proveedores` VALUES ('11-11111111-1','Data Source','Nansen 1111','1111111'),('22-22222222-2','Libreria REDAL','San Martin 2222','2222222'),('33-33333333-3','LAEROB','Richieri 3333','3333333'),('44-44444444-4','INSUBOX','Valparaiso 4444','4444444');
/*!40000 ALTER TABLE `proveedores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proveedores_materiales`
--

DROP TABLE IF EXISTS `proveedores_materiales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `proveedores_materiales` (
  `cuit` char(20) NOT NULL,
  `cod_material` char(6) NOT NULL,
  PRIMARY KEY (`cuit`,`cod_material`),
  KEY `proveedores_materiales_materiales_fk` (`cod_material`),
  CONSTRAINT `proveedores_materiales_materiales_fk` FOREIGN KEY (`cod_material`) REFERENCES `materiales` (`cod_material`) ON UPDATE CASCADE,
  CONSTRAINT `proveedores_materiales_proveedores_fk` FOREIGN KEY (`cuit`) REFERENCES `proveedores` (`cuit`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedores_materiales`
--

LOCK TABLES `proveedores_materiales` WRITE;
/*!40000 ALTER TABLE `proveedores_materiales` DISABLE KEYS */;
INSERT INTO `proveedores_materiales` VALUES ('22-22222222-2','UT-001'),('33-33333333-3','UT-001'),('22-22222222-2','UT-002'),('33-33333333-3','UT-003'),('11-11111111-1','UT-004'),('44-44444444-4','UT-004');
/*!40000 ALTER TABLE `proveedores_materiales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_movimientos`
--

DROP TABLE IF EXISTS `stock_movimientos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_movimientos` (
  `cod_material` char(6) NOT NULL,
  `fecha_movimiento` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `cantidad_movida` int NOT NULL,
  `cantidad_restante` int NOT NULL,
  `usuario_movimiento` varchar(50) NOT NULL,
  PRIMARY KEY (`cod_material`,`fecha_movimiento`),
  CONSTRAINT `stock_movimientos_fk` FOREIGN KEY (`cod_material`) REFERENCES `materiales` (`cod_material`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_movimientos`
--

LOCK TABLES `stock_movimientos` WRITE;
/*!40000 ALTER TABLE `stock_movimientos` DISABLE KEYS */;
INSERT INTO `stock_movimientos` VALUES ('UT-001','2025-10-26 20:10:27',10,103,'root@localhost'),('UT-001','2025-10-26 20:10:46',-5,98,'root@localhost'),('UT-005','2025-10-25 23:20:47',100,100,'root@localhost'),('UT-005','2025-10-25 23:24:00',700,800,'root@localhost'),('UT-005','2025-10-25 23:25:23',200,1000,'root@localhost'),('UT-005','2025-10-25 23:26:21',-990,10,'root@localhost'),('UT-005','2025-10-25 23:30:06',-10,0,'root@localhost');
/*!40000 ALTER TABLE `stock_movimientos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `valores_plan`
--

DROP TABLE IF EXISTS `valores_plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `valores_plan` (
  `nom_plan` varchar(20) NOT NULL,
  `fecha_desde_plan` date NOT NULL,
  `valor_plan` decimal(9,3) NOT NULL,
  `usuario_alta` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`nom_plan`,`fecha_desde_plan`),
  CONSTRAINT `valores_plan_plan_fk` FOREIGN KEY (`nom_plan`) REFERENCES `plan_capacitacion` (`nom_plan`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `valores_plan`
--

LOCK TABLES `valores_plan` WRITE;
/*!40000 ALTER TABLE `valores_plan` DISABLE KEYS */;
INSERT INTO `valores_plan` VALUES ('Marketing 1','2013-01-05',25.000,NULL),('Marketing 1','2013-06-01',28.000,NULL),('Marketing 1','2014-02-01',30.000,NULL),('Marketing 1','2014-04-01',37.000,NULL),('Marketing 1','2014-06-01',45.000,NULL),('Marketing 1','2014-08-01',54.000,NULL),('Marketing 1','2014-12-01',65.000,NULL),('Marketing 2','2014-02-01',50.000,NULL),('Marketing 2','2014-04-01',60.000,NULL),('Marketing 2','2014-06-01',73.000,NULL),('Marketing 2','2014-08-01',88.000,NULL),('Marketing 2','2015-01-02',60.000,NULL),('Marketing 3','2015-01-02',200.000,NULL),('Reparac PC Avanzada','2014-02-01',80.000,NULL),('Reparac PC Avanzada','2014-04-01',95.000,NULL),('Reparac PC Avanzada','2014-06-01',120.000,NULL),('Reparac PC Avanzada','2014-08-01',145.000,NULL),('Reparac PC Avanzada','2015-01-02',125.000,NULL),('Reparac PC Avanzada','2015-04-01',135.000,NULL),('Reparacion PC','2013-01-05',37.000,NULL),('Reparacion PC','2013-06-01',42.000,NULL),('Reparacion PC','2014-02-01',45.000,NULL),('Reparacion PC','2014-04-01',54.000,NULL),('Reparacion PC','2014-06-01',65.000,NULL),('Reparacion PC','2014-08-01',80.000,NULL),('Reparacion PC','2015-01-02',80.000,NULL);
/*!40000 ALTER TABLE `valores_plan` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `valores_plan_before_ins_tr` BEFORE INSERT ON `valores_plan` FOR EACH ROW BEGIN
set new.usuario_alta=CURRENT_USER; 
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Dumping events for database 'afatse_mod'
--

--
-- Dumping routines for database 'afatse_mod'
--
/*!50003 DROP FUNCTION IF EXISTS `alumnos_deudas_a_fecha` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `alumnos_deudas_a_fecha`(p_dni int,
    p_fecha date) RETURNS int
    READS SQL DATA
BEGIN
declare v_cuotas_adeudadas int;

select
  count(1) into v_cuotas_adeudadas
from
  cuotas
where
  dni = p_dni
  and fecha_emision <= p_fecha
  and fecha_pago is null;

return v_cuotas_adeudadas;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stock_egreso` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `stock_egreso`(in p_cod_mat char(6), in p_cant_movida integer(11), out p_stock integer(11))
BEGIN
call stock_movimiento(p_cod_mat, (-1) * p_cant_movida, p_stock);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stock_ingreso` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `stock_ingreso`(in p_cod_mat char(6), in p_cant_movida integer(11), out p_stock integer(11))
BEGIN
call stock_movimiento(p_cod_mat, p_cant_movida, p_stock);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stock_movimiento` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `stock_movimiento`(in cod_mat char(6), in cant_movida integer(11), out stock integer(11))
BEGIN
     declare url varchar(50);
     
     start transaction;
     select url_descarga into url from materiales where
    cod_material = cod_mat;
    
    if url is null then 
		update materiales set cant_disponible = cant_disponible + cant_movida
        where cod_material=cod_mat;
	end if; 
    
    SELECT cant_disponible INTO stock 
    FROM materiales
	WHERE cod_material = cod_mat;       

	if stock>=0 then
		commit;
	else
		rollback; 
	
		select cant_disponible
		into stock from materiales
		where cod_material = cod_mat;
	end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `todos_los_alumnos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `todos_los_alumnos`()
BEGIN
select * from alumnos;
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

-- Dump completed on 2025-11-19 15:08:30
