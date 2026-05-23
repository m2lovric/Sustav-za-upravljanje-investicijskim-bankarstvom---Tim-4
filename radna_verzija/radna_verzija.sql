DROP DATABASE IF EXISTS InvesticijskoBankarstvo;

CREATE DATABASE InvesticijskoBankarstvo;
USE InvesticijskoBankarstvo;

CREATE TABLE klijent(
	id INT PRIMARY KEY AUTO_INCREMENT,
	ime VARCHAR(45) NOT NULL,
	prezime VARCHAR(45) NOT NULL,
	OIB VARCHAR(11) NOT NULL UNIQUE,
	email VARCHAR(255) NOT NULL UNIQUE,
	telefon VARCHAR(20) NOT NULL UNIQUE,
	ulica_i_kucni_broj VARCHAR(255) NOT NULL,
	postanski_broj CHAR(5) NOT NULL,
	CHECK (OIB REGEXP '^[0-9]{11}$'),
	CHECK (postanski_broj REGEXP '^[0-9]{5}$')
);

CREATE TABLE banka(
	id INT PRIMARY KEY AUTO_INCREMENT,
	ime VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE investicijski_racun(
	id INT PRIMARY KEY AUTO_INCREMENT,
	klijent_id INT NOT NULL,
	banka_id INT NOT NULL,
	broj_racuna VARCHAR(21) NOT NULL UNIQUE,
	stanje DECIMAL(38,12) NOT NULL,
	datum_otvaranja DATE NOT NULL,
	FOREIGN KEY (klijent_id) REFERENCES klijent (id) ON DELETE CASCADE,
	FOREIGN KEY (banka_id) REFERENCES banka (id) ON DELETE RESTRICT,
	CHECK (broj_racuna REGEXP '^[0-9]{21}$')
);

CREATE TABLE portfelj(
	id INT PRIMARY KEY AUTO_INCREMENT,
	investicijski_racun_id INT NOT NULL,
	ime VARCHAR(100) NOT NULL,
	datum_otvaranja DATETIME NOT NULL,
	FOREIGN KEY (investicijski_racun_id) REFERENCES investicijski_racun (id) ON DELETE CASCADE
);

CREATE TABLE uplata_isplata(
	id INT PRIMARY KEY AUTO_INCREMENT,
	investicijski_racun_id INT NOT NULL,
	iznos DECIMAL(38,12) UNSIGNED NOT NULL,
	datum DATETIME NOT NULL,
	vrsta_prometa ENUM("uplata", "isplata") NOT NULL,
	FOREIGN KEY (investicijski_racun_id) REFERENCES investicijski_racun (id) ON DELETE CASCADE
);

CREATE TABLE tip_imovine(
	id INT PRIMARY KEY AUTO_INCREMENT,
	tip VARCHAR(45) NOT NULL UNIQUE
);

CREATE TABLE imovina(
	id INT PRIMARY KEY AUTO_INCREMENT,
	ime VARCHAR(45) NOT NULL UNIQUE,
	tip_imovine_id INT NOT NULL,
	trenutna_cijena DECIMAL(38,18) UNSIGNED NOT NULL,
	FOREIGN KEY (tip_imovine_id) REFERENCES tip_imovine(id) ON DELETE RESTRICT
);

CREATE TABLE tip_transakcije(
	id INT PRIMARY KEY AUTO_INCREMENT,
	tip VARCHAR(45) NOT NULL UNIQUE
);

CREATE TABLE transakcija(
	id INT PRIMARY KEY AUTO_INCREMENT,
	investicijski_racun_id INT NOT NULL,
	imovina_id INT NOT NULL,
	tip_transakcije_id INT NOT NULL,
	kolicina DECIMAL(38,18) UNSIGNED NOT NULL,
	cijena DECIMAL(38,18) UNSIGNED NOT NULL,
	naknada DECIMAL(38,18) UNSIGNED NULL,
	datum DATETIME NOT NULL,
	FOREIGN KEY (investicijski_racun_id) REFERENCES investicijski_racun(id) ON DELETE CASCADE,
	FOREIGN KEY (imovina_id) REFERENCES imovina (id) ON DELETE RESTRICT,
	FOREIGN KEY (tip_transakcije_id) REFERENCES tip_transakcije (id) ON DELETE RESTRICT
);

CREATE TABLE portfelj_imovina(
	id INT PRIMARY KEY AUTO_INCREMENT,
	portfelj_id INT NOT NULL,
	imovina_id INT NOT NULL,
	kolicina DECIMAL(38,18) UNSIGNED NOT NULL,
	UNIQUE (portfelj_id, imovina_id),
	FOREIGN KEY (portfelj_id) REFERENCES portfelj (id) ON DELETE CASCADE,
	FOREIGN KEY (imovina_id) REFERENCES imovina (id) ON DELETE RESTRICT
);

CREATE TABLE povijesna_cijena_imovine(
	id INT PRIMARY KEY AUTO_INCREMENT,
	imovina_id INT NOT NULL,
	cijena DECIMAL(38,18) UNSIGNED NOT NULL,
	datum DATETIME NOT NULL,
	FOREIGN KEY (imovina_id) REFERENCES imovina (id) ON DELETE CASCADE
);

CREATE TABLE dividenda(
	id INT PRIMARY KEY AUTO_INCREMENT,
	imovina_id INT NOT NULL,
	datum DATETIME NOT NULL,
	iznos DECIMAL(38,18) UNSIGNED NOT NULL,
	FOREIGN KEY (imovina_id) REFERENCES imovina(id) ON DELETE CASCADE
);


