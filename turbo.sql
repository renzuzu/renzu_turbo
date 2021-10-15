CREATE TABLE IF NOT EXISTS `renzu_turbo` (
  `plate` varchar(64) NOT NULL DEFAULT '',
  `turbo` longtext NULL,
  PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;