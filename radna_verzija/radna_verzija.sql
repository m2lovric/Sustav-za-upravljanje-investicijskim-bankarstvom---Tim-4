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
	CHECK (broj_racuna REGEXP '^HR[0-9]{19}$')
);

CREATE TABLE portfelj(
	id INT PRIMARY KEY AUTO_INCREMENT,
	investicijski_racun_id INT NOT NULL,
	ime VARCHAR(100) NOT NULL,
	datum_otvaranja DATETIME NOT NULL,
	FOREIGN KEY (investicijski_racun_id) REFERENCES investicijski_racun (id) ON DELETE CASCADE,
	UNIQUE (investicijski_racun_id, ime)
);

CREATE TABLE uplata_isplata(
	id INT PRIMARY KEY AUTO_INCREMENT,
	investicijski_racun_id INT NOT NULL,
	broj_transakcije VARCHAR(45) NOT NULL UNIQUE,
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
	broj_naloga VARCHAR(45) NOT NULL UNIQUE,
	kolicina DECIMAL(38,18) UNSIGNED NOT NULL,
	cijena DECIMAL(38,18) UNSIGNED NOT NULL,
	naknada DECIMAL(38,18) UNSIGNED,
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



-- ==========================================
-- 1. TIPOVI IMOVINE
-- ==========================================
INSERT INTO tip_imovine (id, tip) VALUES (1, 'Dionica');
INSERT INTO tip_imovine (id, tip) VALUES (2, 'Obveznica');
INSERT INTO tip_imovine (id, tip) VALUES (3, 'ETF');
INSERT INTO tip_imovine (id, tip) VALUES (4, 'Kriptovaluta');
INSERT INTO tip_imovine (id, tip) VALUES (5, 'Investicijski fond');

-- ==========================================
-- 2. TIPOVI TRANSAKCIJE
-- ==========================================
INSERT INTO tip_transakcije (id, tip) VALUES (1, 'Kupnja');
INSERT INTO tip_transakcije (id, tip) VALUES (2, 'Prodaja');

-- ==========================================
-- 3. BANKE
-- ==========================================
INSERT INTO banka (id, ime) VALUES (1, 'Zagrebačka banka');
INSERT INTO banka (id, ime) VALUES (2, 'Privredna banka Zagreb');
INSERT INTO banka (id, ime) VALUES (3, 'Erste & Steiermärkische Bank');
INSERT INTO banka (id, ime) VALUES (4, 'OTP Banka');
INSERT INTO banka (id, ime) VALUES (5, 'Hrvatska poštanska banka');
INSERT INTO banka (id, ime) VALUES (6, 'Raiffeisenbank Austria');
INSERT INTO banka (id, ime) VALUES (7, 'Addiko Bank');

-- ==========================================
-- 4. KLIJENTI (31 unos)
-- ==========================================
INSERT INTO klijent (id, ime, prezime, OIB, email, telefon, ulica_i_kucni_broj, postanski_broj) VALUES 
(1, 'Ivan', 'Horvat', '10001234567', 'ivan.horvat1@example.com', '+385911007654', 'Ulica Ivana 1', '21000'),
(2, 'Ana', 'Kovačević', '10002469134', 'ana.kovacevic2@example.com', '+385911015308', 'Ulica Ane 2', '10000'),
(3, 'Marko', 'Babić', '10003703701', 'marko.babic3@example.com', '+385911022962', 'Ulica Marka 3', '20000'),
(4, 'Marija', 'Marić', '10004938268', 'marija.maric4@example.com', '+385911030616', 'Ulica Marije 4', '51000'),
(5, 'Josip', 'Jurić', '10006172835', 'josip.juric5@example.com', '+385911038270', 'Ulica Josipa 5', '51000'),
(6, 'Ivana', 'Novak', '10007407402', 'ivana.novak6@example.com', '+385911045924', 'Ulica Ivane 6', '31000'),
(7, 'Stjepan', 'Kovačić', '10008641969', 'stjepan.kovacic7@example.com', '+385911053578', 'Ulica Stjepana 7', '21000'),
(8, 'Katarina', 'Knežević', '10009876536', 'katarina.knezevic8@example.com', '+385911061232', 'Ulica Katarine 8', '23000'),
(9, 'Tomislav', 'Vuković', '10011111103', 'tomislav.vukovic9@example.com', '+385911068886', 'Ulica Tomislava 9', '21000'),
(10, 'Petra', 'Marković', '10012345670', 'petra.markovic10@example.com', '+385911076540', 'Ulica Petre 10', '44000'),
(11, 'Luka', 'Matić', '10013580237', 'luka.matic11@example.com', '+385911084194', 'Ulica Luke 11', '35000'),
(12, 'Elena', 'Petrović', '10014814804', 'elena.petrovic12@example.com', '+385911091848', 'Ulica Elene 12', '10000'),
(13, 'Mateo', 'Tomić', '10016049371', 'mateo.tomic13@example.com', '+385911099502', 'Ulica Matea 13', '10000'),
(14, 'Lucija', 'Kovačić', '10017283938', 'lucija.kovacic14@example.com', '+385911107156', 'Ulica Lucije 14', '21000'),
(15, 'Filip', 'Lončar', '10018518505', 'filip.loncar15@example.com', '+385911114810', 'Ulica Filipa 15', '51000'),
(16, 'Marta', 'Filipović', '10019753072', 'marta.filipovic16@example.com', '+385911122464', 'Ulica Marte 16', '51000'),
(17, 'Antun', 'Posavec', '10020987639', 'antun.posavec17@example.com', '+385911130118', 'Ulica Antuna 17', '23000'),
(18, 'Sara', 'Radić', '10022222206', 'sara.radic18@example.com', '+385911137772', 'Ulica Sare 18', '44000'),
(19, 'David', 'Šimić', '10023456773', 'david.simic19@example.com', '+385911145426', 'Ulica Davida 19', '10000'),
(20, 'Lana', 'Vidović', '10024691340', 'lana.vidovic20@example.com', '+385911153080', 'Ulica Lane 20', '23000'),
(21, 'Nikola', 'Jukić', '10025925907', 'nikola.jukic21@example.com', '+385911160734', 'Ulica Nikole 21', '51000'),
(22, 'Karla', 'Blažević', '10027160474', 'karla.blazevic22@example.com', '+385911168388', 'Ulica Karle 22', '23000'),
(23, 'Marin', 'Grgić', '10028395041', 'marin.grgic23@example.com', '+385911176042', 'Ulica Marina 23', '35000'),
(24, 'Valerija', 'Pavlović', '10029629608', 'valerija.pavlovic24@example.com', '+385911183696', 'Ulica Valerije 24', '51000'),
(25, 'Borisa', 'Kolić', '10030864175', 'borisa.kolic25@example.com', '+385911191350', 'Ulica Borise 25', '22000'),
(26, 'Tea', 'Perić', '10032098742', 'tea.peric26@example.com', '+385911199004', 'Ulica Tee 26', '44000'),
(27, 'Kristijan', 'Pavić', '10033333309', 'kristijan.pavic27@example.com', '+385912066580', 'Ulica Kristijana 27', '20000'),
(28, 'Monika', 'Šarić', '10034567876', 'monika.saric28@example.com', '+385911214312', 'Ulica Monike 28', '10000'),
(29, 'Damir', 'Vidović', '10035802443', 'damir.vidovic29@example.com', '+385911221966', 'Ulica Damira 29', '31000'),
(30, 'Sanja', 'Lovrić', '10037037010', 'sanja.lovric30@example.com', '+385911229620', 'Ulica Sanje 30', '35000'),
(31, 'Robert', 'Zeba', '10038271577', 'robert.zeba31@example.com', '+385911237274', 'Ulica Roberta 31', '42000');

-- ==========================================
-- 5. INVESTICIJSKI RAČUNI (31 unos, 21 znamenka za broj računa)
-- ==========================================
INSERT INTO investicijski_racun (id, klijent_id, banka_id, broj_racuna, stanje, datum_otvaranja) VALUES 
(1, 1, 2, '300000000000987654321', 45291.34, '2020-01-16'),
(2, 2, 3, '300000000001975308642', 36220.50, '2020-01-31'),
(3, 3, 4, '300000000002962962963', 115706.65, '2020-02-15'),
(4, 4, 5, '300000000003950617284', 19820.49, '2020-03-01'),
(5, 5, 6, '300000000004938271605', 60089.46, '2020-03-16'),
(6, 6, 7, '300000000005925925926', 57052.01, '2020-03-31'),
(7, 7, 1, '300000000006913580247', 54873.58, '2020-04-15'),
(8, 8, 2, '300000000007901234568', 43355.53, '2020-04-30'),
(9, 9, 3, '300000000008888888889', 11300.31, '2020-05-15'),
(10, 10, 4, '300000000009876543210', 71616.61, '2020-05-30'),
(11, 11, 5, '300000000010864197531', 23099.79, '2020-06-14'),
(12, 12, 6, '300000000011851851852', 138732.83, '2020-06-29'),
(13, 13, 7, '300000000012839506173', 16426.03, '2020-07-14'),
(14, 14, 1, '300000000013827160494', 47510.85, '2020-07-29'),
(15, 15, 2, '300000000014814814815', 96152.77, '2020-08-13'),
(16, 16, 3, '300000000015802469136', 133390.50, '2020-08-28'),
(17, 17, 4, '300000000016790123457', 57437.08, '2020-09-12'),
(18, 18, 5, '300000000017777777778', 32881.85, '2020-09-27'),
(19, 19, 6, '300000000018765432099', 15085.50, '2020-10-12'),
(20, 20, 7, '300000000019753086420', 100883.18, '2020-10-27'),
(21, 21, 1, '300000000020740740741', 117094.91, '2020-11-11'),
(22, 22, 2, '300000000021728395062', 147857.12, '2020-11-26'),
(23, 23, 3, '300000000022716049383', 129021.07, '2020-12-11'),
(24, 24, 4, '300000000023703703704', 130640.13, '2020-12-26'),
(25, 25, 5, '300000000024691358025', 60118.30, '2021-01-10'),
(26, 26, 6, '300000000025679012346', 70744.49, '2021-01-25'),
(27, 27, 7, '300000000026666666667', 125946.01, '2021-02-09'),
(28, 28, 1, '300000000027654320988', 28584.84, '2021-02-24'),
(29, 29, 2, '300000000028641975309', 56514.25, '2021-03-11'),
(30, 30, 3, '300000000029629629630', 102175.40, '2021-03-26'),
(31, 31, 4, '300000000030617283951', 106763.95, '2021-04-10');

-- ==========================================
-- 6. PORTFELJI (31 unos)
-- ==========================================
INSERT INTO portfelj (id, investicijski_racun_id, ime, datum_otvaranja) VALUES 
(1, 1, 'Glavni Portfelj 1', '2020-01-17 00:00:00'),
(2, 2, 'Glavni Portfelj 2', '2020-02-01 00:00:00'),
(3, 3, 'Glavni Portfelj 3', '2020-02-16 00:00:00'),
(4, 4, 'Glavni Portfelj 4', '2020-03-02 00:00:00'),
(5, 5, 'Glavni Portfelj 5', '2020-03-17 00:00:00'),
(6, 6, 'Glavni Portfelj 6', '2020-04-01 00:00:00'),
(7, 7, 'Glavni Portfelj 7', '2020-04-16 00:00:00'),
(8, 8, 'Glavni Portfelj 8', '2020-05-01 00:00:00'),
(9, 9, 'Glavni Portfelj 9', '2020-05-16 00:00:00'),
(10, 10, 'Glavni Portfelj 10', '2020-05-31 00:00:00'),
(11, 11, 'Glavni Portfelj 11', '2020-06-15 00:00:00'),
(12, 12, 'Glavni Portfelj 12', '2020-06-30 00:00:00'),
(13, 13, 'Glavni Portfelj 13', '2020-07-15 00:00:00'),
(14, 14, 'Glavni Portfelj 14', '2020-07-30 00:00:00'),
(15, 15, 'Glavni Portfelj 15', '2020-08-14 00:00:00'),
(16, 16, 'Glavni Portfelj 16', '2020-08-29 00:00:00'),
(17, 17, 'Glavni Portfelj 17', '2020-09-13 00:00:00'),
(18, 18, 'Glavni Portfelj 18', '2020-09-28 00:00:00'),
(19, 19, 'Glavni Portfelj 19', '2020-10-13 00:00:00'),
(20, 20, 'Glavni Portfelj 20', '2020-10-28 00:00:00'),
(21, 21, 'Glavni Portfelj 21', '2020-11-12 00:00:00'),
(22, 22, 'Glavni Portfelj 22', '2020-11-27 00:00:00'),
(23, 23, 'Glavni Portfelj 23', '2020-12-12 00:00:00'),
(24, 24, 'Glavni Portfelj 24', '2020-12-27 00:00:00'),
(25, 25, 'Glavni Portfelj 25', '2021-01-11 00:00:00'),
(26, 26, 'Glavni Portfelj 26', '2021-01-26 00:00:00'),
(27, 27, 'Glavni Portfelj 27', '2021-02-10 00:00:00'),
(28, 28, 'Glavni Portfelj 28', '2021-02-25 00:00:00'),
(29, 29, 'Glavni Portfelj 29', '2021-03-12 00:00:00'),
(30, 30, 'Glavni Portfelj 30', '2021-03-27 00:00:00'),
(31, 31, 'Glavni Portfelj 31', '2021-04-11 00:00:00');

-- ==========================================
-- 7. UPLATE / ISPLATE (Izuzeto iz pravila od 30+)
-- ==========================================
INSERT INTO uplata_isplata (id, investicijski_racun_id, broj_transakcije, iznos, datum, vrsta_prometa) VALUES 
(1, 1, 'TXN-PAY-10001', 13987.41, '2021-01-31 00:00:00', 'uplata'),
(2, 2, 'TXN-PAY-10002', 2356.65, '2021-03-02 00:00:00', 'isplata'),
(3, 3, 'TXN-PAY-10003', 13064.59, '2021-04-01 00:00:00', 'uplata'),
(4, 4, 'TXN-PAY-10004', 11148.66, '2021-05-01 00:00:00', 'isplata'),
(5, 5, 'TXN-PAY-10005', 5651.41, '2021-05-31 00:00:00', 'uplata');

-- ==========================================
-- 8. IMOVINA (31 unos)
-- ==========================================
INSERT INTO imovina (id, ime, tip_imovine_id, trenutna_cijena) VALUES 
(1, 'Apple Inc.', 1, 175.5),
(2, 'Microsoft Corp.', 1, 420.2),
(3, 'Alphabet Inc.', 1, 150.3),
(4, 'Amazon.com Inc.', 1, 180.1),
(5, 'NVIDIA Corp.', 1, 850.0),
(6, 'Tesla Inc.', 1, 170.45),
(7, 'Meta Platforms', 1, 490.15),
(8, 'Eli Lilly & Co', 1, 760.3),
(9, 'Berkshire Hathaway', 1, 610000.0),
(10, 'JPMorgan Chase', 1, 195.4),
(11, 'Hrvatski Telekom', 1, 30.2),
(12, 'Podravka', 1, 160.0),
(13, 'Atlantic Grupa', 1, 55.5),
(14, 'Končar', 1, 250.0),
(15, 'Valamar Riviera', 1, 5.2),
(16, 'US 10Y Bond', 2, 98.5),
(17, 'German 10Y Bund', 2, 101.2),
(18, 'Croatia 2030 Bond', 2, 100.0),
(19, 'S&P 500 ETF', 3, 510.4),
(20, 'Nasdaq 100 ETF', 3, 440.1),
(21, 'MSCI World ETF', 3, 85.3),
(22, 'Bitcoin', 4, 65000.0),
(23, 'Ethereum', 4, 3400.0),
(24, 'Solana', 4, 140.2),
(25, 'Cardano', 4, 0.45),
(26, 'Ripple XRP', 4, 0.5),
(27, 'ZB Aktiv Fond', 5, 120.4),
(28, 'PBZ Global Fond', 5, 210.6),
(29, 'Erste Balance Fond', 5, 145.1),
(30, 'OTP indeksni Fond', 5, 95.8),
(31, 'Gold Trust ETF', 3, 215.3);

-- ==========================================
-- 9. TRANSAKCIJE (34 unosa)
-- ==========================================
INSERT INTO transakcija (id, investicijski_racun_id, imovina_id, tip_transakcije_id, broj_naloga, kolicina, cijena, naknada, datum) VALUES 
(1, 2, 2, 1, 'ORD-20240001', 23.6508, 420.2, 9.9381, '2022-01-11 00:00:00'),
(2, 3, 3, 1, 'ORD-20240002', 14.2274, 150.3, 2.1384, '2022-01-21 00:00:00'),
(3, 4, 4, 1, 'ORD-20240003', 46.3442, 180.1, 8.3466, '2022-01-31 00:00:00'),
(4, 5, 5, 2, 'ORD-20240004', 34.7199, 850.0, 29.5119, '2022-02-10 00:00:00'),
(5, 6, 6, 1, 'ORD-20240005', 11.7611, 170.45, 2.0047, '2022-02-20 00:00:00'),
(6, 7, 7, 1, 'ORD-20240006', 16.8899, 490.15, 8.2786, '2022-03-02 00:00:00'),
(7, 8, 8, 1, 'ORD-20240007', 38.6474, 760.3, 29.3836, '2022-03-12 00:00:00'),
(8, 9, 9, 2, 'ORD-20240008', 3.741, 610000.0, 2282.01, '2022-03-22 00:00:00'),
(9, 10, 10, 1, 'ORD-20240009', 41.2683, 195.4, 8.0638, '2022-04-01 00:00:00'),
(10, 11, 11, 1, 'ORD-20240010', 40.4472, 30.2, 1.2215, '2022-04-11 00:00:00'),
(11, 12, 12, 1, 'ORD-20240011', 20.6571, 160.0, 3.3051, '2022-04-21 00:00:00'),
(12, 13, 13, 2, 'ORD-20240012', 4.2432, 55.5, 0.2355, '2022-05-01 00:00:00'),
(13, 14, 14, 1, 'ORD-20240013', 45.7437, 250.0, 11.4359, '2022-05-11 00:00:00'),
(14, 15, 15, 1, 'ORD-20240014', 28.7918, 5.2, 0.1497, '2022-05-21 00:00:00'),
(15, 16, 16, 1, 'ORD-20240015', 36.1778, 98.5, 3.5635, '2022-05-31 00:00:00'),
(16, 17, 17, 2, 'ORD-20240016', 11.4187, 101.2, 1.1556, '2022-06-10 00:00:00'),
(17, 18, 18, 1, 'ORD-20240017', 25.4623, 100.0, 2.5462, '2022-06-20 00:00:00'),
(18, 19, 19, 1, 'ORD-20240018', 21.0567, 510.4, 10.7473, '2022-06-30 00:00:00'),
(19, 20, 20, 1, 'ORD-20240019', 37.0792, 440.1, 16.3186, '2022-07-10 00:00:00'),
(20, 21, 21, 2, 'ORD-20240020', 21.7247, 85.3, 1.8531, '2022-07-20 00:00:00'),
(21, 22, 22, 1, 'ORD-20240021', 49.3364, 65000.0, 3206.866, '2022-07-30 00:00:00'),
(22, 23, 23, 1, 'ORD-20240022', 17.5146, 3400.0, 59.5496, '2022-08-09 00:00:00'),
(23, 24, 24, 1, 'ORD-20240023', 44.9745, 140.2, 6.3054, '2022-08-19 00:00:00'),
(24, 25, 25, 2, 'ORD-20240024', 44.0204, 0.45, 0.0198, '2022-08-29 00:00:00'),
(25, 26, 26, 1, 'ORD-20240025', 18.0645, 0.5, 0.009, '2022-09-08 00:00:00'),
(26, 27, 27, 1, 'ORD-20240026', 42.4839, 120.4, 5.1151, '2022-09-18 00:00:00'),
(27, 28, 28, 1, 'ORD-20240027', 37.7667, 210.6, 7.9537, '2022-09-28 00:00:00'),
(28, 29, 29, 2, 'ORD-20240028', 15.6983, 145.1, 2.2778, '2022-10-08 00:00:00'),
(29, 30, 30, 1, 'ORD-20240029', 11.4587, 95.8, 1.0977, '2022-10-18 00:00:00'),
(30, 31, 31, 1, 'ORD-20240030', 21.0594, 215.3, 4.5341, '2022-10-28 00:00:00'),
(31, 1, 1, 1, 'ORD-20240031', 5.6200, 175.5, 0.9863, '2022-11-07 00:00:00'),
(32, 2, 2, 1, 'ORD-20240032', 8.9100, 420.2, 3.7440, '2022-11-17 00:00:00'),
(33, 3, 3, 1, 'ORD-20240033', 12.4500, 150.3, 1.8712, '2022-11-27 00:00:00'),
(34, 4, 4, 2, 'ORD-20240034', 2.3000, 180.1, 0.4142, '2022-12-07 00:00:00');

-- ==========================================
-- 10. PORTFELJ IMOVINA (62 unosa - po 2 za svaki portfelj)
-- ==========================================
INSERT INTO portfelj_imovina (id, portfelj_id, imovina_id, kolicina) VALUES 
(1, 1, 2, 40.825), (2, 1, 3, 26.6094), (3, 2, 3, 85.5002), (4, 2, 4, 91.503), 
(5, 3, 4, 73.1979), (6, 3, 5, 25.1092), (7, 4, 5, 48.069), (8, 4, 6, 62.6953), 
(9, 5, 6, 73.0975), (10, 5, 7, 72.8252), (11, 6, 7, 51.1098), (12, 6, 8, 30.6481), 
(13, 7, 8, 93.304), (14, 7, 9, 78.4728), (15, 8, 9, 39.5312), (16, 8, 10, 68.4907), 
(17, 9, 10, 71.494), (18, 9, 11, 88.5997), (19, 10, 11, 62.5933), (20, 10, 12, 70.3235), 
(21, 11, 12, 28.5372), (22, 11, 13, 47.9621), (23, 12, 13, 12.3916), (24, 12, 14, 52.3781), 
(25, 13, 14, 99.4206), (26, 13, 15, 41.5284), (27, 14, 15, 69.4184), (28, 14, 16, 92.5181), 
(29, 15, 16, 60.1009), (30, 15, 17, 36.6577), (31, 16, 17, 71.4339), (32, 16, 18, 26.1666), 
(33, 17, 18, 86.877), (34, 17, 19, 93.3514), (35, 18, 19, 62.1558), (36, 18, 20, 39.5668), 
(37, 19, 20, 80.5285), (38, 19, 21, 48.0163), (39, 20, 21, 33.6599), (40, 20, 22, 46.1662), 
(41, 21, 22, 88.197), (42, 21, 23, 85.034), (43, 22, 23, 49.3361), (44, 22, 24, 9.4716), 
(45, 23, 24, 69.2139), (46, 23, 25, 41.1396), (47, 24, 25, 11.233), (48, 24, 26, 85.5898), 
(49, 25, 26, 21.0543), (50, 25, 27, 43.1492), (51, 26, 27, 28.5312), (52, 26, 28, 8.5288), 
(53, 27, 28, 61.3414), (54, 27, 29, 67.5414), (55, 28, 29, 44.8986), (56, 28, 30, 25.438), 
(57, 29, 30, 89.2844), (58, 29, 31, 25.1005), (59, 30, 31, 92.2981), (60, 30, 1, 93.1895), 
(61, 31, 1, 62.1158), (62, 31, 2, 74.5218);

-- ==========================================
-- 11. POVIJESNE CIJENE (62 unosa - po 2 povijesne cijene za svaku imovinu)
-- ==========================================
INSERT INTO povijesna_cijena_imovine (id, imovina_id, cijena, datum) VALUES 
(1, 1, 172.54, '2024-04-01 00:00:00'), (2, 1, 165.41, '2024-03-02 00:00:00'),
(3, 2, 442.15, '2024-04-01 00:00:00'), (4, 2, 395.22, '2024-03-02 00:00:00'),
(5, 3, 142.11, '2024-04-01 00:00:00'), (6, 3, 155.61, '2024-03-02 00:00:00'),
(7, 4, 185.30, '2024-04-01 00:00:00'), (8, 4, 168.90, '2024-03-02 00:00:00'),
(9, 5, 810.50, '2024-04-01 00:00:00'), (10, 5, 780.00, '2024-03-02 00:00:00'),
(11, 6, 162.30, '2024-04-01 00:00:00'), (12, 6, 179.40, '2024-03-02 00:00:00'),
(13, 7, 510.20, '2024-04-01 00:00:00'), (14, 7, 460.11, '2024-03-02 00:00:00'),
(15, 8, 790.30, '2024-04-01 00:00:00'), (16, 8, 730.20, '2024-03-02 00:00:00'),
(17, 9, 595000.0, '2024-04-01 00:00:00'), (18, 9, 620000.0, '2024-03-02 00:00:00'),
(19, 10, 185.40, '2024-04-01 00:00:00'), (20, 10, 199.10, '2024-03-02 00:00:00'),
(21, 11, 29.50, '2024-04-01 00:00:00'), (22, 11, 28.90, '2024-03-02 00:00:00'),
(23, 12, 155.00, '2024-04-01 00:00:00'), (24, 12, 162.50, '2024-03-02 00:00:00'),
(25, 13, 56.20, '2024-04-01 00:00:00'), (26, 13, 53.10, '2024-03-02 00:00:00'),
(27, 14, 240.00, '2024-04-01 00:00:00'), (28, 14, 255.00, '2024-03-02 00:00:00'),
(29, 15, 5.10, '2024-04-01 00:00:00'), (30, 15, 5.35, '2024-03-02 00:00:00'),
(31, 16, 97.20, '2024-04-01 00:00:00'), (32, 16, 99.10, '2024-03-02 00:00:00'),
(33, 17, 102.10, '2024-04-01 00:00:00'), (34, 17, 100.50, '2024-03-02 00:00:00'),
(35, 18, 99.50, '2024-04-01 00:00:00'), (36, 18, 101.20, '2024-03-02 00:00:00'),
(37, 19, 498.50, '2024-04-01 00:00:00'), (38, 19, 520.10, '2024-03-02 00:00:00'),
(39, 20, 425.30, '2024-04-01 00:00:00'), (40, 20, 448.20, '2024-03-02 00:00:00'),
(41, 21, 83.10, '2024-04-01 00:00:00'), (42, 21, 87.40, '2024-03-02 00:00:00'),
(43, 22, 62000.0, '2024-04-01 00:00:00'), (44, 22, 67500.0, '2024-03-02 00:00:00'),
(45, 23, 3250.0, '2024-04-01 00:00:00'), (46, 23, 3550.0, '2024-03-02 00:00:00'),
(47, 24, 131.50, '2024-04-01 00:00:00'), (48, 24, 146.20, '2024-03-02 00:00:00'),
(49, 25, 0.42, '2024-04-01 00:00:00'), (50, 25, 0.48, '2024-03-02 00:00:00'),
(51, 26, 0.49, '2024-04-01 00:00:00'), (52, 26, 0.52, '2024-03-02 00:00:00'),
(53, 27, 118.20, '2024-04-01 00:00:00'), (54, 27, 122.40, '2024-03-02 00:00:00'),
(55, 28, 205.10, '2024-04-01 00:00:00'), (56, 28, 215.30, '2024-03-02 00:00:00'),
(57, 29, 141.20, '2024-04-01 00:00:00'), (58, 29, 149.00, '2024-03-02 00:00:00'),
(59, 30, 93.40, '2024-04-01 00:00:00'), (60, 30, 97.20, '2024-03-02 00:00:00'),
(61, 31, 211.50, '2024-04-01 00:00:00'), (62, 31, 219.00, '2024-03-02 00:00:00');

-- ==========================================
-- 12. DIVIDENDE (32 unosa - po 2 isplate za dioničku/ETF imovinu)
-- ==========================================
INSERT INTO dividenda (id, imovina_id, datum, iznos) VALUES 
(1, 1, '2023-11-28 00:00:00', 2.3411), (2, 1, '2024-05-26 00:00:00', 3.1259),
(3, 2, '2023-11-28 00:00:00', 4.1105), (4, 2, '2024-05-26 00:00:00', 1.1569),
(5, 3, '2023-11-28 00:00:00', 0.5481), (6, 3, '2024-05-26 00:00:00', 4.3142),
(7, 4, '2023-11-28 00:00:00', 4.4121), (8, 4, '2024-05-26 00:00:00', 1.8841),
(9, 5, '2023-11-28 00:00:00', 2.1554), (10, 5, '2024-05-26 00:00:00', 3.4912),
(11, 6, '2023-11-28 00:00:00', 4.5126), (12, 6, '2024-05-26 00:00:00', 1.1154),
(13, 7, '2023-11-28 00:00:00', 3.5412), (14, 7, '2024-05-26 00:00:00', 4.1956),
(15, 8, '2023-11-28 00:00:00', 2.8711), (16, 8, '2024-05-26 00:00:00', 3.1098),
(17, 9, '2023-11-28 00:00:00', 3.1147), (18, 9, '2024-05-26 00:00:00', 2.4116),
(19, 10, '2023-11-28 00:00:00', 1.2541), (20, 10, '2024-05-26 00:00:00', 1.9953),
(21, 11, '2023-11-28 00:00:00', 0.8841), (22, 11, '2024-05-26 00:00:00', 1.4312),
(23, 12, '2023-11-28 00:00:00', 4.1026), (24, 12, '2024-05-26 00:00:00', 2.5119),
(25, 13, '2023-11-28 00:00:00', 3.5129), (26, 13, '2024-05-26 00:00:00', 1.8841),
(27, 14, '2023-11-28 00:00:00', 4.3129), (28, 14, '2024-05-26 00:00:00', 0.9952),
(29, 15, '2023-11-28 00:00:00', 0.6514), (30, 15, '2024-05-26 00:00:00', 1.4118),
(31, 19, '2023-11-28 00:00:00', 3.1145), (32, 19, '2024-05-26 00:00:00', 4.8872);