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


-- =========================================================================
-- 1. POPULATING LOOKUP TABLES (tip_imovine, tip_transakcije, banka)
-- =========================================================================

INSERT INTO tip_imovine (id, tip) VALUES 
(1, 'Dionice'), 
(2, 'Obveznice'), 
(3, 'ETF'), 
(4, 'Kriptovalute');

INSERT INTO tip_transakcije (id, tip) VALUES 
(1, 'Kupnja'), 
(2, 'Prodaja');

INSERT INTO banka (id, ime) VALUES 
(1, 'Zagrebačka banka d.d.'),
(2, 'Privredna banka Zagreb d.d.'),
(3, 'Erste & Steiermärkische Bank d.d.'),
(4, 'OTP Banka d.d.'),
(5, 'Hrvatska poštanska banka d.d.');


-- =========================================================================
-- 2. POPULATING KLIJENT (30 Realistic Croatian Entries)
-- =========================================================================

INSERT INTO klijent (id, ime, prezime, OIB, email, telefon, ulica_i_kucni_broj, postanski_broj) VALUES 
(1, 'Luka', 'Vuković', '74885019635', 'luka.vukovic44@email.hr', '+385911237722', 'Ilica 39', '52000'),
(2, 'Ema', 'Vidović', '10913708829', 'ema.vidovic30@email.hr', '+385916966080', 'Slavonska avenija 13', '22000'),
(3, 'Jakov', 'Filipović', '40388910613', 'jakov.filipovic23@email.hr', '+385912629915', 'Vukovarska ulica 113', '21000'),
(4, 'Elena', 'Horvat', '81068637692', 'elena.horvat49@email.hr', '+385913512977', 'Ulica grada Vukovara 3', '10000'),
(5, 'Borut', 'Blažević', '64371369399', 'borut.blazevic47@email.hr', '+385914912161', 'Ulica grada Vukovara 23', '31000'),
(6, 'Matea', 'Lovrić', '93352970278', 'matea.lovric53@email.hr', '+385912906279', 'Palmotićeva 129', '20000'),
(7, 'Petar', 'Jurić', '27467064684', 'petar.juric95@email.hr', '+385915384519', 'Ulica grada Vukovara 42', '10000'),
(8, 'Ana', 'Kovač', '13441756491', 'ana.kovac25@email.hr', '+385915692177', 'Vukovarska ulica 148', '51000'),
(9, 'Luka', 'Tomanić', '50036743664', 'luka.tomanic66@email.hr', '+385916770908', 'Savska cesta 128', '35000'),
(10, 'Lucija', 'Novak', '68399089011', 'lucija.novak43@email.hr', '+385913311669', 'Gundulićeva 66', '52000'),
(11, 'Tomislav', 'Lovrić', '64196916235', 'tomislav.lovric75@email.hr', '+385917383499', 'Slavonska avenija 43', '52000'),
(12, 'Ema', 'Brkić', '38250076036', 'ema.brkic24@email.hr', '+385913082453', 'Frankopanska 103', '31000'),
(13, 'Antun', 'Novak', '51934543331', 'antun.novak91@email.hr', '+385915524943', 'Frankopanska 69', '51000'),
(14, 'Nina', 'Kovačić', '61851879332', 'nina.kovacic70@email.hr', '+385919186510', 'Gundulićeva 4', '42000'),
(15, 'Antun', 'Pavlović', '47201899075', 'antun.pavlovic23@email.hr', '+385918575267', 'Slavonska avenija 72', '23000'),
(16, 'Nina', 'Tomanić', '28014414937', 'nina.tomanic50@email.hr', '+385915067959', 'Slavonska avenija 107', '35000'),
(17, 'Marko', 'Knežević', '64432911383', 'marko.knezevic91@email.hr', '+385916646421', 'Ilica 13', '23000'),
(18, 'Tea', 'Horvat', '82502545646', 'tea.horvat42@email.hr', '+385919749050', 'Frankopanska 136', '31000'),
(19, 'Marko', 'Kovačić', '82034511485', 'marko.kovacic87@email.hr', '+385918743643', 'Gundulićeva 73', '52000'),
(20, 'Martina', 'Filipović', '84605641687', 'martina.filipovic91@email.hr', '+385911804019', 'Vukovarska ulica 101', '22000'),
(21, 'Karlo', 'Babić', '49269691217', 'karlo.babic12@email.hr', '+385915784186', 'Maksimirska cesta 100', '21000'),
(22, 'Tea', 'Lovrić', '75801055853', 'tea.lovric25@email.hr', '+385918235903', 'Palmotićeva 6', '23000'),
(23, 'Luka', 'Vuković', '98819836947', 'luka.vukovic51@email.hr', '+385915502976', 'Ulica grada Vukovara 132', '23000'),
(24, 'Tea', 'Sarić', '90167143977', 'tea.saric32@email.hr', '+385918070641', 'Slavonska avenija 114', '31000'),
(25, 'Matej', 'Marić', '87083903592', 'matej.maric66@email.hr', '+385918394768', 'Vukovarska ulica 21', '31000'),
(26, 'Ivan', 'Stanić', '31289456721', 'ivan.stanic88@email.hr', '+385915553421', 'Maksimirska 45', '10000'),
(27, 'Petra', 'Brkić', '90124356782', 'petra.brkic19@email.hr', '+385917764321', 'Zvonimirova 12', '21000'),
(28, 'David', 'Novak', '55432198765', 'david.novak99@email.hr', '+385913239876', 'Ilica 210', '10000'),
(29, 'Sara', 'Kovač', '12983476501', 'sara.kovac01@email.hr', '+385914432109', 'Savska cesta 14', '10000'),
(30, 'Marin', 'Jurić', '77654321098', 'marin.juric92@email.hr', '+385919988776', 'Gundulićeva 8', '21000');


-- =========================================================================
-- 3. POPULATING INVESTICIJSKI_RACUN (30 Entries, Unique 21-digit numbers)
-- =========================================================================

INSERT INTO investicijski_racun (id, klijent_id, banka_id, broj_racuna, stanje, datum_otvaranja) VALUES 
(1, 1, 3, '513812741902847156291', 124500.500000000000, '2021-04-12'),
(2, 2, 1, '830174920184716294012', 45200.000000000000, '2023-11-28'),
(3, 3, 5, '103948172639481726354', 8900.250000000000, '2020-02-15'),
(4, 4, 2, '948172635491827364501', 340000.000000000000, '2022-07-19'),
(5, 5, 2, '293847102938471029384', 15500.750000000000, '2024-01-10'),
(6, 6, 4, '482910394817263549102', '61200.000000000000', '2023-05-24'),
(7, 7, 1, '710293847102938471029', '1800.000000000000', '2021-09-02'),
(8, 8, 3, '394817263549102938471', '95400.100000000000', '2022-12-11'),
(9, 9, 5, '827364501928374650192', '12400.000000000000', '2020-06-30'),
(10, 10, 4, '192837465019283746501', '310500.000000000000', '2023-03-14'),
(11, 11, 1, '501928374650192837465', '4200.350000000000', '2024-02-27'),
(12, 12, 2, '650192837465019283746', '73900.000000000000', '2021-10-05'),
(13, 13, 3, '374650192837465019283', '168000.000000000000', '2022-01-20'),
(14, 14, 5, '928374650192837465019', '5500.000000000000', '2023-08-08'),
(15, 15, 4, '465019283746501928374', '23400.900000000000', '2020-11-12'),
(16, 16, 2, '837465019283746501928', '89100.000000000000', '2024-04-01'),
(17, 17, 1, '112233445566778899001', '1250.000000000000', '2022-05-18'),
(18, 18, 3, '223344556677889900112', '412000.000000000000', '2021-03-25'),
(19, 19, 4, '334455667788990011223', '6700.500000000000', '2023-07-09'),
(20, 20, 5, '445566778899001122334', '19200.000000000000', '2020-09-14'),
(21, 21, 1, '556677889900112233445', '105400.000000000000', '2022-10-31'),
(22, 22, 2, '667788990011223344556', '3100.000000000000', '2024-05-02'),
(23, 23, 3, '778899001122334455667', '78500.250000000000', '2021-06-15'),
(24, 24, 4, '889900112233445566778', '14200.000000000000', '2023-02-20'),
(25, 25, 5, '990011223344556677889', '290000.000000000000', '2020-04-05'),
(26, 26, 1, '123456789012345678901', '53000.000000000000', '2022-01-11'),
(27, 27, 2, '234567890123456789012', '8400.000000000000', '2023-06-18'),
(28, 28, 3, '345678901234567890123', '165000.000000000000', '2021-08-22'),
(29, 29, 4, '456789012345678901234', '22100.000000000000', '2024-02-14'),
(30, 30, 5, '567890123456789012345', '71000.000000000000', '2020-12-05');


-- =========================================================================
-- 4. POPULATING PORTFELJ (30 Entries matched to Investment Accounts)
-- =========================================================================

INSERT INTO portfelj (id, investicijski_racun_id, ime, datum_otvaranja) VALUES 
(1, 1, 'Glavni Portfelj', '2021-04-12 10:00:00'),
(2, 2, 'Dugoročni Rast', '2023-11-28 11:30:00'),
(3, 3, 'Konzervativni Portfelj', '2020-02-15 09:15:00'),
(4, 4, 'Crypto & Tech', '2022-07-19 14:00:00'),
(5, 5, 'Glavni Portfelj', '2024-01-10 16:45:00'),
(6, 6, 'Dugoročni Rast', '2023-05-24 10:20:00'),
(7, 7, 'Mirovinski Štedni', '2021-09-02 08:30:00'),
(8, 8, 'Glavni Portfelj', '2022-12-11 12:00:00'),
(9, 9, 'Konzervativni Portfelj', '2020-06-30 15:10:00'),
(10, 10, 'Crypto & Tech', '2023-03-14 11:00:00'),
(11, 11, 'Glavni Portfelj', '2024-02-27 09:40:00'),
(12, 12, 'Dugoročni Rast', '2021-10-05 14:15:00'),
(13, 13, 'Mirovinski Štedni', '2022-01-20 10:05:00'),
(14, 14, 'Konzervativni Portfelj', '2023-08-08 16:20:00'),
(15, 15, 'Crypto & Tech', '2020-11-12 13:50:00'),
(16, 16, 'Glavni Portfelj', '2024-04-01 11:11:00'),
(17, 17, 'Štedni za Djecu', '2022-05-18 09:00:00'),
(18, 18, 'Dugoročni Rast', '2021-03-25 10:30:00'),
(19, 19, 'Konzervativni Portfelj', '2023-07-09 14:40:00'),
(20, 20, 'Glavni Portfelj', '2020-09-14 15:25:00'),
(21, 21, 'Crypto & Tech', '2022-10-31 16:00:00'),
(22, 22, 'Mirovinski Štedni', '2024-05-02 11:45:00'),
(23, 23, 'Glavni Portfelj', '2021-06-15 10:50:00'),
(24, 24, 'Dugoročni Rast', '2023-02-20 09:10:00'),
(25, 25, 'Agresivni Rast', '2020-04-05 13:00:00'),
(26, 26, 'Glavni Portfelj', '2022-01-11 14:20:00'),
(27, 27, 'Defenzivni Portfelj', '2023-06-18 15:30:00'),
(28, 28, 'Z-Tech Portfelj', '2021-08-22 10:15:00'),
(29, 29, 'Dividendni Fokus', '2024-02-14 11:00:00'),
(30, 30, 'Glavni Portfelj', '2020-12-05 09:00:00');


-- =========================================================================
-- 5. POPULATING IMOVINA (30 Distinct Assets Spanning All Types)
-- =========================================================================

INSERT INTO imovina (id, ime, tip_imovine_id, trenutna_cijena) VALUES 
-- Dionice (ID 1)
(1, 'Hrvatski Telekom d.d. (HT)', 1, 32.500000000000),
(2, 'Podravka d.d. (PODR)', 1, 160.000000000000),
(3, 'Končar d.d. (KOEI)', 1, 250.000000000000),
(4, 'Adris Grupa d.d. (ADRS)', 1, 60.500000000000),
(5, 'Atlantic Grupa d.d. (ATGR)', 1, 55.000000000000),
(6, 'Valamar Riviera d.d. (RIVP)', 1, 5.200000000000),
(7, 'Zagrebačka banka d.d. (ZABA)', 1, 18.100000000000),
(8, 'Apple Inc. (AAPL)', 1, 175.300000000000),
(9, 'Microsoft Corp. (MSFT)', 1, 420.150000000000),
(10, 'NVIDIA Corp. (NVDA)', 1, 900.250000000000),
(11, 'Tesla Inc. (TSLA)', 1, 170.800000000000),
(12, 'Alphabet Inc. (GOOGL)', 1, 150.400000000000),
(13, 'Amazon.com Inc. (AMZN)', 1, 180.100000000000),
(14, 'Meta Platforms Inc. (META)', 1, 480.600000000000),
(15, 'Berkshire Hathaway (BRK.B)', 1, 405.000000000000),
-- Obveznice (ID 2)
(16, 'Obveznica RH 2028', 2, 102.500000000000),
(17, 'Obveznica RH 2032', 2, 98.200000000000),
(18, 'US 10-Year Treasury', 2, 95.400000000000),
(19, 'Corporate Bond Siemens', 2, 101.100000000000),
(20, 'Corporate Bond Allianz', 2, 103.750000000000),
-- ETF (ID 3)
(21, 'iShares Core S&P 500 ETF', 3, 510.300000000000),
(22, 'Vanguard Total Stock Market ETF', 3, 255.400000000000),
(23, 'iShares MSCI World ETF', 3, 85.900000000000),
(24, 'Invesco QQQ Trust', 3, 440.200000000000),
(25, 'Vanguard FTSE All-World ETF', 3, 112.100000000000),
-- Kriptovalute (ID 4)
(26, 'Bitcoin (BTC)', 4, 65200.000000000000),
(27, 'Ethereum (ETH)', 4, 3500.000000000000),
(28, 'Solana (SOL)', 4, 150.000000000000),
(29, 'Cardano (ADA)', 4, 0.500000000000),
(30, 'Ripple (XRP)', 4, 0.550000000000);


-- =========================================================================
-- 6. POPULATING PROCEDURAL TABLES (Sample operations & transactions)
-- =========================================================================

-- Uplate / Isplate (Deposits / Withdrawals)
INSERT INTO uplata_isplata (investicijski_racun_id, iznos, datum, vrsta_prometa) VALUES 
(1, 2500.000000000000, '2025-05-01 10:00:00', 'uplata'),
(3, 500.000000000000, '2025-05-02 11:15:00', 'uplata'),
(4, 12000.000000000000, '2025-05-03 14:30:00', 'isplata'),
(10, 45000.000000000000, '2025-05-04 09:00:00', 'uplata'),
(15, 1500.000000000000, '2025-05-05 16:20:00', 'isplata');

-- Transakcije (Trades execution logs)
INSERT INTO transakcija (investicijski_racun_id, imovina_id, tip_transakcije_id, kolicina, cijena, naknada, datum) VALUES 
(1, 1, 1, 50.000000000000, 32.500000000000, 8.125000000000, '2025-05-10 11:00:00'),
(1, 26, 1, 0.250000000000, 65200.000000000000, 81.500000000000, '2025-05-11 15:45:00'),
(4, 10, 1, 10.000000000000, 900.250000000000, 45.012500000000, '2025-05-12 10:30:00'),
(12, 21, 1, 15.000000000000, 510.300000000000, 38.272500000000, '2025-05-13 09:15:00'),
(2, 2, 2, 5.000000000000, 160.000000000000, 4.000000000000, '2025-05-14 16:00:00');

-- Portfelj Imovina (Current Assets Held inside Portfolios)
INSERT INTO portfelj_imovina (portfelj_id, imovina_id, kolicina) VALUES 
(1, 1, 120.000000000000),
(1, 2, 35.000000000000),
(1, 26, 0.450000000000),
(2, 8, 15.000000000000),
(2, 9, 8.000000000000),
(4, 26, 1.200000000000),
(4, 27, 4.500000000000),
(10, 10, 25.000000000000),
(21, 21, 50.000000000000);

-- Povijesna Cijena Imovine (Historical Price Records)
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES 
(1, 31.200000000000, '2025-04-01 16:00:00'),
(2, 155.000000000000, '2025-04-01 16:00:00'),
(26, 61200.000000000000, '2025-04-15 23:59:59'),
(27, 3200.000000000000, '2025-04-15 23:59:59'),
(8, 170.100000000000, '2025-04-30 16:00:00');

-- Dividende (Historical payouts for Dividend Stocks)
INSERT INTO dividenda (imovina_id, datum, iznos) VALUES 
(1, '2025-03-15 00:00:00', 1.200000000000),
(2, '2025-03-20 00:00:00', 4.500000000000),
(4, '2025-04-05 00:00:00', 2.100000000000);


-- =========================================================================
-- EXTENSION PACK: UPLATA_ISPLATA (25 Additional Cash Flows)
-- =========================================================================

INSERT INTO uplata_isplata (investicijski_racun_id, iznos, datum, vrsta_prometa) VALUES 
(10, 56486.102100000000, '2026-04-11 16:39:00', 'uplata'),
(16, 48890.306400000000, '2026-01-10 17:51:00', 'isplata'),
(2, 71248.661000000000, '2026-03-25 09:23:00', 'uplata'),
(7, 45806.021100000000, '2026-03-28 10:59:00', 'uplata'),
(28, 62587.169200000000, '2026-01-08 10:35:00', 'uplata'),
(19, 19974.435700000000, '2026-02-17 16:26:00', 'uplata'),
(20, 73941.175900000000, '2026-01-20 13:48:00', 'isplata'),
(20, 60837.344100000000, '2026-03-05 11:11:00', 'isplata'),
(16, 61662.490700000000, '2026-02-11 11:09:00', 'uplata'),
(4, 44634.274600000000, '2026-02-23 13:56:00', 'isplata'),
(15, 26953.355800000000, '2026-03-23 10:52:00', 'isplata'),
(7, 56545.548900000000, '2026-04-25 09:49:00', 'uplata'),
(27, 72137.467900000000, '2026-01-21 17:32:00', 'uplata'),
(11, 5227.384100000000, '2026-01-07 11:20:00', 'isplata'),
(10, 57630.019600000000, '2026-02-21 09:14:00', 'isplata'),
(20, 22467.492000000000, '2026-01-18 18:51:00', 'uplata'),
(8, 25869.096200000000, '2026-02-13 13:02:00', 'isplata'),
(23, 17511.691000000000, '2026-02-21 16:22:00', 'isplata'),
(9, 28547.918100000000, '2026-01-26 18:49:00', 'isplata'),
(2, 39167.638900000000, '2026-01-26 13:15:00', 'uplata'),
(14, 36950.510800000000, '2026-04-21 16:10:00', 'isplata'),
(29, 22594.621800000000, '2026-04-05 15:19:00', 'uplata'),
(15, 28733.795800000000, '2026-01-16 16:58:00', 'uplata'),
(25, 54127.042900000000, '2026-04-06 12:14:00', 'uplata'),
(21, 44289.372700000000, '2026-02-25 13:54:00', 'uplata');


-- =========================================================================
-- EXTENSION PACK: TRANSAKCIJA (30 Scale-Logical Asset Trades)
-- =========================================================================

INSERT INTO transakcija (investicijski_racun_id, imovina_id, tip_transakcije_id, kolicina, cijena, naknada, datum) VALUES 
(3, 5, 2, 131.122700000000, 53.297500000000, 17.471300000000, '2026-02-17 15:41:00'),
(9, 25, 2, 16.048700000000, 110.035200000000, 4.414800000000, '2026-01-06 12:31:00'),
(13, 13, 1, 102.217700000000, 176.280100000000, 45.047400000000, '2026-02-02 16:22:00'),
(27, 14, 1, 135.084400000000, 477.601800000000, 161.291400000000, '2026-02-28 09:18:00'),
(3, 17, 2, 45.420000000000, 96.543300000000, 10.962500000000, '2026-04-21 12:07:00'),
(8, 25, 1, 12.240300000000, 114.616200000000, 3.507300000000, '2026-05-24 15:35:00'),
(10, 22, 2, 20.760300000000, 246.209600000000, 12.778500000000, '2026-02-13 09:41:00'),
(30, 16, 1, 87.020000000000, 104.044500000000, 22.634900000000, '2026-01-18 12:49:00'),
(4, 26, 1, 0.348180000000, 65902.428600000000, 57.364800000000, '2026-05-21 15:36:00'),
(1, 15, 2, 58.098800000000, 387.189300000000, 56.238100000000, '2026-03-06 11:17:00'),
(3, 19, 2, 69.440000000000, 101.938900000000, 17.696600000000, '2026-04-01 14:36:00'),
(20, 7, 2, 113.401900000000, 18.916900000000, 5.363000000000, '2026-02-06 12:36:00'),
(27, 7, 2, 43.403000000000, 17.635500000000, 1.913600000000, '2026-01-12 10:47:00'),
(17, 30, 1, 2.439731000000, 0.543300000000, 0.003300000000, '2026-05-01 15:55:00'),
(10, 29, 2, 0.924505000000, 0.491100000000, 0.001100000000, '2026-02-06 11:08:00'),
(30, 1, 1, 14.273800000000, 33.582500000000, 1.198400000000, '2026-02-23 15:58:00'),
(28, 26, 1, 0.840474000000, 62195.658100000000, 130.684600000000, '2026-02-20 12:56:00'),
(11, 12, 1, 18.946700000000, 153.421100000000, 7.267100000000, '2026-05-27 11:52:00'),
(1, 2, 1, 9.626600000000, 158.011500000000, 3.802800000000, '2026-05-18 09:21:00'),
(25, 27, 1, 0.199581000000, 3378.518300000000, 1.685700000000, '2026-03-13 12:45:00'),
(27, 23, 2, 18.558400000000, 85.181500000000, 3.952100000000, '2026-01-21 16:02:00'),
(23, 28, 2, 2.392928000000, 152.228500000000, 0.910700000000, '2026-01-06 10:03:00'),
(30, 29, 2, 0.571994000000, 0.479100000000, 0.000700000000, '2026-05-26 10:06:00'),
(6, 28, 2, 1.229485000000, 151.370400000000, 0.465300000000, '2026-02-12 15:48:00'),
(22, 9, 1, 113.122600000000, 402.500400000000, 113.829700000000, '2026-04-24 09:44:00'),
(2, 20, 2, 11.250000000000, 107.264400000000, 3.016800000000, '2026-01-01 10:25:00'),
(17, 30, 1, 2.258231000000, 0.568300000000, 0.003200000000, '2026-01-25 11:52:00'),
(29, 20, 1, 28.060000000000, 102.141800000000, 7.165200000000, '2026-02-23 14:33:00'),
(1, 4, 2, 65.254100000000, 61.380800000000, 10.013400000000, '2026-03-01 10:04:00'),
(17, 14, 2, 57.916900000000, 458.258800000000, 66.352300000000, '2026-02-26 11:14:00');


-- =========================================================================
-- EXTENSION PACK: POVIJESNA_CIJENA_IMOVINE (35 Chronological Price Records)
-- =========================================================================

-- Hrvatski Telekom d.d. (HT) Timeline
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (1, 28.967700000000, '2025-10-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (1, 30.761000000000, '2025-11-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (1, 30.393700000000, '2025-12-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (1, 29.945000000000, '2026-01-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (1, 31.504500000000, '2026-02-15 16:00:00');

-- Podravka d.d. (PODR) Timeline
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (2, 140.211900000000, '2025-10-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (2, 137.200200000000, '2025-11-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (2, 138.231000000000, '2025-12-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (2, 138.309800000000, '2026-01-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (2, 148.988200000000, '2026-02-15 16:00:00');

-- Apple Inc. (AAPL) Timeline
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (8, 144.767900000000, '2025-10-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (8, 146.037500000000, '2025-11-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (8, 148.475300000000, '2025-12-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (8, 157.301600000000, '2026-01-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (8, 162.059500000000, '2026-02-15 16:00:00');

-- NVIDIA Corp. (NVDA) Timeline
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (10, 749.884800000000, '2025-10-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (10, 746.725500000000, '2025-11-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (10, 768.916200000000, '2025-12-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (10, 797.448500000000, '2026-01-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (10, 784.263200000000, '2026-02-15 16:00:00');

-- iShares Core S&P 500 ETF Timeline
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (21, 461.934800000000, '2025-10-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (21, 461.389400000000, '2025-11-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (21, 486.703500000000, '2025-12-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (21, 506.624200000000, '2026-01-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (21, 535.754100000000, '2026-02-15 16:00:00');

-- Bitcoin (BTC) Timeline
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (26, 57963.058900000000, '2025-10-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (26, 56546.072900000000, '2025-11-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (26, 60012.431400000000, '2025-12-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (26, 62807.491200000000, '2026-01-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (26, 63406.831300000000, '2026-02-15 16:00:00');

-- Ethereum (ETH) Timeline
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (27, 3180.618400000000, '2025-10-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (27, 3088.037200000000, '2025-11-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (27, 3208.703000000000, '2025-12-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (27, 3311.572800000000, '2026-01-15 16:00:00');
INSERT INTO povijesna_cijena_imovine (imovina_id, cijena, datum) VALUES (27, 3422.717700000000, '2026-02-15 16:00:00');

