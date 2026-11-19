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

-- Copiando estrutura para tabela snaplock_db.alteracao_email_token
CREATE TABLE IF NOT EXISTS `alteracao_email_token` (
  `id_alteracao` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `novo_email` varchar(150) NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expira_em` datetime NOT NULL,
  `enviado_em` datetime NOT NULL DEFAULT current_timestamp(),
  `usado_em` datetime DEFAULT NULL,
  PRIMARY KEY (`id_alteracao`),
  KEY `idx_alteracao_email_usuario` (`id_usuario`),
  KEY `idx_alteracao_email_token` (`token_hash`),
  CONSTRAINT `fk_alteracao_email_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Copiando dados para a tabela snaplock_db.alteracao_email_token: ~0 rows (aproximadamente)
INSERT IGNORE INTO `alteracao_email_token` (`id_alteracao`, `id_usuario`, `novo_email`, `token_hash`, `expira_em`, `enviado_em`, `usado_em`) VALUES
	(1, 15, 'gigisantanasilva@gmail.com', 'ded2dbd96c391c24788390c212fe5550b74405d53d1e3147188a49afd9fbcb76', '2026-11-06 10:01:32', '2026-11-06 09:46:32', '2026-11-06 09:47:08');

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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Copiando dados para a tabela snaplock_db.amizade: ~11 rows (aproximadamente)
INSERT IGNORE INTO `amizade` (`id_amizade`, `id_usuario_1`, `id_usuario_2`, `status`, `data_solicitacao`, `data_resposta`) VALUES
	(13, 24, 21, 'aceito', '2026-10-16 08:37:13', '2026-10-16 08:37:45'),
	(15, 15, 21, 'aceito', '2026-10-23 10:59:18', '2026-10-29 11:03:50'),
	(16, 15, 10, 'aceito', '2026-10-23 11:01:26', '2026-10-23 11:02:52'),
	(17, 18, 10, 'aceito', '2026-10-29 10:39:46', '2026-10-29 10:40:17'),
	(18, 26, 10, 'aceito', '2026-10-29 10:55:38', '2026-10-29 10:59:38'),
	(19, 26, 21, 'pendente', '2026-11-05 09:32:03', NULL),
	(20, 23, 15, 'aceito', '2026-11-05 09:39:10', '2026-11-05 09:45:30'),
	(21, 23, 10, 'aceito', '2026-11-05 09:39:13', '2026-11-06 08:45:49'),
	(22, 23, 22, 'aceito', '2026-11-05 09:40:11', '2026-11-05 09:40:53'),
	(23, 22, 10, 'aceito', '2026-11-05 09:44:02', '2026-11-06 08:45:52'),
	(24, 22, 15, 'aceito', '2026-11-05 09:44:05', '2026-11-05 09:45:27'),
	(25, 15, 26, 'aceito', '2026-11-10 09:41:33', '2026-11-10 10:17:36');

-- Copiando estrutura para tabela snaplock_db.cadastro_email_verificacao
CREATE TABLE IF NOT EXISTS `cadastro_email_verificacao` (
  `id_verificacao` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `username` varchar(30) NOT NULL,
  `email` varchar(150) NOT NULL,
  `senha_hash` varchar(255) NOT NULL,
  `data_nascimento` date NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expira_em` datetime NOT NULL,
  `tentativas` int(11) NOT NULL DEFAULT 0,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  `verificado_em` datetime DEFAULT NULL,
  PRIMARY KEY (`id_verificacao`),
  KEY `idx_cadastro_verificacao_email` (`email`),
  KEY `idx_cadastro_verificacao_token` (`token_hash`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Copiando dados para a tabela snaplock_db.cadastro_email_verificacao: ~1 rows (aproximadamente)
INSERT IGNORE INTO `cadastro_email_verificacao` (`id_verificacao`, `nome`, `username`, `email`, `senha_hash`, `data_nascimento`, `token_hash`, `expira_em`, `tentativas`, `criado_em`, `verificado_em`) VALUES
	(8, 'Marina', 'marininha', 'marianabandonisenai@gmail.com', '', '2010-11-12', '7a864638553757d2a96fcda742aaa05d67ebab7c8df82f1753ad5e4e3bf18740', '2026-11-12 10:03:13', 0, '2026-11-12 09:48:13', '2026-11-12 09:48:37');

-- Copiando estrutura para tabela snaplock_db.curtida
CREATE TABLE IF NOT EXISTS `curtida` (
  `id_usuario` int(11) NOT NULL,
  `id_foto` int(11) NOT NULL,
  `data_curtida` datetime DEFAULT NULL,
  `data_hora` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_usuario`,`id_foto`),
  KEY `fk_curtida_foto` (`id_foto`),
  CONSTRAINT `fk_curtida_foto` FOREIGN KEY (`id_foto`) REFERENCES `foto` (`id_foto`),
  CONSTRAINT `fk_curtida_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Copiando dados para a tabela snaplock_db.curtida: ~6 rows (aproximadamente)
INSERT IGNORE INTO `curtida` (`id_usuario`, `id_foto`, `data_curtida`, `data_hora`) VALUES
	(10, 2, '2026-10-23 09:18:50', '2026-10-23 09:18:50'),
	(10, 21, '2026-11-03 09:17:14', '2026-11-03 09:17:14'),
	(10, 24, '2026-11-05 09:05:11', '2026-11-05 09:05:11'),
	(15, 12, '2026-10-23 09:13:49', '2026-10-23 09:13:49'),
	(18, 12, '2026-10-29 10:41:27', '2026-10-29 10:41:27');

-- Copiando estrutura para tabela snaplock_db.denuncia
CREATE TABLE IF NOT EXISTS `denuncia` (
  `id_foto` int(11) NOT NULL,
  `quantidade_denuncias` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_foto`),
  CONSTRAINT `fk_denuncia_foto` FOREIGN KEY (`id_foto`) REFERENCES `foto` (`id_foto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Copiando dados para a tabela snaplock_db.denuncia: ~6 rows (aproximadamente)
INSERT IGNORE INTO `denuncia` (`id_foto`, `quantidade_denuncias`) VALUES
	(12, 1),
	(33, 4),
	(34, 4),
	(35, 4),
	(36, 4),
	(37, 4),
	(38, 4);

-- Copiando estrutura para tabela snaplock_db.denuncia_detalhe
CREATE TABLE IF NOT EXISTS `denuncia_detalhe` (
  `id_denuncia` int(11) NOT NULL AUTO_INCREMENT,
  `id_foto` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `motivo` text NOT NULL,
  `data_denuncia` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_denuncia`),
  UNIQUE KEY `uq_denuncia_detalhe_foto_usuario` (`id_foto`,`id_usuario`),
  KEY `idx_denuncia_detalhe_usuario` (`id_usuario`),
  CONSTRAINT `fk_denuncia_detalhe_foto` FOREIGN KEY (`id_foto`) REFERENCES `foto` (`id_foto`),
  CONSTRAINT `fk_denuncia_detalhe_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Copiando dados para a tabela snaplock_db.denuncia_detalhe: ~22 rows (aproximadamente)
INSERT IGNORE INTO `denuncia_detalhe` (`id_denuncia`, `id_foto`, `id_usuario`, `motivo`, `data_denuncia`) VALUES
	(1, 12, 15, 'Violência', '2026-10-23 08:55:48'),
	(2, 33, 10, 'Indesejado', '2026-11-10 09:40:36'),
	(3, 33, 26, 'Indesejado', '2026-11-10 10:17:54'),
	(4, 33, 22, 'Indesejado', '2026-11-10 10:19:03'),
	(5, 33, 23, 'Indesejado', '2026-11-10 10:29:06'),
	(6, 34, 15, 'Spam', '2026-11-10 11:08:37'),
	(7, 34, 23, 'Spam', '2026-11-10 11:08:57'),
	(8, 34, 22, 'Spam', '2026-11-10 11:09:20'),
	(9, 34, 26, 'Spam', '2026-11-10 11:10:24'),
	(10, 35, 15, 'Indesejado', '2026-11-11 08:39:30'),
	(11, 35, 23, 'Indesejado', '2026-11-11 08:40:05'),
	(12, 35, 26, 'Indesejado', '2026-11-11 08:41:43'),
	(13, 35, 22, 'Indesejado', '2026-11-11 08:47:35'),
	(14, 36, 10, 'Violência, Spam', '2026-11-11 08:57:09'),
	(15, 36, 22, 'Violência, Spam', '2026-11-11 08:57:30'),
	(16, 36, 23, 'Violência, Spam', '2026-11-11 08:57:54'),
	(17, 36, 26, 'Violência, Spam', '2026-11-11 08:58:12'),
	(18, 37, 15, 'Indesejado', '2026-11-11 09:13:37'),
	(19, 37, 22, 'Inapropriado, Indesejado', '2026-11-11 09:14:42'),
	(20, 37, 23, 'Inapropriado', '2026-11-11 09:15:33'),
	(21, 37, 26, 'Outro', '2026-11-11 09:16:06'),
	(32, 38, 23, 'Inapropriado', '2026-11-11 10:11:04'),
	(33, 38, 15, 'Inapropriado', '2026-11-11 10:12:35'),
	(34, 38, 26, 'Inapropriado', '2026-11-11 10:14:46'),
	(35, 38, 22, 'Inapropriado', '2026-11-11 10:16:11');

-- Copiando estrutura para tabela snaplock_db.dump_visibilidade
CREATE TABLE IF NOT EXISTS `dump_visibilidade` (
  `id_usuario` int(11) NOT NULL,
  `ano` int(11) NOT NULL,
  `mes` int(11) NOT NULL,
  `visivel` tinyint(1) NOT NULL DEFAULT 0,
  `capa_url` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id_usuario`,`ano`,`mes`),
  CONSTRAINT `fk_dump_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Copiando dados para a tabela snaplock_db.dump_visibilidade: ~2 rows (aproximadamente)
INSERT IGNORE INTO `dump_visibilidade` (`id_usuario`, `ano`, `mes`, `visivel`, `capa_url`) VALUES
	(10, 2026, 10, 1, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1791468658/fotos/yylykv3zvg0w1w3bptou.png'),
	(15, 2026, 10, 1, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1793018322/fotos/fr1fccqtcrkg6gbsni7b.png');

-- Copiando estrutura para tabela snaplock_db.foto
CREATE TABLE IF NOT EXISTS `foto` (
  `id_foto` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `midia_url` varchar(255) NOT NULL,
  `legenda` text DEFAULT NULL,
  `filtro_aplicado` varchar(50) DEFAULT NULL,
  `data_postagem` datetime NOT NULL DEFAULT current_timestamp(),
  `proporcao` double DEFAULT NULL,
  `ativa` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_foto`),
  KEY `idx_foto_usuario_data` (`id_usuario`,`data_postagem`),
  CONSTRAINT `fk_foto_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Copiando dados para a tabela snaplock_db.foto: ~21 rows (aproximadamente)
INSERT IGNORE INTO `foto` (`id_foto`, `id_usuario`, `midia_url`, `legenda`, `filtro_aplicado`, `data_postagem`, `proporcao`, `ativa`) VALUES
	(2, 15, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1790941708/fotos/uqiqngtiwy3zkapytsex.jpg', '🦇', NULL, '2026-10-02 08:48:37', NULL, 1),
	(12, 10, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1791468658/fotos/yylykv3zvg0w1w3bptou.png', '☕💌', NULL, '2026-10-08 11:11:09', 1, 1),
	(19, 15, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1793015696/fotos/t7wanqvzsnor41xwl5mw.jpg', 'saudades praia!', NULL, '2026-10-26 08:54:27', 1.5, 1),
	(21, 15, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1793018322/fotos/fr1fccqtcrkg6gbsni7b.png', 'Meu desenho favorito', 'vintage', '2026-10-26 09:38:13', 1.3395348837209302, 1),
	(22, 18, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1793281193/fotos/syp1f7kcdlwffhm1tktk.jpg', 'amo praia', NULL, '2026-10-29 10:39:26', 1.4961038961038962, 1),
	(23, 26, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1793282138/fotos/csrhwfufua8hrh9ubpns.png', 'Amo branca de neve !!', 'sepia', '2026-10-29 10:55:11', 1.4961038961038962, 1),
	(24, 15, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1793880333/fotos/wnj0udlqkfzluf8uuuuh.jpg', 'Em busca de inspirações', NULL, '2026-11-05 09:04:20', 1.4072948328267476, 1),
	(25, 10, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1793881644/fotos/i9a3rxmbexvblpsbxokn.jpg', 'Dia de passeio 🐶', NULL, '2026-11-05 09:26:11', 0.8, 1),
	(26, 10, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1793881743/fotos/v1pfnglizptgxvxtiue2.jpg', 'Brunch time :)', NULL, '2026-11-05 09:27:50', 1.3880597014925373, 1),
	(27, 26, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1793882030/fotos/yhztbaldzeh1llzbpmin.jpg', 'Netinho veio visitar a vovó', NULL, '2026-11-05 09:32:37', 1.264797507788162, 1),
	(28, 26, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1793882104/fotos/mmywhihkrlcqg1rrqik4.jpg', 'Trabalhando em casa hoje ❤️', NULL, '2026-11-05 09:33:51', 0.8012422360248447, 1),
	(29, 23, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1793882332/fotos/gwpfk3tgdogo960q7pv1.jpg', 'Por ai 😎', NULL, '2026-11-05 09:37:39', 1.2685185185185186, 1),
	(30, 23, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1793882404/fotos/zsjnfhvf1fqg007hplz2.jpg', 'Amo te ouvir cantar 😍', NULL, '2026-11-05 09:38:51', 0.7974683544303798, 1),
	(31, 22, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1793882661/fotos/tdu1vwpfsmlarnufq8lg.jpg', 'Arte :)', NULL, '2026-11-05 09:43:08', 1.4483985765124556, 1),
	(32, 22, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1793882705/fotos/lbwrdbx3rm27m16wsimg.jpg', 'Minha lua de mel ❤️', NULL, '2026-11-05 09:43:52', 0.7994791666666666, 1),
	(33, 15, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1794314288/fotos/xgk8c9augzbmj3uea3y6.jpg', 'morta', NULL, '2026-11-10 09:36:56', 1.0556701030927835, 0),
	(34, 10, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1794319741/fotos/pb8m5kpi9sl3cnr6swsj.jpg', '', NULL, '2026-11-10 11:07:48', 1.4961038961038962, 0),
	(35, 10, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1794397183/fotos/tidepinwna7on3psve0r.jpg', '', NULL, '2026-11-11 08:38:31', 0.976, 0),
	(36, 15, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1794398263/fotos/mijyxlspedgepqwonbef.jpg', '', NULL, '2026-11-11 08:56:31', 0.976, 0),
	(37, 10, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1794399259/fotos/mx5jgckxxfh0rrmyzefa.jpg', '', NULL, '2026-11-11 09:13:07', 0.976, 0),
	(38, 10, 'https://res.cloudinary.com/wabuuqrt/image/upload/v1794401008/fotos/hptbbyjymygv1qwts4zb.jpg', '', NULL, '2026-11-11 09:42:16', 0.976, 0);

-- Copiando estrutura para tabela snaplock_db.moderacao_conteudo
CREATE TABLE IF NOT EXISTS `moderacao_conteudo` (
  `id_registro` int(11) NOT NULL AUTO_INCREMENT,
  `id_foto` int(11) DEFAULT NULL,
  `id_usuario_reportado` int(11) DEFAULT NULL,
  `tipo_infracao` varchar(100) NOT NULL,
  `conteudo_flagrado` text DEFAULT NULL,
  `data_deteccao` datetime NOT NULL DEFAULT current_timestamp(),
  `acao_tomada` varchar(100) DEFAULT NULL,
  `score_confianca` decimal(5,2) DEFAULT NULL COMMENT 'Ex: 0.92 = 92% de certeza que é ofensivo (retornado pela IA)',
  `origem_deteccao` enum('lista_palavras','ia_externa','denuncia_usuario') DEFAULT 'ia_externa',
  PRIMARY KEY (`id_registro`),
  KEY `fk_moderacao_foto` (`id_foto`),
  KEY `fk_moderacao_usuario` (`id_usuario_reportado`),
  KEY `idx_moderacao_origem` (`origem_deteccao`,`score_confianca`),
  CONSTRAINT `fk_moderacao_foto` FOREIGN KEY (`id_foto`) REFERENCES `foto` (`id_foto`) ON DELETE SET NULL,
  CONSTRAINT `fk_moderacao_usuario` FOREIGN KEY (`id_usuario_reportado`) REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Copiando dados para a tabela snaplock_db.moderacao_conteudo: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela snaplock_db.recuperacao_senha
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
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela snaplock_db.recuperacao_senha: ~3 rows (aproximadamente)
INSERT IGNORE INTO `recuperacao_senha` (`id_recuperacao`, `id_usuario`, `token_hash`, `expira_em`, `enviado_em`, `usado_em`) VALUES
	(21, 14, '4200466a8039923baef429bfffc1a165aca268e70a85623bb19377bcc6ab7231', '2026-09-10 08:33:56', '2026-09-10 08:18:56', NULL),
	(24, 23, '5da19b9b82099f8bcc00236eb4b49504a3aa29490367102e0a48c291272ea637', '2026-10-01 09:07:05', '2026-10-01 08:52:05', '2026-10-01 08:52:58'),
	(25, 14, '9c737f748b508fb943004d822f08006ed2571fd89417a3e1b01abbee16ee355a', '2026-10-29 09:48:00', '2026-10-29 09:33:00', '2026-10-29 09:33:35'),
	(26, 26, 'a6177382576fa691e62de7fdde23911dc70492fa3847ed9cd6eb26c7a427510e', '2026-11-10 10:34:38', '2026-11-10 10:19:38', NULL);

-- Copiando estrutura para tabela snaplock_db.usuario
CREATE TABLE IF NOT EXISTS `usuario` (
  `id_usuario` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `username` varchar(30) NOT NULL,
  `email` varchar(150) NOT NULL,
  `senha_hash` varchar(255) NOT NULL,
  `foto_perfil` varchar(255) DEFAULT NULL,
  `data_nascimento` date NOT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `data_criacao` datetime NOT NULL DEFAULT current_timestamp(),
  `biografia` varchar(255) DEFAULT NULL,
  `email_ativo` varchar(150) GENERATED ALWAYS AS (case when `ativo` = 1 then `email` else NULL end) STORED,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `uq_usuario_email_ativo` (`email_ativo`),
  KEY `idx_usuario_ativo` (`ativo`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Copiando dados para a tabela snaplock_db.usuario: ~11 rows (aproximadamente)
INSERT IGNORE INTO `usuario` (`id_usuario`, `nome`, `username`, `email`, `senha_hash`, `foto_perfil`, `data_nascimento`, `ativo`, `data_criacao`, `biografia`) VALUES
	(10, 'Lorena', 'lorena11', 'llomarques2007@gmail.com', '$2a$10$XLgtBVa5t25dhRlvVCaIL.W11RriOHRkopp.AhD6dOP7qKdbFRTIy', 'https://res.cloudinary.com/wabuuqrt/image/upload/v1793881517/perfil/lg9aisngwhwecqdfzjpa.png', '2007-03-11', 1, '2026-09-03 10:51:32', 'Colecionando pores do sol, histórias e momentos inesquecíveis. 🌊'),
	(14, 'Isabella', 'isabella_leite', 'isabella.leite562@gmail.com', '$2a$10$B96KpRBhPfBTv6kAg/yUuuwGRcdpZAeuRYme/hF2OcV.DWbHGoXxO', NULL, '2007-09-16', 0, '2026-09-04 11:14:24', NULL),
	(15, 'Giovanna', 'gigi07', 'gigisantanasilva@gmail.com', '$2a$10$Ppnf4xpqkROTgn6bVJk.ae2Iu/U8hbzjnQ4PnwlJlAmr5Tj.ovUiW', 'https://res.cloudinary.com/wabuuqrt/image/upload/v1793880288/perfil/viygkxnxd44a5n2sooup.jpg', '2006-09-07', 1, '2026-09-08 08:37:15', 'Entre acordes, sol e liberdade. A música é meu jeito de florescer! ☀️🌻'),
	(16, 'Cintia', 'cintinha_00', 'cintiamimimi@gmail.com', '$2a$10$KLc0WihwMr59BF3rjdqnzeXxChk.60vM6GEpHyPpFoC27UX3dQPH2', NULL, '2003-09-08', 0, '2026-09-08 08:57:42', NULL),
	(18, 'Isabela', 'bella_09', 'isabella.leite400@gmail.com', '$2a$10$ndN/zyqtxVQMvHY7PvZgieAO4om1lBPRxZjcu4CPp5dxbI5yirEke', NULL, '2009-09-02', 0, '2026-09-08 11:12:04', NULL),
	(19, 'Nicolly', 'nicks_', 'nicollysantossilva0508@gmail.com', '$2a$10$8We9UCIaB08lePKPx9NLietRuEjGKc51BywFrhP5tVEr2xoDgbio.', NULL, '2008-08-09', 0, '2026-09-10 08:50:05', NULL),
	(21, 'luluzinha', 'lucia', 'lucialivre@gmail.com', '$2a$10$yra3R2AYonv6c/3cwFusJ.YTAAk664hCBQeELxlUvTZqtjWc3b3CK', 'https://res.cloudinary.com/wabuuqrt/image/upload/v1789651696/perfil/pdsu4qggfi54uhqdwu76.png', '2008-09-10', 0, '2026-09-10 10:29:46', 'amo viver'),
	(22, 'Mariana', 'maridias', 'marianabandoni2007@gmail.com', '$2a$10$4K9zAL4N1DRT8vr.6GYES.k7McooOciq04S3AqyIyrNRWAyyFtYB2', 'https://res.cloudinary.com/wabuuqrt/image/upload/v1793882611/perfil/xrllvgfwx6rntmex27zb.jpg', '2007-02-19', 1, '2026-09-17 10:30:45', 'Vivendo sobre rodas, colecionando manobras, tombos e histórias. 🛹'),
	(23, 'Vitor', 'vitinho04', 'vitor.pimenteel04@gmail.com', '$2a$10$9cqElZyrN9vVD84xqFrYZOTeGkIT2FPh6f49kmmsKxWNzxeI4QhPi', 'https://res.cloudinary.com/wabuuqrt/image/upload/v1793882274/perfil/gp2zfgsxszhsztkmsosj.png', '2009-03-04', 1, '2026-09-17 10:44:36', 'Na correria da cidade, sempre atrás de novas histórias e boas vibrações. 🎧⚡'),
	(24, 'Mariana', 'maribandoni', 'marilalala@gmail.com', '$2a$10$8ao4LJed9sbHCCN4g4/GS.3zfLTh8vXu5.LK2LUezWWzHgRAVjmoq', 'https://res.cloudinary.com/wabuuqrt/image/upload/v1792150589/perfil/iodt3gymosmbq2wuo71q.png', '2007-02-19', 0, '2026-10-16 08:36:00', 'Marimbondo'),
	(26, 'Isabella', 'isa_bella', 'isabella.leite400@gmail.com', '$2a$10$JsQLWMOWtsey9haKsZvcv.djNwfxHrFKe2eIK9JCTztK8Hi.xD4WW', 'https://res.cloudinary.com/wabuuqrt/image/upload/v1793881985/perfil/wmmy8hgfccbvirc54qpg.jpg', '2009-02-09', 1, '2026-10-29 10:49:56', 'oiii, sou nova por aqui!'),
	(27, 'Marina', 'marininha', 'marianabandonisenai@gmail.com', '$2a$10$yd7K07eixht/Zl86ZXEG0u5n3.24HczVH.lmZNloylFJta7vYpzgi', NULL, '2010-11-12', 1, '2026-11-12 09:48:37', NULL);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
