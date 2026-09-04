-- --------------------------------------------------------
-- Servidor:                     127.0.0.1
-- Versão do servidor:           12.1.2-MariaDB - MariaDB Server
-- OS do Servidor:               Win64
-- HeidiSQL Versão:              12.11.0.7065
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Copiando estrutura do banco de dados para snaplock_db
CREATE DATABASE IF NOT EXISTS `snaplock_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci */;
USE `snaplock_db`;

-- Copiando estrutura para tabela snaplock_db.amizade
CREATE TABLE IF NOT EXISTS `amizade` (
  `id_amizade` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario_1` int(11) NOT NULL,
  `id_usuario_2` int(11) NOT NULL,
  `status` enum('pendente','aceito','recusado') NOT NULL DEFAULT 'pendente',
  `data_solicitacao` datetime NOT NULL DEFAULT current_timestamp(),
  `data_resposta` datetime DEFAULT NULL,
  PRIMARY KEY (`id_amizade`),
  UNIQUE KEY `uq_amizade` (`id_usuario_1`,`id_usuario_2`),
  KEY `fk_amizade_usuario2` (`id_usuario_2`),
  KEY `idx_amizade_status` (`status`),
  CONSTRAINT `fk_amizade_usuario1` FOREIGN KEY (`id_usuario_1`) REFERENCES `usuario` (`id_usuario`),
  CONSTRAINT `fk_amizade_usuario2` FOREIGN KEY (`id_usuario_2`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Copiando dados para a tabela snaplock_db.amizade: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela snaplock_db.curtida
CREATE TABLE IF NOT EXISTS `curtida` (
  `id_usuario` int(11) NOT NULL,
  `id_foto` int(11) NOT NULL,
  `data_hora` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_usuario`,`id_foto`),
  KEY `fk_curtida_foto` (`id_foto`),
  CONSTRAINT `fk_curtida_foto` FOREIGN KEY (`id_foto`) REFERENCES `foto` (`id_foto`),
  CONSTRAINT `fk_curtida_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Copiando dados para a tabela snaplock_db.curtida: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela snaplock_db.foto
CREATE TABLE IF NOT EXISTS `foto` (
  `id_foto` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `midia_url` varchar(255) NOT NULL,
  `legenda` text DEFAULT NULL,
  `filtro_aplicado` varchar(50) DEFAULT NULL,
  `data_postagem` datetime NOT NULL DEFAULT current_timestamp(),
  `visibilidade` enum('amigos','privado') NOT NULL DEFAULT 'amigos',
  PRIMARY KEY (`id_foto`),
  KEY `idx_foto_usuario_data` (`id_usuario`,`data_postagem`),
  CONSTRAINT `fk_foto_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Copiando dados para a tabela snaplock_db.foto: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela snaplock_db.usuario
CREATE TABLE IF NOT EXISTS `usuario` (
  `id_usuario` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `senha_hash` varchar(255) NOT NULL,
  `foto_perfil` varchar(255) DEFAULT NULL,
  `data_nascimento` date NOT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `data_criacao` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_usuario_ativo` (`ativo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE TABLE IF NOT EXISTS `recuperacao_senha` (
  `id_recuperacao` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expira_em` datetime NOT NULL,
  `enviado_em` datetime NOT NULL DEFAULT current_timestamp(),
  `usado_em` datetime DEFAULT NULL,
  PRIMARY KEY (`id_recuperacao`),
  KEY `idx_recuperacao_usuario` (`id_usuario`),
  KEY `idx_recuperacao_token` (`token_hash`),
  CONSTRAINT `fk_recuperacao_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Copiando dados para a tabela snaplock_db.usuario: ~0 rows (aproximadamente)

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
