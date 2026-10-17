-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: internship_management
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `internship_management`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `internship_management` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `internship_management`;

--
-- Table structure for table `allowances`
--

DROP TABLE IF EXISTS `allowances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `allowances` (
  `allowance_id` int(11) NOT NULL AUTO_INCREMENT,
  `enrollment_id` int(11) NOT NULL,
  `allowance_type` varchar(50) NOT NULL,
  `period` varchar(20) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `status` varchar(30) DEFAULT 'PENDING',
  `paid_at` datetime DEFAULT NULL,
  `created_by` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`allowance_id`),
  UNIQUE KEY `uk_allowance` (`enrollment_id`,`allowance_type`,`period`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `allowances_ibfk_1` FOREIGN KEY (`enrollment_id`) REFERENCES `program_enrollments` (`enrollment_id`) ON DELETE CASCADE,
  CONSTRAINT `allowances_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `allowances`
--

LOCK TABLES `allowances` WRITE;
/*!40000 ALTER TABLE `allowances` DISABLE KEYS */;
INSERT INTO `allowances` VALUES (1,1,'Phụ cấp thực tập','2026-09',3000000.00,'PAID','2026-10-05 09:00:00',1,'2026-10-17 15:50:31','2026-10-17 16:00:32'),(2,1,'Phụ cấp thực tập','2026-10',3000000.00,'PAID','2026-10-17 23:03:42',1,'2026-10-17 15:50:31','2026-10-17 16:03:42'),(3,2,'Phụ cấp thực tập','2026-10',2500000.00,'PAID','2026-10-17 23:03:40',1,'2026-10-17 15:50:31','2026-10-17 16:03:40');
/*!40000 ALTER TABLE `allowances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `applications`
--

DROP TABLE IF EXISTS `applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `applications` (
  `application_id` int(11) NOT NULL AUTO_INCREMENT,
  `intern_id` int(11) NOT NULL,
  `status` varchar(30) DEFAULT 'PENDING',
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `reviewed_by` bigint(20) DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `reject_reason` text DEFAULT NULL,
  PRIMARY KEY (`application_id`),
  KEY `intern_id` (`intern_id`),
  KEY `reviewed_by` (`reviewed_by`),
  CONSTRAINT `applications_ibfk_1` FOREIGN KEY (`intern_id`) REFERENCES `intern_profiles` (`profile_id`) ON DELETE CASCADE,
  CONSTRAINT `applications_ibfk_2` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `applications`
--

LOCK TABLES `applications` WRITE;
/*!40000 ALTER TABLE `applications` DISABLE KEYS */;
INSERT INTO `applications` VALUES (1,1,'APPROVED','2026-09-01 13:30:00',1,'2026-09-03 15:00:00',NULL),(2,2,'APPROVED','2026-09-10 19:15:00',1,'2026-10-16 18:20:22',NULL),(3,3,'REJECTED','2026-09-05 14:00:00',1,'2026-09-07 21:30:00','─Éiß╗âm GPA chã░a ─æß║ít y├¬u cß║ºu tß╗æi thiß╗âu ─æß╗út 1'),(4,4,'APPROVED','2026-10-15 15:28:14',1,'2026-10-16 18:34:47',NULL);
/*!40000 ALTER TABLE `applications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendances`
--

DROP TABLE IF EXISTS `attendances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attendances` (
  `attendance_id` int(11) NOT NULL AUTO_INCREMENT,
  `enrollment_id` int(11) NOT NULL,
  `work_date` date NOT NULL,
  `check_in_time` datetime NOT NULL,
  `check_out_time` datetime DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`attendance_id`),
  UNIQUE KEY `uq_attendance_day` (`enrollment_id`,`work_date`),
  KEY `idx_attendance_enrollment` (`enrollment_id`,`work_date`),
  CONSTRAINT `attendances_ibfk_1` FOREIGN KEY (`enrollment_id`) REFERENCES `program_enrollments` (`enrollment_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendances`
--

LOCK TABLES `attendances` WRITE;
/*!40000 ALTER TABLE `attendances` DISABLE KEYS */;
INSERT INTO `attendances` VALUES (1,1,'2026-10-15','2026-10-15 22:57:19',NULL,NULL,'2026-10-15 15:57:19'),(2,2,'2026-10-15','2026-10-15 08:05:00','2026-10-15 17:55:00','Đúng giờ','2026-10-16 18:34:47');
/*!40000 ALTER TABLE `attendances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audit_logs` (
  `audit_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `actor_user_id` bigint(20) DEFAULT NULL,
  `action` varchar(64) NOT NULL,
  `object_type` varchar(64) NOT NULL,
  `object_id` bigint(20) DEFAULT NULL,
  `occurred_at` timestamp(6) NOT NULL DEFAULT current_timestamp(6),
  `result` enum('SUCCESS','FAILURE') NOT NULL,
  PRIMARY KEY (`audit_id`),
  KEY `idx_audit_time` (`occurred_at`,`audit_id`),
  KEY `idx_audit_actor_time` (`actor_user_id`,`occurred_at`),
  KEY `idx_audit_action_time` (`action`,`occurred_at`)
) ENGINE=InnoDB AUTO_INCREMENT=180 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` VALUES (1,1,'LOGIN','USER',1,'2026-10-15 15:18:15.817721','SUCCESS'),(2,NULL,'LOGIN','USER',NULL,'2026-10-15 15:18:21.240899','FAILURE'),(3,NULL,'LOGIN','USER',NULL,'2026-10-15 15:18:26.962725','FAILURE'),(4,6,'LOGIN','USER',6,'2026-10-15 15:18:45.782965','SUCCESS'),(5,5,'LOGIN','USER',5,'2026-10-15 15:18:52.089528','SUCCESS'),(6,2,'LOGIN','USER',2,'2026-10-15 15:18:57.168312','SUCCESS'),(7,6,'LOGIN','USER',6,'2026-10-15 15:19:36.000751','SUCCESS'),(8,6,'LOGIN','USER',6,'2026-10-15 15:19:50.898678','SUCCESS'),(9,6,'LOGIN','USER',6,'2026-10-15 15:20:08.489997','SUCCESS'),(10,NULL,'REGISTER','USER',7,'2026-10-15 15:26:45.261761','SUCCESS'),(11,7,'LOGIN','USER',7,'2026-10-15 15:26:55.882418','SUCCESS'),(12,7,'LOGOUT','USER',7,'2026-10-15 15:28:32.294142','SUCCESS'),(13,1,'LOGIN','USER',1,'2026-10-15 15:30:43.400475','SUCCESS'),(14,2,'LOGIN','USER',2,'2026-10-15 15:56:08.583137','SUCCESS'),(15,2,'LOGIN','USER',2,'2026-10-15 15:56:19.755153','SUCCESS'),(16,2,'LOGIN','USER',2,'2026-10-15 15:56:26.271527','SUCCESS'),(17,2,'LOGIN','USER',2,'2026-10-15 15:56:32.628078','SUCCESS'),(18,2,'LOGIN','USER',2,'2026-10-15 15:56:38.584684','SUCCESS'),(19,2,'LOGIN','USER',2,'2026-10-15 15:56:49.140326','SUCCESS'),(20,2,'LOGIN','USER',2,'2026-10-15 15:57:19.433222','SUCCESS'),(21,5,'LOGIN','USER',5,'2026-10-15 15:57:30.714462','SUCCESS'),(22,1,'LOGIN','USER',1,'2026-10-15 15:57:31.063792','SUCCESS'),(23,5,'LOGIN','USER',5,'2026-10-15 15:57:48.304311','SUCCESS'),(24,1,'LOGIN','USER',1,'2026-10-15 15:57:48.495758','SUCCESS'),(25,2,'LOGIN','USER',2,'2026-10-15 15:57:57.216900','SUCCESS'),(26,5,'LOGIN','USER',5,'2026-10-15 15:59:39.554282','SUCCESS'),(27,5,'LOGOUT','USER',5,'2026-10-15 16:00:15.694172','SUCCESS'),(28,7,'LOGIN','USER',7,'2026-10-15 16:00:22.660209','SUCCESS'),(29,7,'LOGOUT','USER',7,'2026-10-15 16:01:20.052158','SUCCESS'),(30,5,'LOGIN','USER',5,'2026-10-15 16:01:25.424772','SUCCESS'),(31,5,'LOGIN','USER',5,'2026-10-15 16:05:06.695355','SUCCESS'),(32,5,'LOGIN','USER',5,'2026-10-15 16:05:20.985674','SUCCESS'),(33,5,'LOGIN','USER',5,'2026-10-15 16:09:43.240414','SUCCESS'),(34,2,'LOGIN','USER',2,'2026-10-15 16:09:43.581551','SUCCESS'),(35,1,'LOGIN','USER',1,'2026-10-15 16:09:58.807952','SUCCESS'),(36,5,'LOGIN','USER',5,'2026-10-15 16:10:48.724674','SUCCESS'),(37,5,'LOGIN','USER',5,'2026-10-15 16:24:25.679459','SUCCESS'),(38,5,'LOGIN','USER',5,'2026-10-15 16:24:38.128328','SUCCESS'),(39,5,'LOGIN','USER',5,'2026-10-15 16:50:26.604566','SUCCESS'),(40,5,'LOGOUT','USER',5,'2026-10-15 16:51:58.778586','SUCCESS'),(41,7,'LOGIN','USER',7,'2026-10-15 16:52:04.749515','SUCCESS'),(42,7,'LOGOUT','USER',7,'2026-10-15 16:52:49.687026','SUCCESS'),(43,6,'LOGIN','USER',6,'2026-10-15 16:53:30.544549','SUCCESS'),(44,1,'LOGIN','USER',1,'2026-10-16 16:54:51.702952','SUCCESS'),(45,7,'LOGIN','USER',7,'2026-10-16 16:55:57.609479','SUCCESS'),(46,7,'LOGOUT','USER',7,'2026-10-16 16:56:20.855690','SUCCESS'),(47,5,'LOGIN','USER',5,'2026-10-16 16:56:26.604892','SUCCESS'),(48,5,'LOGOUT','USER',5,'2026-10-16 17:07:32.119687','SUCCESS'),(49,5,'LOGIN','USER',5,'2026-10-16 17:10:17.825715','SUCCESS'),(50,1,'LOGIN','USER',1,'2026-10-16 17:11:20.644905','SUCCESS'),(51,5,'LOGIN','USER',5,'2026-10-16 17:13:49.734725','SUCCESS'),(52,5,'LOGIN','USER',5,'2026-10-16 17:35:11.719236','SUCCESS'),(53,5,'LOGIN','USER',5,'2026-10-16 17:35:28.382896','SUCCESS'),(54,5,'LOGIN','USER',5,'2026-10-16 17:35:51.666297','SUCCESS'),(55,5,'LOGIN','USER',5,'2026-10-16 17:36:11.821240','SUCCESS'),(56,5,'LOGIN','USER',5,'2026-10-16 17:36:24.075767','SUCCESS'),(57,2,'LOGIN','USER',2,'2026-10-16 17:36:32.255700','SUCCESS'),(58,1,'LOGIN','USER',1,'2026-10-16 17:36:39.108843','SUCCESS'),(59,5,'LOGIN','USER',5,'2026-10-16 17:38:47.947229','SUCCESS'),(60,5,'MEETING_CREATE','MEETING',1,'2026-10-16 17:52:51.387837','SUCCESS'),(61,5,'LOGIN','USER',5,'2026-10-16 18:17:43.837511','SUCCESS'),(62,5,'LOGIN','USER',5,'2026-10-16 18:17:44.565844','SUCCESS'),(63,2,'LOGIN','USER',2,'2026-10-16 18:17:53.596126','SUCCESS'),(64,5,'LOGIN','USER',5,'2026-10-16 18:18:37.015702','SUCCESS'),(65,5,'LOGOUT','USER',5,'2026-10-16 18:19:39.652017','SUCCESS'),(66,1,'LOGIN','USER',1,'2026-10-16 18:19:45.850621','SUCCESS'),(67,NULL,'LOGIN','USER',NULL,'2026-10-16 18:26:12.741898','FAILURE'),(68,1,'LOGIN','USER',1,'2026-10-16 18:26:42.052170','SUCCESS'),(69,6,'LOGIN','USER',6,'2026-10-16 18:30:37.331896','SUCCESS'),(70,6,'ACCOUNT_CREATE','USER',8,'2026-10-16 18:31:53.047832','SUCCESS'),(71,6,'LOGOUT','USER',6,'2026-10-16 18:32:21.833968','SUCCESS'),(72,8,'LOGIN','USER',8,'2026-10-16 18:32:29.155320','SUCCESS'),(73,8,'LOGOUT','USER',8,'2026-10-16 18:32:41.510262','SUCCESS'),(74,1,'LOGIN','USER',1,'2026-10-16 18:38:27.697399','SUCCESS'),(75,8,'LOGIN','USER',8,'2026-10-16 18:40:18.653853','SUCCESS'),(76,1,'LOGIN','USER',1,'2026-10-16 18:46:30.693664','SUCCESS'),(77,1,'LOGIN','USER',1,'2026-10-16 18:48:36.940939','SUCCESS'),(78,1,'LOGIN','USER',1,'2026-10-16 18:51:20.625028','SUCCESS'),(79,1,'LOGIN','USER',1,'2026-10-16 18:51:42.663810','SUCCESS'),(80,1,'LOGIN','USER',1,'2026-10-16 18:51:50.893620','SUCCESS'),(81,8,'LOGIN','USER',8,'2026-10-16 18:53:42.569251','SUCCESS'),(82,8,'LOGOUT','USER',8,'2026-10-16 18:54:05.662400','SUCCESS'),(83,6,'LOGIN','USER',6,'2026-10-16 18:54:08.854987','SUCCESS'),(84,6,'LOGIN','USER',6,'2026-10-16 18:59:28.939455','SUCCESS'),(85,6,'LOGIN','USER',6,'2026-10-16 19:00:00.230892','SUCCESS'),(86,8,'LOGIN','USER',8,'2026-10-16 19:05:03.848362','SUCCESS'),(87,6,'LOGIN','USER',6,'2026-10-16 19:10:49.713458','SUCCESS'),(88,1,'LOGIN','USER',1,'2026-10-16 19:11:11.181583','SUCCESS'),(89,5,'LOGIN','USER',5,'2026-10-16 19:11:21.777946','SUCCESS'),(90,2,'LOGIN','USER',2,'2026-10-16 19:11:31.281457','SUCCESS'),(91,2,'LOGIN','USER',2,'2026-10-16 19:11:48.219233','SUCCESS'),(92,NULL,'LOGIN','USER',NULL,'2026-10-16 19:11:58.443216','FAILURE'),(93,5,'LOGIN','USER',5,'2026-10-16 19:13:50.038760','SUCCESS'),(94,5,'LOGOUT','USER',5,'2026-10-16 19:14:13.771569','SUCCESS'),(95,6,'LOGIN','USER',6,'2026-10-16 19:14:17.906732','SUCCESS'),(96,6,'ROLE_CHANGE','USER',1,'2026-10-16 19:14:43.869706','SUCCESS'),(97,6,'LOGOUT','USER',6,'2026-10-16 19:14:46.405406','SUCCESS'),(98,1,'LOGIN','USER',1,'2026-10-16 19:14:54.427720','SUCCESS'),(99,1,'LOGOUT','USER',1,'2026-10-16 19:14:59.862135','SUCCESS'),(100,6,'LOGIN','USER',6,'2026-10-16 19:15:05.740969','SUCCESS'),(101,6,'ROLE_CHANGE','USER',1,'2026-10-16 19:15:14.020027','SUCCESS'),(102,6,'LOGOUT','USER',6,'2026-10-16 19:15:59.272423','SUCCESS'),(103,7,'LOGIN','USER',7,'2026-10-16 19:16:12.395649','SUCCESS'),(104,6,'LOGIN','USER',6,'2026-10-17 15:45:38.265232','SUCCESS'),(105,1,'LOGIN','USER',1,'2026-10-17 15:45:38.621206','SUCCESS'),(106,5,'LOGIN','USER',5,'2026-10-17 15:45:40.698575','SUCCESS'),(107,2,'LOGIN','USER',2,'2026-10-17 15:45:40.835405','SUCCESS'),(108,6,'LOGIN','USER',6,'2026-10-17 15:46:33.342562','SUCCESS'),(109,1,'LOGIN','USER',1,'2026-10-17 15:46:33.826350','SUCCESS'),(110,5,'LOGIN','USER',5,'2026-10-17 15:46:35.164607','SUCCESS'),(111,2,'LOGIN','USER',2,'2026-10-17 15:46:35.332580','SUCCESS'),(112,1,'LOGIN','USER',1,'2026-10-17 15:48:39.376692','SUCCESS'),(113,1,'LOGIN','USER',1,'2026-10-17 15:49:30.915851','SUCCESS'),(114,6,'LOGIN','USER',6,'2026-10-17 15:50:47.003466','SUCCESS'),(115,1,'LOGIN','USER',1,'2026-10-17 15:50:47.354830','SUCCESS'),(116,5,'LOGIN','USER',5,'2026-10-17 15:50:47.828030','SUCCESS'),(117,2,'LOGIN','USER',2,'2026-10-17 15:50:47.986375','SUCCESS'),(118,5,'LOGIN','USER',5,'2026-10-17 15:51:04.088757','SUCCESS'),(119,2,'LOGIN','USER',2,'2026-10-17 15:51:04.265965','SUCCESS'),(120,1,'LOGIN','USER',1,'2026-10-17 15:51:04.549623','SUCCESS'),(121,5,'LOGIN','USER',5,'2026-10-17 15:51:24.267345','SUCCESS'),(122,2,'LOGIN','USER',2,'2026-10-17 15:51:24.460864','SUCCESS'),(123,1,'LOGIN','USER',1,'2026-10-17 15:51:24.780267','SUCCESS'),(124,6,'LOGIN','USER',6,'2026-10-17 15:58:16.903885','SUCCESS'),(125,6,'LOGOUT','USER',6,'2026-10-17 15:58:44.129955','SUCCESS'),(126,1,'LOGIN','USER',1,'2026-10-17 15:58:48.726529','SUCCESS'),(127,1,'LOGIN','USER',1,'2026-10-17 16:00:51.981952','SUCCESS'),(128,1,'LOGIN','USER',1,'2026-10-17 16:01:20.800588','SUCCESS'),(129,1,'LOGOUT','USER',1,'2026-10-17 16:02:13.797225','SUCCESS'),(130,5,'LOGIN','USER',5,'2026-10-17 16:02:22.019361','SUCCESS'),(131,5,'LOGOUT','USER',5,'2026-10-17 16:02:36.397299','SUCCESS'),(132,7,'LOGIN','USER',7,'2026-10-17 16:02:39.789663','SUCCESS'),(133,7,'LOGOUT','USER',7,'2026-10-17 16:03:17.435117','SUCCESS'),(134,1,'LOGIN','USER',1,'2026-10-17 16:03:20.853076','SUCCESS'),(135,6,'LOGIN','USER',6,'2026-10-17 16:18:37.519428','SUCCESS'),(136,1,'LOGIN','USER',1,'2026-10-17 16:18:38.500370','SUCCESS'),(137,5,'LOGIN','USER',5,'2026-10-17 16:18:41.437824','SUCCESS'),(138,2,'LOGIN','USER',2,'2026-10-17 16:18:41.720797','SUCCESS'),(139,NULL,'LOGIN','USER',NULL,'2026-10-17 16:19:55.063722','FAILURE'),(140,NULL,'LOGIN','USER',NULL,'2026-10-17 16:20:05.165403','FAILURE'),(141,NULL,'LOGIN','USER',NULL,'2026-10-17 16:20:28.769614','FAILURE'),(142,NULL,'LOGIN','USER',NULL,'2026-10-17 16:20:39.908065','FAILURE'),(143,NULL,'LOGIN','USER',NULL,'2026-10-17 16:21:03.929060','FAILURE'),(144,1,'LOGIN','USER',1,'2026-10-17 16:21:04.197055','SUCCESS'),(145,NULL,'LOGIN','USER',NULL,'2026-10-17 16:21:23.739854','FAILURE'),(146,1,'LOGIN','USER',1,'2026-10-17 16:21:24.031760','SUCCESS'),(147,NULL,'LOGIN','USER',NULL,'2026-10-17 16:21:35.164077','FAILURE'),(148,1,'LOGIN','USER',1,'2026-10-17 16:21:35.425705','SUCCESS'),(149,NULL,'LOGIN','USER',NULL,'2026-10-17 16:21:57.174007','FAILURE'),(150,1,'LOGIN','USER',1,'2026-10-17 16:21:57.490820','SUCCESS'),(151,NULL,'LOGIN','USER',NULL,'2026-10-17 16:22:12.866741','FAILURE'),(152,1,'LOGIN','USER',1,'2026-10-17 16:22:13.153028','SUCCESS'),(153,1,'MEETING_CREATE','MEETING',2,'2026-10-17 16:22:13.288724','SUCCESS'),(154,8,'LOGIN','USER',8,'2026-10-17 16:23:14.730436','SUCCESS'),(155,2,'LOGIN','USER',2,'2026-10-17 16:26:26.721366','SUCCESS'),(156,NULL,'LOGIN','USER',NULL,'2026-10-17 16:26:27.122607','FAILURE'),(157,8,'LOGIN','USER',8,'2026-10-17 16:26:27.448899','SUCCESS'),(158,8,'LOGIN','USER',8,'2026-10-17 16:27:02.999621','SUCCESS'),(159,8,'LOGIN','USER',8,'2026-10-17 16:30:22.610457','SUCCESS'),(160,8,'LOGIN','USER',8,'2026-10-17 16:30:37.013576','SUCCESS'),(161,8,'LOGIN','USER',8,'2026-10-17 16:35:41.361227','SUCCESS'),(162,NULL,'LOGIN','USER',NULL,'2026-10-17 16:36:06.817540','FAILURE'),(163,8,'LOGIN','USER',8,'2026-10-17 16:36:07.107080','SUCCESS'),(164,NULL,'LOGIN','USER',NULL,'2026-10-17 16:36:41.734726','FAILURE'),(165,8,'LOGIN','USER',8,'2026-10-17 16:36:42.041825','SUCCESS'),(166,NULL,'LOGIN','USER',NULL,'2026-10-17 16:37:55.254436','FAILURE'),(167,8,'LOGIN','USER',8,'2026-10-17 16:37:55.544935','SUCCESS'),(168,1,'LOGIN','USER',1,'2026-10-17 16:37:56.160239','SUCCESS'),(169,6,'LOGIN','USER',6,'2026-10-17 16:38:04.949232','SUCCESS'),(170,1,'LOGIN','USER',1,'2026-10-17 16:38:05.715894','SUCCESS'),(171,5,'LOGIN','USER',5,'2026-10-17 16:38:06.530590','SUCCESS'),(172,2,'LOGIN','USER',2,'2026-10-17 16:38:06.733419','SUCCESS'),(173,8,'LOGIN','USER',8,'2026-10-17 16:39:00.778613','SUCCESS'),(174,8,'LOGOUT','USER',8,'2026-10-17 16:40:27.094381','SUCCESS'),(175,1,'LOGIN','USER',1,'2026-10-17 16:40:33.059832','SUCCESS'),(176,1,'LOGOUT','USER',1,'2026-10-17 16:41:49.280598','SUCCESS'),(177,5,'LOGIN','USER',5,'2026-10-17 16:41:55.151924','SUCCESS'),(178,5,'LOGOUT','USER',5,'2026-10-17 16:42:23.639521','SUCCESS'),(179,2,'LOGIN','USER',2,'2026-10-17 16:42:27.582012','SUCCESS');
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contracts`
--

DROP TABLE IF EXISTS `contracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contracts` (
  `contract_id` int(11) NOT NULL AUTO_INCREMENT,
  `application_id` int(11) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` bigint(20) NOT NULL,
  `mime_type` varchar(100) NOT NULL,
  `uploaded_by` bigint(20) NOT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` varchar(30) DEFAULT 'PENDING_CONFIRMATION',
  `confirmed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`contract_id`),
  UNIQUE KEY `application_id` (`application_id`),
  KEY `uploaded_by` (`uploaded_by`),
  CONSTRAINT `contracts_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `applications` (`application_id`) ON DELETE CASCADE,
  CONSTRAINT `contracts_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contracts`
--

LOCK TABLES `contracts` WRITE;
/*!40000 ALTER TABLE `contracts` DISABLE KEYS */;
INSERT INTO `contracts` VALUES (1,1,'HopDongThucTap_NguyenVanNam_2026.pdf','uploads/contracts/HopDongThucTap_NguyenVanNam_2026.pdf',2097152,'application/pdf',1,'2026-09-05 19:00:00','CONFIRMED','2026-10-17 16:42:42');
/*!40000 ALTER TABLE `contracts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `departments` (
  `department_id` int(11) NOT NULL AUTO_INCREMENT,
  `department_name` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`department_id`),
  UNIQUE KEY `department_name` (`department_name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departments`
--

LOCK TABLES `departments` WRITE;
/*!40000 ALTER TABLE `departments` DISABLE KEYS */;
INSERT INTO `departments` VALUES (1,'Phòng Phát triển Phần mềm','Bộ phận kỹ thuật và phát triển phần mềm','2026-10-15 15:16:10','2026-10-15 16:04:53');
/*!40000 ALTER TABLE `departments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents`
--

DROP TABLE IF EXISTS `documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documents` (
  `document_id` int(11) NOT NULL AUTO_INCREMENT,
  `profile_id` int(11) NOT NULL,
  `document_type` varchar(50) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` bigint(20) NOT NULL,
  `mime_type` varchar(100) NOT NULL,
  `status` varchar(30) DEFAULT 'PENDING',
  `reviewed_by` bigint(20) DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `reject_reason` text DEFAULT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`document_id`),
  KEY `idx_profile_doc` (`profile_id`,`document_type`),
  KEY `fk_documents_reviewed_by` (`reviewed_by`),
  CONSTRAINT `documents_ibfk_1` FOREIGN KEY (`profile_id`) REFERENCES `intern_profiles` (`profile_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_documents_reviewed_by` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents`
--

LOCK TABLES `documents` WRITE;
/*!40000 ALTER TABLE `documents` DISABLE KEYS */;
INSERT INTO `documents` VALUES (1,1,'CV','CV_NguyenVanNam_JavaBackend.pdf','uploads/documents/CV_NguyenVanNam_JavaBackend.pdf',1048576,'application/pdf','APPROVED',NULL,NULL,NULL,'2026-09-01 13:35:00'),(2,1,'APPLICATION_LETTER','DonXinThucTap_NguyenVanNam.pdf','uploads/documents/DonXinThucTap_NguyenVanNam.pdf',524288,'application/pdf','APPROVED',NULL,NULL,NULL,'2026-09-01 13:36:00'),(3,2,'CV','CV_TranThiHoa_BA.pdf','uploads/documents/CV_TranThiHoa_BA.pdf',838860,'application/pdf','PENDING',NULL,NULL,NULL,'2026-09-10 19:20:00'),(4,4,'CV','CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM.docx','documents/7d791077-ce7c-4b14-bf5e-5b3961f94392.docx',16978,'application/vnd.openxmlformats-officedocument.wordprocessingml.document','PENDING',NULL,NULL,NULL,'2026-10-15 15:28:03');
/*!40000 ALTER TABLE `documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `enrollment_lifecycle_events`
--

DROP TABLE IF EXISTS `enrollment_lifecycle_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `enrollment_lifecycle_events` (
  `event_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `enrollment_id` int(11) NOT NULL,
  `from_status` varchar(20) NOT NULL,
  `to_status` varchar(20) NOT NULL,
  `actor_user_id` bigint(20) NOT NULL,
  `reason` varchar(1000) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`event_id`),
  KEY `enrollment_id` (`enrollment_id`),
  KEY `actor_user_id` (`actor_user_id`),
  CONSTRAINT `enrollment_lifecycle_events_ibfk_1` FOREIGN KEY (`enrollment_id`) REFERENCES `program_enrollments` (`enrollment_id`),
  CONSTRAINT `enrollment_lifecycle_events_ibfk_2` FOREIGN KEY (`actor_user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enrollment_lifecycle_events`
--

LOCK TABLES `enrollment_lifecycle_events` WRITE;
/*!40000 ALTER TABLE `enrollment_lifecycle_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `enrollment_lifecycle_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evaluations`
--

DROP TABLE IF EXISTS `evaluations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `evaluations` (
  `evaluation_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `enrollment_id` int(11) NOT NULL,
  `mentor_id` int(11) NOT NULL,
  `score` decimal(5,2) DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `skill_score` tinyint(4) DEFAULT NULL,
  `attitude_score` tinyint(4) DEFAULT NULL,
  `legacy_enrollment_id` int(11) GENERATED ALWAYS AS (case when `score` is not null then `enrollment_id` else NULL end) STORED,
  PRIMARY KEY (`evaluation_id`),
  UNIQUE KEY `uq_eval_legacy_enrollment` (`legacy_enrollment_id`),
  KEY `fk_eval_mentor` (`mentor_id`),
  KEY `ix_eval_history` (`enrollment_id`,`evaluation_id`),
  CONSTRAINT `fk_eval_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `program_enrollments` (`enrollment_id`),
  CONSTRAINT `fk_eval_mentor` FOREIGN KEY (`mentor_id`) REFERENCES `mentors` (`mentor_id`),
  CONSTRAINT `ck_eval_record_shape` CHECK (`score` is not null and `skill_score` is null and `attitude_score` is null or `score` is null and `skill_score` is not null and `attitude_score` is not null and `skill_score` between 1 and 5 and `attitude_score` between 1 and 5 and `comment` is not null and char_length(trim(`comment`)) > 0)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evaluations`
--

LOCK TABLES `evaluations` WRITE;
/*!40000 ALTER TABLE `evaluations` DISABLE KEYS */;
INSERT INTO `evaluations` VALUES (5,1,1,NULL,'Thuc tap sinh hoan thanh tot nhiem vu, co y thuc ky luat cao va phoi hop tot voi mentor.','2026-10-16 17:11:07','2026-10-16 17:11:07',5,4,NULL),(6,1,1,NULL,'NHẬN XÉT CHUNG CỦA MENTOR:\nThực tập sinh thể hiện năng lực chuyên môn vững vàng, tư duy logic tốt và hoàn thành tốt các nhiệm vụ được giao trong dự án. Tinh thần kỷ luật và thái độ học hỏi rất đáng khen ngợi.\n\nBẢNG ĐIỂM CHI TIẾT THEO TIÊU CHÍ:\nI. KỸ NĂNG & NĂNG LỰC CHUYÊN MÔN (TB: 4.4/5):\n1. Kiến thức nền tảng: 5/5 - Nắm vững Java và OOP\n...\n<!--EVAL_DATA:{\"attitudeAvg\":4.6,\"attitude\":[{\"title\":\"Tính chuyên cần \\u0026 Kỷ luật giờ giấc\",\"score\":5,\"comment\":\"Đi làm đúng giờ, không vắng buổi nào\",\"id\":1},{\"title\":\"Tinh thần trách nhiệm \\u0026 Cam kết công việc\",\"score\":5,\"comment\":\"Rất có trách nhiệm\",\"id\":2},{\"title\":\"Kỹ năng giao tiếp \\u0026 Làm việc nhóm\",\"score\":4,\"comment\":\"Hòa đồng, giao tiếp tốt\",\"id\":3},{\"title\":\"Tinh thần cầu tiến \\u0026 Tiếp thu góp ý\",\"score\":5,\"comment\":\"Luôn lắng nghe và cải thiện ngay\",\"id\":4},{\"title\":\"Tính chủ động, trung thực \\u0026 Hỗ trợ tập thể\",\"score\":4,\"comment\":\"Nhiệt tình hỗ trợ bạn thực tập khác\",\"id\":5}],\"skills\":[{\"title\":\"Kiến thức nền tảng \\u0026 Tư duy lập trình\",\"score\":5,\"comment\":\"Nắm vững Java và OOP rất tốt\",\"id\":1},{\"title\":\"Kỹ năng thiết kế \\u0026 Phát triển ứng dụng\",\"score\":4,\"comment\":\"Hiểu tốt luồng MVC\",\"id\":2},{\"title\":\"Thao tác \\u0026 Thiết kế Cơ sở dữ liệu\",\"score\":4,\"comment\":\"Viết truy vấn SQL chuẩn xác\",\"id\":3},{\"title\":\"Quy chuẩn mã nguồn \\u0026 Clean Code\",\"score\":5,\"comment\":\"Code rõ ràng, đặt tên biến chuẩn\",\"id\":4},{\"title\":\"Kỹ năng Debug, xử lý lỗi \\u0026 Ngoại lệ\",\"score\":4,\"comment\":\"Tự tra cứu lỗi tốt\",\"id\":5},{\"title\":\"Quản lý mã nguồn với Git \\u0026 Phối hợp nhóm\",\"score\":4,\"comment\":\"Commit gọn gàng\",\"id\":6},{\"title\":\"Năng lực tự học \\u0026 Đọc tài liệu kỹ thuật\",\"score\":5,\"comment\":\"Đọc tài liệu tiếng Anh nhanh\",\"id\":7},{\"title\":\"Tiến độ \\u0026 Mức độ hoàn thành nhiệm vụ\",\"score\":4,\"comment\":\"Bàn giao đúng hạn các task\",\"id\":8}],\"score10\":9,\"skillAvg\":4.38,\"overallComment\":\"Thực tập sinh thể hiện năng lực chuyên môn vững vàng, tư duy logic tốt và hoàn thành tốt các nhiệm vụ được giao trong dự án. Tinh thần kỷ luật và thái độ học hỏi rất đáng khen ngợi.\"}-->','2026-10-16 17:36:11','2026-10-16 17:36:11',4,5,NULL),(7,1,1,NULL,'NHẬN XÉT CHUNG CỦA MENTOR:\nfie\n\nBẢNG ĐIỂM CHI TIẾT THEO TIÊU CHÍ:\nI. KỸ NĂNG & NĂNG LỰC CHUYÊN MÔN (TB: 2.3/5):\n1. Kiến thức nền tảng & Tư duy lập trình: 1/5\n2. Kỹ năng thiết kế & Phát triển ứng dụng: 1/5\n3. Thao tác & Thiết kế Cơ sở dữ liệu: 1/5\n4. Quy chuẩn mã nguồn & Clean Code: 2/5\n5. Kỹ năng Debug, xử lý lỗi & Ngoại lệ: 2/5\n6. Quản lý mã nguồn với Git & Phối hợp nhóm: 3/5\n7. Năng lực tự học & Đọc tài liệu kỹ thuật: 5/5\n8. Tiến độ & Mức độ hoàn thành nhiệm vụ: 3/5\n\nII. Ý THỨC KỶ LUẬT & THÁI ĐỘ LÀM VIỆC (TB: 2.0/5):\n1. Tính chuyên cần & Kỷ luật giờ giấc: 2/5\n2. Tinh thần trách nhiệm & Cam kết công việc: 2/5\n3. Kỹ năng giao tiếp & Làm việc nhóm: 2/5\n4. Tinh thần cầu tiến & Tiếp thu góp ý: 2/5\n5. Tính chủ động, trung thực & Hỗ trợ tập thể: 2/5\n<!--EVAL_DATA:{\"skillAvg\":2.25,\"attitudeAvg\":2,\"score10\":4.3,\"overallComment\":\"fie\",\"skills\":[{\"id\":1,\"title\":\"Kiến thức nền tảng & Tư duy lập trình\",\"desc\":\"Nắm vững kiến thức lập trình cơ bản, OOP, cấu trúc dữ liệu và giải thuật.\",\"score\":1,\"comment\":\"\"},{\"id\":2,\"title\":\"Kỹ năng thiết kế & Phát triển ứng dụng\",\"desc\":\"Hiểu kiến trúc hệ thống (MVC/layered), luồng dữ liệu và cài đặt chức năng nghiệp vụ.\",\"score\":1,\"comment\":\"\"},{\"id\":3,\"title\":\"Thao tác & Thiết kế Cơ sở dữ liệu\",\"desc\":\"Kỹ năng viết truy vấn SQL, thiết kế bảng quan hệ và tối ưu truy vấn dữ liệu.\",\"score\":1,\"comment\":\"\"},{\"id\":4,\"title\":\"Quy chuẩn mã nguồn & Clean Code\",\"desc\":\"Viết code sạch, tuân thủ naming convention, cấu trúc hàm/lớp rõ ràng và dễ bảo trì.\",\"score\":2,\"comment\":\"\"},{\"id\":5,\"title\":\"Kỹ năng Debug, xử lý lỗi & Ngoại lệ\",\"desc\":\"Khả năng phân tích log, phát hiện bug độc lập và đề xuất phương án khắc phục hiệu quả.\",\"score\":2,\"comment\":\"\"},{\"id\":6,\"title\":\"Quản lý mã nguồn với Git & Phối hợp nhóm\",\"desc\":\"Sử dụng Git thành thạo (commit rõ ràng, quản lý branch, pull request) và phối hợp mã nguồn.\",\"score\":3,\"comment\":\"\"},{\"id\":7,\"title\":\"Năng lực tự học & Đọc tài liệu kỹ thuật\",\"desc\":\"Chủ động tìm hiểu tài liệu kỹ thuật, thư viện mới và tiếp cận công nghệ nhanh chóng.\",\"score\":5,\"comment\":\"\"},{\"id\":8,\"title\":\"Tiến độ & Mức độ hoàn thành nhiệm vụ\",\"desc\":\"Tinh thần cam kết deadline, hoàn thành đầy đủ các nhiệm vụ và tính đúng đắn của sản phẩm.\",\"score\":3,\"comment\":\"\"}],\"attitude\":[{\"id\":1,\"title\":\"Tính chuyên cần & Kỷ luật giờ giấc\",\"desc\":\"Đi làm đúng giờ, tuân thủ lịch họp và thực hiện nghiêm túc nội quy công ty/dự án.\",\"score\":2,\"comment\":\"\"},{\"id\":2,\"title\":\"Tinh thần trách nhiệm & Cam kết công việc\",\"desc\":\"Tận tâm với nhiệm vụ được giao, chủ động báo cáo tiến độ và nêu bật các vướng mắc.\",\"score\":2,\"comment\":\"\"},{\"id\":3,\"title\":\"Kỹ năng giao tiếp & Làm việc nhóm\",\"desc\":\"Giao tiếp hòa nhã, cởi mở, lắng nghe và hợp tác hiệu quả trong tập thể.\",\"score\":2,\"comment\":\"\"},{\"id\":4,\"title\":\"Tinh thần cầu tiến & Tiếp thu góp ý\",\"desc\":\"Lắng nghe chân thành, tích cực ghi nhận và tiếp thu phản hồi từ Mentor để cải thiện.\",\"score\":2,\"comment\":\"\"},{\"id\":5,\"title\":\"Tính chủ động, trung thực & Hỗ trợ tập thể\",\"desc\":\"Chủ động tìm kiếm việc khi xong task, trung thực và sẵn sàng hỗ trợ các thành viên khác.\",\"score\":2,\"comment\":\"\"}]}-->','2026-10-16 17:40:52','2026-10-16 17:40:52',2,2,NULL);
/*!40000 ALTER TABLE `evaluations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inapp_notifications`
--

DROP TABLE IF EXISTS `inapp_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inapp_notifications` (
  `notification_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `recipient_user_id` bigint(20) NOT NULL,
  `event_key` varchar(160) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `kind` varchar(30) NOT NULL,
  `source_type` varchar(20) NOT NULL,
  `source_id` bigint(20) NOT NULL,
  `source_revision` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `body` text NOT NULL,
  `available_at` datetime(6) NOT NULL,
  `expires_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `read_at` datetime(6) DEFAULT NULL,
  `superseded_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`notification_id`),
  UNIQUE KEY `uq_inapp_event_recipient` (`event_key`,`recipient_user_id`),
  KEY `idx_inapp_recipient` (`recipient_user_id`,`superseded_at`,`available_at`,`notification_id`),
  KEY `idx_inapp_source` (`source_type`,`source_id`,`kind`,`source_revision`),
  CONSTRAINT `fk_inapp_recipient` FOREIGN KEY (`recipient_user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inapp_notifications`
--

LOCK TABLES `inapp_notifications` WRITE;
/*!40000 ALTER TABLE `inapp_notifications` DISABLE KEYS */;
INSERT INTO `inapp_notifications` VALUES (1,1,'system:welcome:1','SYSTEM','SYSTEM',1,1,'Chào mừng đến với Internship Manager','Hệ thống quản lý thực tập sinh đã sẵn sàng hoạt động. Chúc bạn một ngày làm việc hiệu quả!','2026-10-16 18:43:52.682344',NULL,'2026-10-17 01:43:52.682344','2026-10-16 18:51:42.754972',NULL),(2,1,'app:new:4','APPLICATION','APPLICATION',4,1,'Hồ sơ thực tập sinh mới','Thực tập sinh Nguyễn Quốc Khánh đã ghi danh thành công vào Chương trình Thực tập Java Backend 2026.','2026-10-16 18:43:52.682344',NULL,'2026-10-17 01:43:52.682344',NULL,NULL),(3,7,'enroll:welcome:2','ENROLLMENT','ENROLLMENT',2,1,'Thông báo lịch họp tuần','Mentor Phạm Quốc Hùng đã lên lịch họp trao đổi tiến độ thực tập vào lúc 09:00 ngày 20/10/2026.','2026-10-16 18:43:52.682344',NULL,'2026-10-17 01:43:52.682344',NULL,NULL),(4,2,'meeting:2:1:CREATE','CREATE','MEETING',2,1,'Cuộc họp mới','Hop dinh ky review du an\n2026-10-28T09:00:00Z – 2026-10-28T10:00:00Z','2026-10-17 16:22:13.000000',NULL,'2026-10-17 16:22:13.283434',NULL,NULL),(5,2,'meeting:2:1:REMINDER','REMINDER','MEETING',2,1,'Nhắc lịch họp','Hop dinh ky review du an\n2026-10-28T09:00:00Z','2026-10-28 08:30:00.000000','2026-10-28 09:00:00.000000','2026-10-17 16:22:13.284751',NULL,NULL);
/*!40000 ALTER TABLE `inapp_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `intern_profiles`
--

DROP TABLE IF EXISTS `intern_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `intern_profiles` (
  `profile_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `dob` date DEFAULT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `email` varchar(100) NOT NULL,
  `university` varchar(150) NOT NULL,
  `major` varchar(100) NOT NULL,
  `gpa` decimal(3,2) DEFAULT NULL,
  `skills` text DEFAULT NULL,
  `status` varchar(30) DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`profile_id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `idx_full_name` (`full_name`),
  KEY `idx_university` (`university`),
  KEY `idx_major` (`major`),
  CONSTRAINT `intern_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `intern_profiles`
--

LOCK TABLES `intern_profiles` WRITE;
/*!40000 ALTER TABLE `intern_profiles` DISABLE KEYS */;
INSERT INTO `intern_profiles` VALUES (1,2,'Nguyễn Văn Nam','2003-05-15','Nam','0912345678','nam.nv@student.edu.vn','Đại học Bách Khoa Hà Nội','Công nghệ thông tin',3.45,'Java, Servlet, MySQL, Spring Boot','ACTIVE','2026-10-06 02:56:22','2026-10-15 16:04:53'),(2,3,'Trần Thị Hoa','2003-10-20','Nß╗»','0987654321','hoa.tt@student.edu.vn','Đại học Kinh tế Quốc dân','Hệ thống thông tin quản lý',3.60,'Python, SQL, PowerBI, Business Analysis','ACTIVE','2026-10-06 02:56:22','2026-10-15 16:04:53'),(3,4,'Lê Văn Tuấn','2004-01-08','Nam','0901122334','tuan.lv@student.edu.vn','Đại học Công nghệ - ĐHQGHN','Khoa học máy tính',3.20,'C++, Java, OOP, Data Structures','ACTIVE','2026-10-06 02:56:22','2026-10-15 16:04:53'),(4,7,'Nguyễn Quốc Khánh',NULL,'Nam','0829999456','nguyenqkhanh1626@gmail.com','Đại học CNTT & TT Thái Nguyên','An Toàn Thông Tin',4.00,'Java','ACTIVE','2026-10-15 15:26:45','2026-10-15 16:04:53'),(5,8,'Nguyễn Quốc Anh',NULL,NULL,'0000000000','dtc245220042@ictu.edu.vn','Chưa cập nhật','Chưa cập nhật',NULL,NULL,'ACTIVE','2026-10-17 16:37:55','2026-10-17 16:37:55');
/*!40000 ALTER TABLE `intern_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `internship_programs`
--

DROP TABLE IF EXISTS `internship_programs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `internship_programs` (
  `program_id` int(11) NOT NULL AUTO_INCREMENT,
  `program_name` varchar(200) NOT NULL,
  `department_id` int(11) NOT NULL,
  `description` text DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `max_interns` int(11) NOT NULL DEFAULT 0,
  `status` varchar(30) NOT NULL DEFAULT 'PLANNED',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`program_id`),
  KEY `idx_program_status` (`status`),
  KEY `idx_program_dept` (`department_id`),
  CONSTRAINT `internship_programs_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`),
  CONSTRAINT `chk_program_dates` CHECK (`end_date` >= `start_date`),
  CONSTRAINT `chk_program_capacity` CHECK (`max_interns` >= 0),
  CONSTRAINT `chk_program_status` CHECK (`status` in ('PLANNED','ACTIVE','COMPLETED','CANCELLED'))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `internship_programs`
--

LOCK TABLES `internship_programs` WRITE;
/*!40000 ALTER TABLE `internship_programs` DISABLE KEYS */;
INSERT INTO `internship_programs` VALUES (1,'Chương trình Thực tập Java Backend 2026',1,'Đào tạo thực tập sinh backend công nghệ Java Servlet, JSP, MySQL','2026-10-01','2026-12-31',10,'ACTIVE','2026-10-15 15:16:10','2026-10-15 16:04:53');
/*!40000 ALTER TABLE `internship_programs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_requests`
--

DROP TABLE IF EXISTS `leave_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `leave_requests` (
  `leave_id` int(11) NOT NULL AUTO_INCREMENT,
  `enrollment_id` int(11) NOT NULL,
  `from_date` date NOT NULL,
  `to_date` date NOT NULL,
  `reason` varchar(1000) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'PENDING',
  `reviewed_by` bigint(20) DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `reject_reason` varchar(1000) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`leave_id`),
  KEY `fk_lr_reviewer` (`reviewed_by`),
  KEY `idx_lr_overlap` (`enrollment_id`,`status`,`from_date`,`to_date`),
  CONSTRAINT `fk_lr_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `program_enrollments` (`enrollment_id`),
  CONSTRAINT `fk_lr_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `chk_lr_dates` CHECK (`from_date` <= `to_date`),
  CONSTRAINT `chk_lr_reason` CHECK (char_length(trim(`reason`)) > 0),
  CONSTRAINT `chk_lr_status` CHECK (`status` in ('PENDING','APPROVED','REJECTED')),
  CONSTRAINT `chk_lr_decision` CHECK (`status` = 'PENDING' and `reviewed_by` is null and `reviewed_at` is null and `reject_reason` is null or `status` = 'APPROVED' and `reviewed_by` is not null and `reviewed_at` is not null and `reject_reason` is null or `status` = 'REJECTED' and `reviewed_by` is not null and `reviewed_at` is not null and `reject_reason` is not null and char_length(trim(`reject_reason`)) > 0)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_requests`
--

LOCK TABLES `leave_requests` WRITE;
/*!40000 ALTER TABLE `leave_requests` DISABLE KEYS */;
INSERT INTO `leave_requests` VALUES (1,1,'2026-10-10','2026-10-10','Nghỉ phép để tham gia bảo vệ đồ án tốt nghiệp tại trường Đại học.','APPROVED',1,'2026-10-09 03:00:00',NULL,'2026-10-08 07:00:00'),(2,1,'2026-10-24','2026-10-24','Nghỉ phép có việc gia đình đột xuất.','APPROVED',1,'2026-10-17 15:59:03',NULL,'2026-10-16 02:30:00');
/*!40000 ALTER TABLE `leave_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meeting_notification_outbox`
--

DROP TABLE IF EXISTS `meeting_notification_outbox`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meeting_notification_outbox` (
  `notification_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `meeting_id` bigint(20) NOT NULL,
  `revision` int(11) NOT NULL,
  `event_type` varchar(20) NOT NULL,
  `recipient_user_id` bigint(20) NOT NULL,
  `recipient_email` varchar(255) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `due_at` datetime(6) NOT NULL,
  `state` varchar(20) NOT NULL DEFAULT 'PENDING',
  `attempts` int(11) NOT NULL DEFAULT 0,
  `claim_token` varchar(36) DEFAULT NULL,
  `lease_until` datetime(6) DEFAULT NULL,
  `error_code` varchar(40) DEFAULT NULL,
  `sent_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY (`notification_id`),
  UNIQUE KEY `uq_be1_notification` (`meeting_id`,`revision`,`event_type`,`recipient_user_id`),
  KEY `idx_be1_due` (`state`,`due_at`,`notification_id`),
  KEY `idx_be1_delivery_order` (`meeting_id`,`recipient_user_id`,`notification_id`,`state`),
  KEY `fk_be1_notification_user` (`recipient_user_id`),
  CONSTRAINT `fk_be1_notification_meeting` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`meeting_id`),
  CONSTRAINT `fk_be1_notification_user` FOREIGN KEY (`recipient_user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `chk_be1_notification_event` CHECK (`event_type` in ('CREATE','CHANGE','CANCEL','REMINDER')),
  CONSTRAINT `chk_be1_notification_state` CHECK (`state` in ('PENDING','IN_FLIGHT','SENT','FAILED','SUPERSEDED')),
  CONSTRAINT `chk_be1_notification_revision` CHECK (`revision` > 0),
  CONSTRAINT `chk_be1_notification_attempts` CHECK (`attempts` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting_notification_outbox`
--

LOCK TABLES `meeting_notification_outbox` WRITE;
/*!40000 ALTER TABLE `meeting_notification_outbox` DISABLE KEYS */;
/*!40000 ALTER TABLE `meeting_notification_outbox` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meeting_participants`
--

DROP TABLE IF EXISTS `meeting_participants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meeting_participants` (
  `meeting_id` bigint(20) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  PRIMARY KEY (`meeting_id`,`enrollment_id`),
  KEY `idx_be1_participant_enrollment` (`enrollment_id`,`meeting_id`),
  CONSTRAINT `fk_be1_participant_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `program_enrollments` (`enrollment_id`),
  CONSTRAINT `fk_be1_participant_meeting` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`meeting_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting_participants`
--

LOCK TABLES `meeting_participants` WRITE;
/*!40000 ALTER TABLE `meeting_participants` DISABLE KEYS */;
INSERT INTO `meeting_participants` VALUES (1,1),(2,1);
/*!40000 ALTER TABLE `meeting_participants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meeting_recipient_snapshots`
--

DROP TABLE IF EXISTS `meeting_recipient_snapshots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meeting_recipient_snapshots` (
  `meeting_id` bigint(20) NOT NULL,
  `revision` int(11) NOT NULL,
  `recipient_user_id` bigint(20) NOT NULL,
  `recipient_email` varchar(255) NOT NULL,
  PRIMARY KEY (`meeting_id`,`revision`,`recipient_user_id`),
  KEY `fk_be1_snapshot_user` (`recipient_user_id`),
  CONSTRAINT `fk_be1_snapshot_meeting` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`meeting_id`),
  CONSTRAINT `fk_be1_snapshot_user` FOREIGN KEY (`recipient_user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `chk_be1_snapshot_revision` CHECK (`revision` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting_recipient_snapshots`
--

LOCK TABLES `meeting_recipient_snapshots` WRITE;
/*!40000 ALTER TABLE `meeting_recipient_snapshots` DISABLE KEYS */;
/*!40000 ALTER TABLE `meeting_recipient_snapshots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meetings`
--

DROP TABLE IF EXISTS `meetings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meetings` (
  `meeting_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `program_id` int(11) NOT NULL,
  `organizer_user_id` bigint(20) NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `location` varchar(500) NOT NULL,
  `starts_at` timestamp(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  `ends_at` timestamp(6) NOT NULL DEFAULT '0000-00-00 00:00:00.000000',
  `status` varchar(20) NOT NULL DEFAULT 'SCHEDULED',
  `revision` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` timestamp(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  PRIMARY KEY (`meeting_id`),
  KEY `fk_be1_meeting_organizer` (`organizer_user_id`),
  KEY `idx_be1_meeting_program_time` (`program_id`,`starts_at`),
  CONSTRAINT `fk_be1_meeting_organizer` FOREIGN KEY (`organizer_user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_be1_meeting_program` FOREIGN KEY (`program_id`) REFERENCES `internship_programs` (`program_id`),
  CONSTRAINT `chk_be1_meeting_time` CHECK (`ends_at` > `starts_at`),
  CONSTRAINT `chk_be1_meeting_status` CHECK (`status` in ('SCHEDULED','CANCELLED')),
  CONSTRAINT `chk_be1_meeting_revision` CHECK (`revision` > 0)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meetings`
--

LOCK TABLES `meetings` WRITE;
/*!40000 ALTER TABLE `meetings` DISABLE KEYS */;
INSERT INTO `meetings` VALUES (1,1,5,'Hackpython','Java dell','C2.103','2026-10-23 17:52:00.000000','2026-10-24 17:52:00.000000','SCHEDULED',1,'2026-10-16 17:52:51.380409','2026-10-16 17:52:51.380409'),(2,1,1,'Hop dinh ky review du an','Hop qua Gmail','Phong hop A202','2026-10-28 09:00:00.000000','2026-10-28 10:00:00.000000','SCHEDULED',1,'2026-10-17 16:22:13.264915','2026-10-17 16:22:13.264915');
/*!40000 ALTER TABLE `meetings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mentor_assignments`
--

DROP TABLE IF EXISTS `mentor_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mentor_assignments` (
  `assignment_id` int(11) NOT NULL AUTO_INCREMENT,
  `enrollment_id` int(11) NOT NULL,
  `mentor_id` int(11) NOT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `assigned_by` bigint(20) NOT NULL,
  `ended_at` timestamp NULL DEFAULT NULL,
  `active_enrollment_id` int(11) GENERATED ALWAYS AS (case when `ended_at` is null then `enrollment_id` else NULL end) STORED,
  `end_reason` varchar(200) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`assignment_id`),
  UNIQUE KEY `uq_one_current_mentor_per_enrollment` (`active_enrollment_id`),
  KEY `assigned_by` (`assigned_by`),
  KEY `idx_ma_enrollment` (`enrollment_id`),
  KEY `idx_ma_mentor` (`mentor_id`),
  KEY `idx_ma_active` (`enrollment_id`,`ended_at`),
  CONSTRAINT `mentor_assignments_ibfk_1` FOREIGN KEY (`enrollment_id`) REFERENCES `program_enrollments` (`enrollment_id`),
  CONSTRAINT `mentor_assignments_ibfk_2` FOREIGN KEY (`mentor_id`) REFERENCES `mentors` (`mentor_id`),
  CONSTRAINT `mentor_assignments_ibfk_3` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mentor_assignments`
--

LOCK TABLES `mentor_assignments` WRITE;
/*!40000 ALTER TABLE `mentor_assignments` DISABLE KEYS */;
INSERT INTO `mentor_assignments` VALUES (1,1,1,'2026-10-15 15:16:10',1,NULL,1,NULL,'2026-10-15 15:16:10'),(2,2,1,'2026-10-16 18:34:47',1,NULL,2,NULL,'2026-10-16 18:34:47');
/*!40000 ALTER TABLE `mentor_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mentors`
--

DROP TABLE IF EXISTS `mentors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mentors` (
  `mentor_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `department_id` int(11) DEFAULT NULL,
  `specialization` varchar(200) DEFAULT NULL,
  `max_mentees` int(11) NOT NULL DEFAULT 5,
  `status` varchar(30) NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`mentor_id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `department_id` (`department_id`),
  KEY `idx_mentor_status` (`status`),
  CONSTRAINT `mentors_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `mentors_ibfk_2` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`),
  CONSTRAINT `chk_mentor_capacity` CHECK (`max_mentees` > 0)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mentors`
--

LOCK TABLES `mentors` WRITE;
/*!40000 ALTER TABLE `mentors` DISABLE KEYS */;
INSERT INTO `mentors` VALUES (1,5,1,'Java / Web Fullstack',5,'ACTIVE','2026-10-15 15:16:10','2026-10-15 15:16:10');
/*!40000 ALTER TABLE `mentors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `program_enrollments`
--

DROP TABLE IF EXISTS `program_enrollments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `program_enrollments` (
  `enrollment_id` int(11) NOT NULL AUTO_INCREMENT,
  `application_id` int(11) NOT NULL,
  `program_id` int(11) NOT NULL,
  `intern_profile_id` int(11) NOT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'ACTIVE',
  `active_intern_profile_id` int(11) GENERATED ALWAYS AS (case when `status` = 'ACTIVE' then `intern_profile_id` else NULL end) STORED,
  `enrolled_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`enrollment_id`),
  UNIQUE KEY `application_id` (`application_id`),
  UNIQUE KEY `uq_one_active_enrollment_per_intern` (`active_intern_profile_id`),
  KEY `idx_enrollment_status` (`status`),
  KEY `idx_enrollment_intern` (`intern_profile_id`),
  KEY `idx_enrollment_program` (`program_id`),
  CONSTRAINT `program_enrollments_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `applications` (`application_id`),
  CONSTRAINT `program_enrollments_ibfk_2` FOREIGN KEY (`program_id`) REFERENCES `internship_programs` (`program_id`),
  CONSTRAINT `program_enrollments_ibfk_3` FOREIGN KEY (`intern_profile_id`) REFERENCES `intern_profiles` (`profile_id`),
  CONSTRAINT `chk_enrollment_status` CHECK (`status` in ('ACTIVE','COMPLETED','CANCELLED'))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `program_enrollments`
--

LOCK TABLES `program_enrollments` WRITE;
/*!40000 ALTER TABLE `program_enrollments` DISABLE KEYS */;
INSERT INTO `program_enrollments` VALUES (1,1,1,1,'ACTIVE',1,'2026-10-15 15:16:10',NULL,'2026-10-15 15:16:10','2026-10-15 15:16:10'),(2,4,1,4,'ACTIVE',4,'2026-10-16 18:34:47',NULL,'2026-10-16 18:34:47','2026-10-16 18:34:47');
/*!40000 ALTER TABLE `program_enrollments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `program_lifecycle_events`
--

DROP TABLE IF EXISTS `program_lifecycle_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `program_lifecycle_events` (
  `event_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `program_id` int(11) NOT NULL,
  `from_status` varchar(20) NOT NULL,
  `to_status` varchar(20) NOT NULL,
  `actor_user_id` bigint(20) NOT NULL,
  `reason` varchar(1000) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`event_id`),
  KEY `program_id` (`program_id`),
  KEY `actor_user_id` (`actor_user_id`),
  CONSTRAINT `program_lifecycle_events_ibfk_1` FOREIGN KEY (`program_id`) REFERENCES `internship_programs` (`program_id`),
  CONSTRAINT `program_lifecycle_events_ibfk_2` FOREIGN KEY (`actor_user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `program_lifecycle_events`
--

LOCK TABLES `program_lifecycle_events` WRITE;
/*!40000 ALTER TABLE `program_lifecycle_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `program_lifecycle_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_export_events`
--

DROP TABLE IF EXISTS `report_export_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_export_events` (
  `export_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `actor_user_id` bigint(20) NOT NULL,
  `program_id` int(11) DEFAULT NULL,
  `enrollment_id` int(11) DEFAULT NULL,
  `enrollment_status` varchar(20) DEFAULT NULL,
  `format` varchar(10) NOT NULL,
  `report_kind` varchar(30) NOT NULL DEFAULT 'END_TERM',
  `cohort_from` date DEFAULT NULL,
  `cohort_to` date DEFAULT NULL,
  `row_count` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `report_from` date DEFAULT NULL,
  `report_to` date DEFAULT NULL,
  PRIMARY KEY (`export_id`),
  KEY `actor_user_id` (`actor_user_id`),
  CONSTRAINT `report_export_events_ibfk_1` FOREIGN KEY (`actor_user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_export_events`
--

LOCK TABLES `report_export_events` WRITE;
/*!40000 ALTER TABLE `report_export_events` DISABLE KEYS */;
INSERT INTO `report_export_events` VALUES (1,1,NULL,NULL,NULL,'xlsx','END_TERM',NULL,NULL,2,'2026-10-17 15:48:40',NULL,NULL),(2,1,NULL,NULL,NULL,'pdf','END_TERM',NULL,NULL,2,'2026-10-17 15:48:40',NULL,NULL),(3,1,NULL,NULL,NULL,'xlsx','PROGRAM_STATISTICS',NULL,NULL,2,'2026-10-17 15:48:40',NULL,NULL),(4,1,NULL,NULL,NULL,'pdf','PROGRAM_STATISTICS',NULL,NULL,2,'2026-10-17 15:48:40',NULL,NULL),(5,1,NULL,NULL,NULL,'xlsx','END_TERM',NULL,NULL,2,'2026-10-17 15:49:31',NULL,NULL),(6,1,NULL,NULL,NULL,'pdf','END_TERM',NULL,NULL,2,'2026-10-17 15:49:31',NULL,NULL),(7,1,NULL,NULL,NULL,'xlsx','ATTENDANCE',NULL,NULL,4,'2026-10-17 15:49:31','2026-10-01','2026-10-31'),(8,1,NULL,NULL,NULL,'pdf','ATTENDANCE',NULL,NULL,4,'2026-10-17 15:49:31','2026-10-01','2026-10-31'),(9,1,NULL,NULL,NULL,'xlsx','PROGRAM_STATISTICS',NULL,NULL,2,'2026-10-17 15:49:31',NULL,NULL),(10,1,NULL,NULL,NULL,'pdf','PROGRAM_STATISTICS',NULL,NULL,2,'2026-10-17 15:49:31',NULL,NULL);
/*!40000 ALTER TABLE `report_export_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_feedbacks`
--

DROP TABLE IF EXISTS `report_feedbacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_feedbacks` (
  `feedback_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `report_id` bigint(20) NOT NULL,
  `reviewer_user_id` bigint(20) NOT NULL,
  `comment` text DEFAULT NULL,
  `rating` tinyint(3) unsigned DEFAULT NULL CHECK (`rating` between 1 and 5),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`feedback_id`),
  KEY `fk_rf_report` (`report_id`),
  KEY `fk_rf_reviewer` (`reviewer_user_id`),
  CONSTRAINT `fk_rf_report` FOREIGN KEY (`report_id`) REFERENCES `weekly_reports` (`report_id`),
  CONSTRAINT `fk_rf_reviewer` FOREIGN KEY (`reviewer_user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_feedbacks`
--

LOCK TABLES `report_feedbacks` WRITE;
/*!40000 ALTER TABLE `report_feedbacks` DISABLE KEYS */;
INSERT INTO `report_feedbacks` VALUES (1,1,5,'Báo cáo chi tiết, tiến độ rất tốt. Khả năng tự học và nắm bắt kiến thức nhanh. Cố gắng phát huy ở tuần tiếp theo!',5,'2026-10-08 02:30:00');
/*!40000 ALTER TABLE `report_feedbacks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `role_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'ADMIN','Quản trị hệ thống','2026-10-06 02:56:22'),(2,'HR','Nhân sự','2026-10-06 02:56:22'),(3,'MENTOR','Người hướng dẫn thực tập sinh','2026-10-06 02:56:22'),(4,'INTERN','Thực tập sinh','2026-10-06 02:56:22');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `support_requests`
--

DROP TABLE IF EXISTS `support_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `support_requests` (
  `request_id` int(11) NOT NULL AUTO_INCREMENT,
  `profile_id` int(11) NOT NULL,
  `request_type` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `status` varchar(30) DEFAULT 'PENDING',
  `response` text DEFAULT NULL,
  `handled_by` bigint(20) DEFAULT NULL,
  `handled_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`request_id`),
  KEY `profile_id` (`profile_id`),
  KEY `handled_by` (`handled_by`),
  CONSTRAINT `support_requests_ibfk_1` FOREIGN KEY (`profile_id`) REFERENCES `intern_profiles` (`profile_id`) ON DELETE CASCADE,
  CONSTRAINT `support_requests_ibfk_2` FOREIGN KEY (`handled_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `support_requests`
--

LOCK TABLES `support_requests` WRITE;
/*!40000 ALTER TABLE `support_requests` DISABLE KEYS */;
INSERT INTO `support_requests` VALUES (1,4,'HR_INQUIRY','sos','h','RESOLVED','Ok',1,'2026-10-17 01:23:01','2026-10-15 16:52:35'),(2,5,'IT_SUPPORT','Ho tro cai dat moi truong Dev','Em can ho tro cai dat Java 21 va Tomcat tren may ca nhan.','RESOLVED','HR da ghi nhan va se ho tro truc tiep vao 9h sang mai.',1,'2026-10-17 23:37:56','2026-10-17 16:37:55');
/*!40000 ALTER TABLE `support_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_assignments`
--

DROP TABLE IF EXISTS `task_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `task_assignments` (
  `assignment_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `task_id` bigint(20) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `status` enum('TODO','IN_PROGRESS','DONE') NOT NULL DEFAULT 'TODO',
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`assignment_id`),
  UNIQUE KEY `uq_ta_task_enrollment` (`task_id`,`enrollment_id`),
  KEY `fk_ta_enrollment` (`enrollment_id`),
  CONSTRAINT `fk_ta_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `program_enrollments` (`enrollment_id`),
  CONSTRAINT `fk_ta_task` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`task_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_assignments`
--

LOCK TABLES `task_assignments` WRITE;
/*!40000 ALTER TABLE `task_assignments` DISABLE KEYS */;
INSERT INTO `task_assignments` VALUES (1,1,1,'TODO','2026-10-16 18:19:14','2026-10-16 18:19:14'),(2,2,1,'IN_PROGRESS','2026-10-10 01:30:00','2026-10-17 15:50:31'),(3,3,1,'DONE','2026-10-05 01:30:00','2026-10-17 15:50:31');
/*!40000 ALTER TABLE `task_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_progress`
--

DROP TABLE IF EXISTS `task_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `task_progress` (
  `progress_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `assignment_id` bigint(20) NOT NULL,
  `note` text DEFAULT NULL,
  `completion_percentage` tinyint(3) unsigned NOT NULL CHECK (`completion_percentage` between 0 and 100),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`progress_id`),
  KEY `fk_tp_assignment` (`assignment_id`),
  CONSTRAINT `fk_tp_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `task_assignments` (`assignment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_progress`
--

LOCK TABLES `task_progress` WRITE;
/*!40000 ALTER TABLE `task_progress` DISABLE KEYS */;
INSERT INTO `task_progress` VALUES (1,2,'Đã hoàn thành cấu trúc thư mục test và 15 test cases cho AuthService.',40,'2026-10-12 09:00:00'),(2,2,'Bổ sung mock cho UserDAO và hoàn thiện 70% khối lượng công việc.',70,'2026-10-15 10:30:00'),(3,3,'Hoàn thành thêm token csrf trên toàn bộ form JSP và pass test.',100,'2026-10-14 08:00:00');
/*!40000 ALTER TABLE `task_progress` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_progress_actors`
--

DROP TABLE IF EXISTS `task_progress_actors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `task_progress_actors` (
  `progress_id` bigint(20) NOT NULL,
  `actor_user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`progress_id`),
  KEY `actor_user_id` (`actor_user_id`),
  CONSTRAINT `task_progress_actors_ibfk_1` FOREIGN KEY (`progress_id`) REFERENCES `task_progress` (`progress_id`),
  CONSTRAINT `task_progress_actors_ibfk_2` FOREIGN KEY (`actor_user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_progress_actors`
--

LOCK TABLES `task_progress_actors` WRITE;
/*!40000 ALTER TABLE `task_progress_actors` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_progress_actors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tasks`
--

DROP TABLE IF EXISTS `tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tasks` (
  `task_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `created_by_user_id` bigint(20) NOT NULL,
  `status` enum('OPEN','CLOSED','CANCELLED') NOT NULL DEFAULT 'OPEN',
  `due_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`task_id`),
  KEY `fk_tasks_created_by` (`created_by_user_id`),
  CONSTRAINT `fk_tasks_created_by` FOREIGN KEY (`created_by_user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tasks`
--

LOCK TABLES `tasks` WRITE;
/*!40000 ALTER TABLE `tasks` DISABLE KEYS */;
INSERT INTO `tasks` VALUES (1,'Hoàn thành dự án 0003','Java,php',5,'OPEN','2026-10-31','2026-10-16 18:19:14','2026-10-16 18:19:14'),(2,'Nghiên cứu kiến trúc MVC và viết Unit Test','Tìm hiểu mô hình MVC Servlet/JSP, viết kiểm thử đơn vị cho các tầng DAO và Service.',5,'OPEN','2026-10-25','2026-10-10 01:00:00','2026-10-17 15:59:32'),(3,'Tích hợp xác thực bảo mật và CSRF','Rà soát mã nguồn, cấu hình bộ lọc AuthenticationFilter và CsrfToken bảo vệ tất cả form POST.',5,'CLOSED','2026-10-15','2026-10-05 01:00:00','2026-10-17 15:59:32');
/*!40000 ALTER TABLE `tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `user_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `username` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `full_name` varchar(150) NOT NULL,
  `role_id` bigint(20) NOT NULL,
  `status` enum('ACTIVE','INACTIVE','LOCKED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `fk_users_role` (`role_id`),
  CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'hr_lan','hr_lan@company.com','$2a$12$i91pQMrdSf15hnQHPZAZxOrsOpHZ0XgW29IhQV8CpPtv/e5iDlQui','Nguyễn Thị Lan',2,'ACTIVE','2026-10-06 02:56:22','2026-10-16 19:15:14'),(2,'intern_nam','nam.nv@student.edu.vn','$2a$10$ifBNj/pgN7t50ik3utzxyOA9X9j4l0vnmgPhfpUQLhyFm.xgaImQ.','Nguyễn Văn Nam',4,'ACTIVE','2026-10-06 02:56:22','2026-10-15 16:04:53'),(3,'intern_hoa','hoa.tt@student.edu.vn','$2a$10$ifBNj/pgN7t50ik3utzxyOA9X9j4l0vnmgPhfpUQLhyFm.xgaImQ.','Trần Thị Hoa',4,'ACTIVE','2026-10-06 02:56:22','2026-10-15 16:04:53'),(4,'intern_tuan','tuan.lv@student.edu.vn','$2a$10$ifBNj/pgN7t50ik3utzxyOA9X9j4l0vnmgPhfpUQLhyFm.xgaImQ.','Lê Văn Tuấn',4,'ACTIVE','2026-10-06 02:56:22','2026-10-15 16:04:53'),(5,'mentor_hung','mentor_hung@company.com','$2a$12$E3zgUHXEOGxWTXkc.YUIWOK6RM4clj7D/ctgfnsZn1w.JEBri1e1e','Phạm Quốc Hùng',3,'ACTIVE','2026-10-15 15:16:10','2026-10-16 18:17:45'),(6,'admin','admin@company.com','$2a$12$Lb.dRvhFfopMeIseLymkhugRTCUi8m.5Z2XupBS7/aBRO6kbPe44i','Quản trị viên',1,'ACTIVE','2026-10-15 15:16:10','2026-10-16 19:00:01'),(7,'khanh1626','nguyenqkhanh1626@gmail.com','$2a$12$ahT6sdz5jNZDSAh5zuW3meBR7wF1ez0inptkxyQJfBEklXNS8Cxey','Nguyễn Quốc Khánh',4,'ACTIVE','2026-10-15 15:26:45','2026-10-15 16:04:53'),(8,'khanh01','dtc245220042@ictu.edu.vn','$2a$12$j9ekc1KQfj9lNwklGHJFZuf2yZRP1A/mMitLSBLsW85LQqC9Uh3tO','Nguyễn Quốc Anh',4,'ACTIVE','2026-10-16 18:31:39','2026-10-16 19:05:17');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `weekly_report_sections`
--

DROP TABLE IF EXISTS `weekly_report_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `weekly_report_sections` (
  `report_id` bigint(20) NOT NULL,
  `results` text NOT NULL,
  `difficulties` text NOT NULL,
  `next_plan` text NOT NULL,
  PRIMARY KEY (`report_id`),
  CONSTRAINT `weekly_report_sections_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `weekly_reports` (`report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `weekly_report_sections`
--

LOCK TABLES `weekly_report_sections` WRITE;
/*!40000 ALTER TABLE `weekly_report_sections` DISABLE KEYS */;
INSERT INTO `weekly_report_sections` VALUES (1,'1. Thiết lập môi trường MySQL, Tomcat 10.1 và Maven thành công.\n2. Hoàn thành bổ sung CSRF token cho 100% form POST.','Thời gian đầu làm quen với Git Flow nhóm có một số xung đột merge nhưng đã xử lý xong.','Bắt đầu triển khai viết Unit Test và chuẩn bị tài liệu báo cáo tuần tiếp theo.'),(2,'1. Viết 25 test cases kiểm thử các luồng phân quyền và báo cáo.\n2. Hỗ trợ team kiểm thử chức năng xuất file Excel và PDF.','Một số ràng buộc kiểm tra trùng lặp giờ công cần trao đổi thêm với HR để chốt spec.','Hoàn thiện báo cáo cuối kỳ và hỗ trợ đồng đội rà soát giao diện người dùng.');
/*!40000 ALTER TABLE `weekly_report_sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `weekly_reports`
--

DROP TABLE IF EXISTS `weekly_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `weekly_reports` (
  `report_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `enrollment_id` int(11) NOT NULL,
  `week_number` smallint(6) NOT NULL CHECK (`week_number` >= 1),
  `content` text DEFAULT NULL,
  `status` enum('DRAFT','SUBMITTED','REVIEWED') NOT NULL DEFAULT 'DRAFT',
  `submitted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`report_id`),
  UNIQUE KEY `uq_wr_enrollment_week` (`enrollment_id`,`week_number`),
  CONSTRAINT `fk_wr_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `program_enrollments` (`enrollment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `weekly_reports`
--

LOCK TABLES `weekly_reports` WRITE;
/*!40000 ALTER TABLE `weekly_reports` DISABLE KEYS */;
INSERT INTO `weekly_reports` VALUES (1,1,1,'Báo cáo tuần 1: Đã làm quen dự án, cài đặt môi trường và hoàn thành task bảo mật CSRF.','REVIEWED','2026-10-07 10:00:00','2026-10-07 09:30:00','2026-10-17 15:59:32'),(2,1,2,'Báo cáo tuần 2: Triển khai kiểm thử hồi quy cho DAO/Service và nghiên cứu API xuất báo cáo.','SUBMITTED','2026-10-14 10:30:00','2026-10-14 10:00:00','2026-10-17 15:59:32');
/*!40000 ALTER TABLE `weekly_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `work_schedules`
--

DROP TABLE IF EXISTS `work_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `work_schedules` (
  `schedule_id` int(11) NOT NULL AUTO_INCREMENT,
  `enrollment_id` int(11) NOT NULL,
  `work_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `note` varchar(500) NOT NULL DEFAULT '',
  `status` varchar(20) NOT NULL DEFAULT 'ACTIVE',
  `created_by` bigint(20) NOT NULL,
  `updated_by` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`schedule_id`),
  KEY `fk_ws_creator` (`created_by`),
  KEY `fk_ws_updater` (`updated_by`),
  KEY `idx_ws_overlap` (`enrollment_id`,`work_date`,`status`,`start_time`,`end_time`),
  CONSTRAINT `fk_ws_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_ws_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `program_enrollments` (`enrollment_id`),
  CONSTRAINT `fk_ws_updater` FOREIGN KEY (`updated_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `chk_ws_times` CHECK (`start_time` >= '00:00:00' and `end_time` <= '23:59:59' and `start_time` < `end_time`),
  CONSTRAINT `chk_ws_status` CHECK (`status` in ('ACTIVE','CANCELLED'))
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `work_schedules`
--

LOCK TABLES `work_schedules` WRITE;
/*!40000 ALTER TABLE `work_schedules` DISABLE KEYS */;
INSERT INTO `work_schedules` VALUES (1,1,'2026-10-15','08:00:00','18:00:00','Ca lam viec tieu chuan','ACTIVE',1,1,'2026-10-15 15:57:13','2026-10-15 15:57:13'),(2,1,'2026-10-16','08:00:00','18:00:00','Ca lam viec tieu chuan','ACTIVE',1,1,'2026-10-15 15:57:13','2026-10-15 15:57:13'),(3,1,'2026-10-17','08:00:00','18:00:00','Ca lam viec tieu chuan','CANCELLED',1,1,'2026-10-15 15:57:13','2026-10-16 18:22:37'),(4,2,'2026-10-15','08:00:00','18:00:00','Ca làm việc tiêu chuẩn','ACTIVE',1,1,'2026-10-16 18:34:47','2026-10-17 16:00:32'),(5,2,'2026-10-16','08:00:00','18:00:00','Ca làm việc tiêu chuẩn','ACTIVE',1,1,'2026-10-16 18:34:47','2026-10-17 16:00:32'),(6,1,'2026-10-25','08:30:00','17:30:00','Ca lam viec tao bang Gmail','ACTIVE',1,1,'2026-10-17 16:21:04','2026-10-17 16:21:04'),(7,1,'2026-10-27','08:30:00','17:30:00','Ca lam viec tao bang Gmail','ACTIVE',1,1,'2026-10-17 16:21:35','2026-10-17 16:21:35'),(8,1,'2026-11-26','08:30:00','17:30:00','Ca lam viec tao bang Gmail','ACTIVE',1,1,'2026-10-17 16:22:13','2026-10-17 16:22:13');
/*!40000 ALTER TABLE `work_schedules` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-17 23:44:29
