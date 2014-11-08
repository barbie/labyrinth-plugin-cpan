DROP TABLE IF EXISTS `uploads`;
CREATE TABLE `uploads` (
  `type` varchar(10) NOT NULL,
  `author` varchar(32) NOT NULL,
  `dist` varchar(255) NOT NULL,
  `version` varchar(255) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `released` int(10) NOT NULL,
  PRIMARY KEY (`author`,`dist`,`version`),
  KEY `IXDIST` (`dist`),
  KEY `IXAUTH` (`author`),
  KEY `IXDATE` (`released`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

INSERT INTO `uploads` VALUES ('backpan','BARBIE','Acme-CPANAuthors-BackPAN-OneHundred','1.00','Acme-CPANAuthors-BackPAN-OneHundred-1.00.tar.gz',1401615057);
INSERT INTO `uploads` VALUES ('backpan','BARBIE','Acme-CPANAuthors-BackPAN-OneHundred','1.01','Acme-CPANAuthors-BackPAN-OneHundred-1.01.tar.gz',1402193203);
INSERT INTO `uploads` VALUES ('backpan','BARBIE','Acme-CPANAuthors-BackPAN-OneHundred','1.02','Acme-CPANAuthors-BackPAN-OneHundred-1.02.tar.gz',1403834704);
INSERT INTO `uploads` VALUES ('cpan','BARBIE','Acme-CPANAuthors-BackPAN-OneHundred','1.03','Acme-CPANAuthors-BackPAN-OneHundred-1.03.tar.gz',1408262115);
INSERT INTO `uploads` VALUES ('cpan','BARBIE','Acme-CPANAuthors-BackPAN-OneHundred','1.04','Acme-CPANAuthors-BackPAN-OneHundred-1.04.tar.gz',1412417073);

