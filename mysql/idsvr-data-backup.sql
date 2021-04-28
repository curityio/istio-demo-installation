-- MySQL dump 10.13  Distrib 8.0.22, for Linux (x86_64)
--
-- Host: localhost    Database: idsvr
-- ------------------------------------------------------
-- Server version	8.0.22

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
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accounts` (
  `account_id` varchar(64) NOT NULL DEFAULT '' COMMENT 'ID of this account. Unique.',
  `username` varchar(64) NOT NULL COMMENT 'The username of this account. Unique.',
  `password` varchar(128) DEFAULT NULL COMMENT 'The hashed password. Optional',
  `email` varchar(64) DEFAULT NULL COMMENT 'The associated email address',
  `phone` varchar(32) DEFAULT NULL COMMENT 'The phone number of the account owner. Optional',
  `attributes` json DEFAULT NULL COMMENT 'Key/value map of additional attributes associated with the account.',
  `active` tinyint NOT NULL DEFAULT '0' COMMENT 'Indicates if this account has been activated or not. Activation is usually via email or sms.',
  `created` bigint NOT NULL COMMENT 'Time since epoch of account creation, in seconds',
  `updated` bigint NOT NULL COMMENT 'Time since epoch of latest account update, in seconds',
  PRIMARY KEY (`account_id`),
  UNIQUE KEY `IDX_ACCOUNTS_USERNAME` (`username`),
  UNIQUE KEY `IDX_ACCOUNTS_PHONE` (`phone`),
  UNIQUE KEY `IDX_ACCOUNTS_EMAIL` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `before_insert_accounts` BEFORE INSERT ON `accounts` FOR EACH ROW BEGIN
    SET new.account_id = uuid();
  END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `audit`
--

DROP TABLE IF EXISTS `audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit` (
  `id` varchar(64) NOT NULL COMMENT 'Unique ID of the log message',
  `instant` datetime NOT NULL COMMENT 'Moment that the event was logged',
  `event_instant` varchar(64) NOT NULL COMMENT 'Moment that the event occurred',
  `server` varchar(255) NOT NULL COMMENT 'The server node where the event occurred',
  `message` text NOT NULL COMMENT 'Message describing the event',
  `event_type` varchar(48) NOT NULL COMMENT 'Type of event that the message is about',
  `subject` varchar(128) DEFAULT NULL COMMENT 'The subject (i.e., user) effected by the event',
  `client` varchar(128) DEFAULT NULL COMMENT 'The client ID effected by the event',
  `resource` varchar(128) DEFAULT NULL COMMENT 'The resource ID effected by the event',
  `authenticated_subject` varchar(128) DEFAULT NULL COMMENT 'The authenticated subject (i.e., user) effected by the event',
  `authenticated_client` varchar(128) DEFAULT NULL COMMENT 'The authenticated client effected by the event',
  `acr` varchar(128) DEFAULT NULL COMMENT 'The ACR used to authenticate the subject (i.e., user)',
  `endpoint` varchar(255) DEFAULT NULL COMMENT 'The endpoint where the event was triggered',
  `session` varchar(128) DEFAULT NULL COMMENT 'The session ID in which the event was triggered',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit`
--

LOCK TABLES `audit` WRITE;
/*!40000 ALTER TABLE `audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buckets`
--

DROP TABLE IF EXISTS `buckets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `buckets` (
  `subject` varchar(128) NOT NULL COMMENT 'The subject that together with the purpose identify this bucket',
  `purpose` varchar(64) NOT NULL COMMENT 'The purpose of this bucket, eg. "login_attempt_counter"',
  `attributes` json NOT NULL COMMENT 'All attributes stored for this subject/purpose',
  `created` datetime NOT NULL COMMENT 'When this bucket was created',
  `updated` datetime NOT NULL COMMENT 'When this bucket was last updated',
  PRIMARY KEY (`subject`,`purpose`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buckets`
--

LOCK TABLES `buckets` WRITE;
/*!40000 ALTER TABLE `buckets` DISABLE KEYS */;
/*!40000 ALTER TABLE `buckets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delegations`
--

DROP TABLE IF EXISTS `delegations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delegations` (
  `id` varchar(40) NOT NULL COMMENT 'Unique identifier',
  `owner` varchar(128) NOT NULL,
  `created` bigint NOT NULL COMMENT 'Moment when delegations record is created, as measured in number of seconds since epoch',
  `expires` bigint NOT NULL COMMENT 'Moment when delegation expires, as measured in number of seconds since epoch',
  `scope` varchar(1000) DEFAULT NULL COMMENT 'Space delimited list of scope values',
  `scope_claims` text COMMENT 'JSON with the scope-claims configuration at the time of delegation issuance',
  `client_id` varchar(128) NOT NULL COMMENT 'Reference to a client; non-enforced',
  `redirect_uri` varchar(512) DEFAULT NULL COMMENT 'Optional value for the redirect_uri parameter, when provided in a request for delegation',
  `status` varchar(16) NOT NULL COMMENT 'Status of the delegation instance, from {"issued", "revoked"}',
  `claims` text COMMENT 'Optional JSON-blob that contains a list of claims that are part of the delegation',
  `authentication_attributes` text COMMENT 'The JSON-serialized AuthenticationAttributes established for this delegation',
  `authorization_code_hash` varchar(89) DEFAULT NULL COMMENT 'A hash of the authorization code that was provided when this delegation was issued.',
  PRIMARY KEY (`id`),
  KEY `IDX_AUTHORIZATION_CLIENT_ID` (`client_id`),
  KEY `IDX_AUTHORIZATION_STATUS` (`status`),
  KEY `IDX_AUTHORIZATION_EXPIRES` (`expires`),
  KEY `IDX_AUTHORIZATION_OWNER` (`owner`),
  KEY `IDX_AUTHORIZATION_AUTHORIZATION_CODE_HASH` (`authorization_code_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delegations`
--

LOCK TABLES `delegations` WRITE;
/*!40000 ALTER TABLE `delegations` DISABLE KEYS */;
/*!40000 ALTER TABLE `delegations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `devices`
--

DROP TABLE IF EXISTS `devices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `devices` (
  `id` varchar(64) NOT NULL COMMENT 'Unique ID of the device',
  `device_id` varchar(64) DEFAULT NULL COMMENT 'The device ID that identifies the physical device',
  `account_id` varchar(256) DEFAULT NULL COMMENT 'The user account ID that is associated with the device',
  `external_id` varchar(32) DEFAULT NULL,
  `alias` varchar(30) DEFAULT NULL COMMENT 'The user-recognizable name or mnemonic identifier of the device (e.g., my work iPhone)',
  `form_factor` varchar(10) DEFAULT NULL COMMENT 'The type or form of device (e.g., laptop, phone, tablet, etc.)',
  `device_type` varchar(50) DEFAULT NULL COMMENT 'The device type (i.e., make, manufacturer, provider, class)',
  `owner` varchar(256) DEFAULT NULL COMMENT 'The owner of the device. This is the user who has administrative rights on the device',
  `attributes` json DEFAULT NULL COMMENT 'Key/value map of custom attributes associated with the device.',
  `expires` bigint DEFAULT NULL COMMENT 'Time since epoch of device expiration, in seconds',
  `created` bigint NOT NULL COMMENT 'Time since epoch of device creation, in seconds',
  `updated` bigint NOT NULL COMMENT 'Time since epoch of latest device update, in seconds',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `devices`
--

LOCK TABLES `devices` WRITE;
/*!40000 ALTER TABLE `devices` DISABLE KEYS */;
/*!40000 ALTER TABLE `devices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dynamically_registered_clients`
--

DROP TABLE IF EXISTS `dynamically_registered_clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dynamically_registered_clients` (
  `client_id` varchar(64) NOT NULL COMMENT 'The client ID of this client instance',
  `client_secret` varchar(128) DEFAULT NULL COMMENT 'The hash of this client''s secret',
  `instance_of_client` varchar(64) DEFAULT NULL COMMENT 'The client ID on which this instance is based, or NULL if non-templatized client',
  `created` datetime NOT NULL COMMENT 'When this client was originally created (in UTC time)',
  `updated` datetime NOT NULL COMMENT 'When this client was last updated (in UTC time)',
  `initial_client` varchar(64) DEFAULT NULL COMMENT 'In case the user authenticated, this value contains a client_id value of the initial token. If the initial token was issued through a client credentials-flow, the initial_client value is set to the client that authenticated. Registration without initial token (i.e. with no authentication) will result in a null value for initial_client',
  `authenticated_user` varchar(64) DEFAULT NULL COMMENT 'In case a user authenticated (through a client), this value contains the sub value of the initial token',
  `attributes` json NOT NULL COMMENT 'Arbitrary attributes tied to this client',
  `status` enum('active','inactive','revoked') NOT NULL COMMENT 'The current status of the client',
  `scope` text COMMENT 'Space separated list of scopes defined for this client (non-templatized clients only)',
  `redirect_uris` text COMMENT 'Space separated list of redirect URI''s defined for this client (non-templatized clients only)',
  `grant_types` varchar(128) DEFAULT NULL COMMENT 'Space separated list of grant types defined for this client (non-templatized clients only)',
  PRIMARY KEY (`client_id`),
  KEY `IDX_DRC_INSTANCE_OF_CLIENT` (`instance_of_client`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dynamically_registered_clients`
--

LOCK TABLES `dynamically_registered_clients` WRITE;
/*!40000 ALTER TABLE `dynamically_registered_clients` DISABLE KEYS */;
/*!40000 ALTER TABLE `dynamically_registered_clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `linked_accounts`
--

DROP TABLE IF EXISTS `linked_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linked_accounts` (
  `account_id` varchar(64) NOT NULL COMMENT 'Account ID, typically a global one, of the account being linked from (the linker)',
  `linked_account_id` varchar(64) NOT NULL COMMENT 'Account ID, typically a local or legacy one, of the account being linked (the linkee)',
  `linked_account_domain_name` varchar(64) NOT NULL COMMENT 'The domain (i.e., organizational group or realm) of the account being linked',
  `linking_account_manager` varchar(128) DEFAULT NULL COMMENT 'The account manager handling this linked account',
  `created` datetime NOT NULL COMMENT 'The instant in time this link was created',
  PRIMARY KEY (`linked_account_id`,`linked_account_domain_name`),
  KEY `IDX_LINKED_ACCOUNTS_ACCOUNTS_ID` (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `linked_accounts`
--

LOCK TABLES `linked_accounts` WRITE;
/*!40000 ALTER TABLE `linked_accounts` DISABLE KEYS */;
/*!40000 ALTER TABLE `linked_accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nonces`
--

DROP TABLE IF EXISTS `nonces`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nonces` (
  `token` varchar(64) NOT NULL COMMENT 'Value issued as random nonce',
  `reference_data` text NOT NULL COMMENT 'Value that is referenced by the nonce value',
  `created` bigint NOT NULL COMMENT 'Moment when nonce record is created, as measured in number of seconds since epoch',
  `ttl` bigint NOT NULL COMMENT 'Time To Live, period in seconds since created after which the nonce expires',
  `consumed` bigint DEFAULT NULL COMMENT 'Moment when nonce was consumed, as measured in number of seconds since epoch',
  `status` varchar(16) NOT NULL DEFAULT 'issued' COMMENT 'Status of the nonce from {"issued", "revoked", "used"}',
  PRIMARY KEY (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nonces`
--

LOCK TABLES `nonces` WRITE;
/*!40000 ALTER TABLE `nonces` DISABLE KEYS */;
/*!40000 ALTER TABLE `nonces` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(64) NOT NULL COMMENT 'Id given to the session',
  `session_data` text NOT NULL COMMENT 'Value that is referenced by the session id',
  `expires` bigint NOT NULL COMMENT 'Moment when session record expires, as measured in number of seconds since epoch',
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_SESSIONS_ID_EXPIRES` (`id`,`expires`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tokens`
--

DROP TABLE IF EXISTS `tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tokens` (
  `token_hash` varchar(89) NOT NULL COMMENT 'Base64 encoded sha-512 hash of the token value.',
  `id` varchar(64) DEFAULT NULL COMMENT 'Identifier of the token, when it exists, this can be the value from the "jti"-claim of a JWT, etc. Opaque tokens do not have an id.',
  `delegations_id` varchar(40) NOT NULL COMMENT 'Reference to the delegation instance that underlies the token',
  `purpose` varchar(32) NOT NULL COMMENT 'Purpose of the token, i.e. "nonce", "accesstoken", "refreshtoken", "custom", etc.',
  `usage` varchar(8) NOT NULL COMMENT 'Indication whether the token is a bearer or proof token, from {"bearer", "proof"}',
  `format` varchar(32) NOT NULL COMMENT 'The format of the token, i.e. "opaque", "jwt", etc.',
  `created` bigint NOT NULL COMMENT 'Moment when token record is created, as measured in number of seconds since epoch',
  `expires` bigint NOT NULL COMMENT 'Moment when token expires, as measured in number of seconds since epoch',
  `scope` varchar(1000) DEFAULT NULL COMMENT 'Space delimited list of scope values',
  `scope_claims` text COMMENT 'Space delimited list of scope-claims values',
  `status` varchar(16) NOT NULL COMMENT 'Status of the token from {"issued", "used", "revoked"}',
  `issuer` varchar(200) NOT NULL COMMENT 'Optional name of the issuer of the token (jwt.iss)',
  `subject` varchar(64) NOT NULL COMMENT 'Optional subject of the token (jwt.sub)',
  `audience` varchar(512) DEFAULT NULL COMMENT 'Space separated list of audiences for the token (jwt.aud)',
  `not_before` bigint DEFAULT NULL COMMENT 'Moment before which the token is not valid, as measured in number of seconds since epoch (jwt.nbf)',
  `claims` text COMMENT 'Optional JSON-blob that contains a list of claims that are part of the token',
  `meta_data` text,
  PRIMARY KEY (`token_hash`),
  KEY `IDX_TOKENS_ID` (`id`),
  KEY `IDX_TOKENS_STATUS` (`status`),
  KEY `IDX_TOKENS_EXPIRES` (`expires`),
  KEY `FK_DELEGATION_DELEGATION_ID_idx` (`delegations_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tokens`
--

LOCK TABLES `tokens` WRITE;
/*!40000 ALTER TABLE `tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `tokens` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-04-28 14:26:00
