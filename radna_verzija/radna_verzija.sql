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
	mjesto VARCHAR(45) NOT NULL,
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
	stanje DECIMAL(38,12) NOT NULL DEFAULT 0,
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
	naknada DECIMAL(38,18) UNSIGNED NOT NULL DEFAULT 0,
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

USE InvesticijskoBankarstvo;

-- ==========================================
-- 1. TIP IMOVINE (Šifrarnik - logički broj zapisa)
-- ==========================================
INSERT INTO tip_imovine (id, tip) VALUES
(1, 'Dionica'),
(2, 'Obveznica'),
(3, 'ETF (Exchange Traded Fund)'),
(4, 'Kriptovaluta'),
(5, 'Investicijski fond'),
(6, 'Novčani instrumenti');

-- ==========================================
-- 2. TIP TRANSAKCIJE (Šifrarnik - logički broj zapisa)
-- ==========================================
INSERT INTO tip_transakcije (id, tip) VALUES
(1, 'Kupnja'),
(2, 'Prodaja'),
(3, 'Prijenos porfelja'),
(4, 'Squeeze-out');

-- ==========================================
-- 3. BANKA (30 zapisa - Domaće i strane banke)
-- ==========================================
INSERT INTO banka (id, ime) VALUES
(1, 'Zagrebačka banka d.d.'),
(2, 'Privredna banka Zagreb d.d.'),
(3, 'Erste & Steiermärkische Bank d.d.'),
(4, 'OTP banka d.d.'),
(5, 'Raiffeisenbank Austria d.d.'),
(6, 'Hrvatska poštanska banka d.d.'),
(7, 'KentBank d.d.'),
(8, 'Agram Banka d.d.'),
(9, 'Podravska banka d.d.'),
(10, 'Samoborska banka d.d.'),
(11, 'Karlovačka banka d.d.'),
(12, 'Istarska kreditna banka Umag d.d.'),
(13, 'Croatia banka d.d.'),
(14, 'Partner banka d.d.'),
(15, 'BKS Bank AG - Glavna podružnica Hrvatska'),
(16, 'Deutsche Bank AG'),
(17, 'HSBC Holdings PLC'),
(18, 'Goldman Sachs Group Inc.'),
(19, 'JPMorgan Chase & Co.'),
(20, 'Morgan Stanley'),
(21, 'Citigroup Inc.'),
(22, 'UBS Group AG'),
(23, 'Barclays PLC'),
(24, 'BNP Paribas S.A.'),
(25, 'Société Générale S.A.'),
(26, 'Banco Santander S.A.'),
(27, 'ING Groep N.V.'),
(28, 'Bank of America Corp.'),
(29, 'Wells Fargo & Co.'),
(30, 'Commerzbank AG');

-- ==========================================
-- 4. KLIJENT (30 zapisa s validnim OIB-om i poštanskim brojem)
-- ==========================================
INSERT INTO klijent (id, ime, prezime, OIB, email, telefon, ulica_i_kucni_broj, postanski_broj, mjesto) VALUES
(1, 'Ivan', 'Horvat', '12345678901', 'ivan.horvat@email.com', '+385911234567', 'Ilica 20', '10000', 'Zagreb'),
(2, 'Marija', 'Kovačić', '23456789012', 'marija.kovacic@email.com', '+385912345678', 'Vukovarska 45', '21000', 'Split'),
(3, 'Luka', 'Babić', '34567890123', 'luka.babic@email.com', '+385913456789', 'Strossmayerova 12', '31000', 'Osijek'),
(4, 'Ana', 'Jurić', '45678901234', 'ana.juric@email.com', '+385914567890', 'Korzo 5', '51000', 'Rijeka'),
(5, 'Marko', 'Novak', '56789012345', 'marko.novak@email.com', '+385915678901', 'Zagrebačka 88', '42000', 'Varaždin'),
(6, 'Petra', 'Matić', '67890123456', 'petra.matic@email.com', '+385916789012', 'Dubrovačka 3', '20000', 'Dubrovnik'),
(7, 'Filip', 'Tomat', '78901234567', 'filip.tomat@email.com', '+385917890123', 'Matije Gupca 14', '35000', 'Slavonski Brod'),
(8, 'Elena', 'Knežević', '89012345678', 'elena.knezevic@email.com', '+385918901234', 'Poljana 2', '22000', 'Šibenik'),
(9, 'Karlo', 'Vuković', '90123456789', 'karlo.vukovic@email.com', '+385919012345', 'Ante Starčevića 54', '23000', 'Zadar'),
(10, 'Lucija', 'Marković', '01234567890', 'lucija.markovic@email.com', '+385910123456', 'Gradišćanskih Hrvata 9', '40000', 'Čakovec'),
(11, 'Mateo', 'Pavlović', '11223344556', 'mateo.pavlovic@email.com', '+385921112222', 'Domovinskog rata 31', '21000', 'Split'),
(12, 'Martina', 'Blažević', '22334455667', 'martina.blazevic@email.com', '+385922223333', 'Kneza Branimira 7', '10000', 'Zagreb'),
(13, 'Antonio', 'Radić', '33445566778', 'antonio.radic@email.com', '+385923334444', 'Sisačka ulica 102', '44000', 'Sisak'),
(14, 'Valentina', 'Stanić', '44556677889', 'valentina.stanic@email.com', '+385924445555', 'Trg Slobode 4', '31000', 'Osijek'),
(15, 'David', 'Filipović', '55667788990', 'david.filipovic@email.com', '+385925556666', 'Kralja Tomislava 23', '32100', 'Vinkovci'),
(16, 'Ivana', 'Vidović', '66778899001', 'ivana.vidovic@email.com', '+385926667777', 'Obala Alfirev 15', '22211', 'Vodice'),
(17, 'Josip', 'Božić', '77889900112', 'josip.bozic@email.com', '+385927778888', 'Vukovarska avenija 1', '10000', 'Zagreb'),
(18, 'Dorotea', 'Pavić', '88990011223', 'dorotea.pavic@email.com', '+385928889999', 'Opatijska 44', '51000', 'Rijeka'),
(19, 'Marin', 'Lovrić', '99001122334', 'marin.lovric@email.com', '+385951234567', 'Put Plokita 8', '21000', 'Split'),
(20, 'Katarina', 'Medved', '10101010101', 'katarina.medved@email.com', '+385952345678', 'Gajeva 19', '49000', 'Krapina'),
(21, 'Bruno', 'Liović', '20202020202', 'bruno.liovic@email.com', '+385953456789', 'Frana Supila 11', '52100', 'Pula'),
(22, 'Lara', 'Horvatić', '30303030303', 'lara.horvatic@email.com', '+385954567890', 'Trg bana Jelačića 2', '10000', 'Zagreb'),
(23, 'Emanuel', 'Grgić', '40404040404', 'emanuel.grgić@email.com', '+385955678901', 'Osječka 60', '33000', 'Virovitica'),
(24, 'Monika', 'Barić', '50505050505', 'monika.baric@email.com', '+385956789012', 'Gundulićeva 13', '31000', 'Osijek'),
(25, 'Leonardo', 'Zebić', '60606060606', 'leonardo.zebic@email.com', '+385957890123', 'Kapucinski trg 5', '42000', 'Varaždin'),
(26, 'Sara', 'Perić', '70707070707', 'sara.peric@email.com', '+385958901234', 'Šetalište Carmen Sylve 2', '51410', 'Opatija'),
(27, 'Mihael', 'Rupčić', '80808080808', 'mihael.rupcic@email.com', '+385959012345', 'Bjelovarska 33', '43000', 'Bjelovar'),
(28, 'Teo', 'Abramović', '90909090909', 'teo.abramovic@email.com', '+385991112222', 'Velebitska 90', '21000', 'Split'),
(29, 'Nina', 'Mlinarić', '12121212121', 'nina.mlinaric@email.com', '+385992223333', 'Krapinska 4', '10000', 'Zagreb'),
(30, 'Viktor', 'Kosić', '23232323232', 'viktor.kosic@email.com', '+385993334444', 'Kružna ulica 8', '51000', 'Rijeka');

-- ==========================================
-- 5. INVESTICIJSKI RAČUN (30 zapisa - validni HR IBAN-i)
-- ==========================================
INSERT INTO investicijski_racun (id, klijent_id, banka_id, broj_racuna, stanje, datum_otvaranja) VALUES
(1, 1, 1, 'HR1111111111111111111', 150000.50, '2020-01-15'),
(2, 2, 2, 'HR2222222222222222222', 4500.00, '2020-03-20'),
(3, 3, 3, 'HR3333333333333333333', 1250000.75, '2019-06-10'),
(4, 4, 4, 'HR4444444444444444444', 32000.00, '2021-11-01'),
(5, 5, 5, 'HR5555555555555555555', 0.00, '2022-02-14'),
(6, 6, 6, 'HR6666666666666666666', 89500.20, '2020-08-25'),
(7, 7, 1, 'HR7777777777777777777', 6200.00, '2023-01-10'),
(8, 8, 2, 'HR8888888888888888888', 415000.00, '2018-04-18'),
(9, 9, 3, 'HR9999999999999999999', 7430.55, '2021-05-30'),
(10, 10, 4, 'HR0000000000000000000', 12500.00, '2022-07-12'),
(11, 11, 5, 'HR1234567890123456789', 550000.00, '2017-12-01'),
(12, 12, 6, 'HR9876543210987654321', 2300.00, '2023-05-19'),
(13, 13, 1, 'HR1122334455667788990', 14200.00, '2022-09-05'),
(14, 14, 2, 'HR5544332211009988776', 98000.00, '2021-03-11'),
(15, 15, 3, 'HR1212121212121212121', 310000.15, '2020-05-22'),
(16, 16, 4, 'HR3434343434343434343', 1500.00, '2024-02-01'),
(17, 17, 5, 'HR5656565656565656565', 194500.00, '2019-10-10'),
(18, 18, 6, 'HR7878787878787878787', 43000.80, '2021-08-30'),
(19, 19, 1, 'HR9090909090909090909', 250.00, '2023-11-15'),
(20, 20, 2, 'HR1313131313131313131', 890000.00, '2016-01-20'),
(21, 21, 3, 'HR2424242424242424242', 17400.00, '2022-04-05'),
(22, 22, 4, 'HR3535353535353535353', 62500.00, '2021-06-17'),
(23, 23, 5, 'HR4646464646464646464', 3200.00, '2023-09-21'),
(24, 24, 6, 'HR5757575757575757575', 105000.00, '2020-12-05'),
(25, 25, 1, 'HR6868686868686868686', 412000.00, '2018-07-19'),
(26, 26, 2, 'HR7979797979797979797', 8500.00, '2024-01-10'),
(27, 27, 3, 'HR8080808080808080808', 29000.45, '2022-10-02'),
(28, 28, 4, 'HR9191919191919191919', 1450.00, '2023-03-14'),
(29, 29, 5, 'HR0202020202020202020', 67000.00, '2021-02-28'),
(30, 30, 6, 'HR1414141414141414141', 2350000.00, '2015-11-11');

-- ==========================================
-- 6. PORTFELJ (30 zapisa)
-- ==========================================
INSERT INTO portfelj (id, investicijski_racun_id, ime, datum_otvaranja) VALUES
(1, 1, 'Dugoročni Rast', '2020-01-15 09:00:00'),
(2, 2, 'Konzervativni Portfelj', '2020-03-20 10:30:00'),
(3, 3, 'Agresivni Portfelj', '2019-06-10 14:15:00'),
(4, 4, 'Tehnološke Dionice', '2021-11-01 11:00:00'),
(5, 5, 'Crypto & Rizik', '2022-02-14 16:45:00'),
(6, 6, 'Mirovinski Plan', '2020-08-25 09:15:00'),
(7, 7, 'Dividendni Prinos', '2023-01-10 13:00:00'),
(8, 8, 'Zlatna Rezerva', '2018-04-18 10:00:00'),
(9, 9, 'Glavni Portfelj', '2021-05-30 15:30:00'),
(10, 10, 'Štednja za Djecu', '2022-07-12 11:20:00'),
(11, 11, 'Nekretninski Fondovi', '2017-12-01 09:00:00'),
(12, 12, 'Osobni Portfelj', '2023-05-19 14:00:00'),
(13, 13, 'S&P 500 Fokus', '2022-09-05 10:45:00'),
(14, 14, 'Europske Dionice', '2021-03-11 16:00:00'),
(15, 15, 'Obveznički Miks', '2020-05-22 13:15:00'),
(16, 16, 'Pokusni račun', '2024-02-01 10:00:00'),
(17, 17, 'Glavni Portfelj', '2019-10-10 11:30:00'),
(18, 18, 'Zelena Energija', '2021-08-30 09:45:00'),
(19, 19, 'Osnovni', '2023-11-15 15:00:00'),
(20, 20, 'Veliki Likvidni', '2016-01-20 09:00:00'),
(21, 21, 'Srednji Rizik', '2022-04-05 14:30:00'),
(22, 22, 'Sve po malo', '2021-06-17 11:15:00'),
(23, 23, 'Špekulativni', '2023-09-21 16:20:00'),
(24, 24, 'Domaće Tržište', '2020-12-05 10:00:00'),
(25, 25, 'Premium Invest', '2018-07-19 13:00:00'),
(26, 26, 'Početnički', '2024-01-10 09:30:00'),
(27, 27, 'Alternativni', '2022-10-02 15:45:00'),
(28, 28, 'Mali Portfelj', '2023-03-14 11:00:00'),
(29, 29, 'Uravnoteženi', '2021-02-28 14:00:00'),
(30, 30, 'Family Office', '2015-11-11 09:00:00');

-- ==========================================
-- 7. UPLATA / ISPLATA (30 zapisa)
-- ==========================================
INSERT INTO uplata_isplata (id, investicijski_racun_id, broj_transakcije, iznos, datum, vrsta_prometa) VALUES
(1, 1, 'TX-10001', 50000.00, '2020-01-16 10:00:00', 'uplata'),
(2, 1, 'TX-10002', 5000.00, '2020-05-12 14:20:00', 'isplata'),
(3, 2, 'TX-10003', 4500.00, '2020-03-21 09:15:00', 'uplata'),
(4, 3, 'TX-10004', 1000000.00, '2019-06-11 11:00:00', 'uplata'),
(5, 3, 'TX-10005', 50000.00, '2022-08-14 16:30:00', 'isplata'),
(6, 4, 'TX-10006', 32000.00, '2021-11-02 13:10:00', 'uplata'),
(7, 6, 'TX-10007', 90000.00, '2020-08-26 10:00:00', 'uplata'),
(8, 7, 'TX-10008', 6200.00, '2023-01-11 09:45:00', 'uplata'),
(9, 8, 'TX-10009', 415000.00, '2018-04-19 11:15:00', 'uplata'),
(10, 9, 'TX-10010', 10000.00, '2021-06-01 14:00:00', 'uplata'),
(11, 10, 'TX-10011', 12500.00, '2022-07-13 10:30:00', 'uplata'),
(12, 11, 'TX-10012', 550000.00, '2017-12-02 09:30:00', 'uplata'),
(13, 12, 'TX-10013', 5000.00, '2023-05-20 15:20:00', 'uplata'),
(14, 12, 'TX-10014', 2700.00, '2023-12-01 11:00:00', 'isplata'),
(15, 13, 'TX-10015', 14200.00, '2022-09-06 13:45:00', 'uplata'),
(16, 14, 'TX-10016', 98000.00, '2021-03-12 10:00:00', 'uplata'),
(17, 15, 'TX-10017', 310000.00, '2020-05-23 09:00:00', 'uplata'),
(18, 16, 'TX-10018', 1500.00, '2024-02-02 16:10:00', 'uplata'),
(19, 17, 'TX-10019', 200000.00, '2019-10-11 11:30:00', 'uplata'),
(20, 17, 'TX-10020', 5500.00, '2021-04-05 14:00:00', 'isplata'),
(21, 18, 'TX-10021', 43000.00, '2021-08-31 10:15:00', 'uplata'),
(22, 19, 'TX-10022', 250.00, '2023-11-16 09:00:00', 'uplata'),
(23, 20, 'TX-10023', 890000.00, '2016-01-21 13:00:00', 'uplata'),
(24, 21, 'TX-10024', 17400.00, '2022-04-06 11:45:00', 'uplata'),
(25, 22, 'TX-10025', 62500.00, '2021-06-18 10:30:00', 'uplata'),
(26, 23, 'TX-10026', 3200.00, '2023-09-22 15:00:00', 'uplata'),
(27, 24, 'TX-10027', 105000.00, '2020-12-06 09:15:00', 'uplata'),
(28, 25, 'TX-10028', 412000.00, '2018-07-20 14:00:00', 'uplata'),
(29, 26, 'TX-10029', 8500.00, '2024-01-11 10:45:00', 'uplata'),
(30, 27, 'TX-10030', 29000.00, '2022-10-03 13:30:00', 'uplata');

-- ==========================================
-- 8. IMOVINA (30 zapisa - Miks dionica, ETF-ova, Kripta...)
-- ==========================================
INSERT INTO imovina (id, ime, tip_imovine_id, trenutna_cijena) VALUES
(1, 'Hrvatski Telekom d.d. (HT)', 1, 32.50),
(2, 'Podravka d.d. (PODR)', 1, 160.00),
(3, 'Adris Grupa d.d. (ADRS)', 1, 82.00),
(4, 'Valamar Riviera d.d. (RIVP)', 1, 5.20),
(5, 'Končar d.d. (KOEI)', 1, 250.00),
(6, 'Atlantic Grupa d.d. (ATGR)', 1, 55.50),
(7, 'Apple Inc. (AAPL)', 1, 175.30),
(8, 'Microsoft Corp. (MSFT)', 1, 420.15),
(9, 'NVIDIA Corp. (NVDA)', 1, 900.80),
(10, 'Tesla Inc. (TSLA)', 1, 180.50),
(11, 'Obveznica RH 2028 (HRRHMNO287A6)', 2, 101.25),
(12, 'Obveznica RH 2032 (HRRHMNO327A2)', 2, 98.50),
(13, 'Zelena Obveznica HEP 2027', 2, 100.00),
(14, 'iShares Core S&P 500 UCITS ETF', 3, 485.60),
(15, 'Vanguard FTSE All-World ETF', 3, 115.20),
(16, 'iShares MSCI World EUR', 3, 89.40),
(17, 'Bitcoin (BTC)', 4, 65200.00),
(18, 'Ethereum (ETH)', 4, 3450.25),
(19, 'Solana (SOL)', 4, 152.10),
(20, 'Cardano (ADA)', 4, 0.48),
(21, 'ZB Global Fond', 5, 230.40),
(22, 'Erste Asset Management Global', 5, 145.90),
(23, 'PBZ International Fond', 5, 310.10),
(24, 'Blagajnički zapis Ministarstva Financija', 6, 975.00),
(25, 'Komercijalni zapis kupca A', 6, 100.00),
(26, 'Amazon.com Inc. (AMZN)', 1, 185.00),
(27, 'Alphabet Inc. (GOOGL)', 1, 170.20),
(28, 'Meta Platforms Inc. (META)', 1, 475.00),
(29, 'iShares Core MSCI EM ETF', 3, 42.10),
(30, 'Ripple (XRP)', 4, 0.52);

-- ==========================================
-- 9. TRANSAKCIJA (30 zapisa o kupnji/prodaji imovine)
-- ==========================================
INSERT INTO transakcija (id, investicijski_racun_id, imovina_id, tip_transakcije_id, broj_naloga, kolicina, cijena, naknada, datum) VALUES
(1, 1, '1', 1, 'ORD-20001', 100.00, 30.00, 5.00, '2020-01-20 10:15:00'),
(2, 1, '7', 1, 'ORD-20002', 10.00, 150.00, 7.50, '2020-02-15 15:30:00'),
(3, 2, '11', 1, 'ORD-20003', 40.00, 100.00, 0.00, '2020-03-25 11:00:00'),
(4, 3, '17', 1, 'ORD-20004', 5.00, 45000.00, 150.00, '2019-07-01 09:05:00'),
(5, 3, '17', 2, 'ORD-20005', 1.50, 60000.00, 100.00, '2021-04-12 14:00:00'),
(6, 4, '8', 1, 'ORD-20006', 20.00, 350.00, 15.00, '2021-11-05 16:15:00'),
(7, 4, '9', 1, 'ORD-20007', 15.00, 400.00, 12.00, '2022-01-10 10:30:00'),
(8, 6, '2', 1, 'ORD-20008', 50.00, 120.00, 10.00, '2020-09-01 11:20:00'),
(9, 6, '3', 1, 'ORD-20009', 30.00, 75.00, 8.00, '2020-10-15 13:45:00'),
(10, 7, '1', 1, 'ORD-20010', 150.00, 31.00, 6.50, '2023-01-15 09:30:00'),
(11, 8, '14', 1, 'ORD-20011', 200.00, 400.00, 40.00, '2018-05-02 10:00:00'),
(12, 8, '15', 1, 'ORD-20012', 500.00, 95.00, 25.00, '2018-06-20 15:00:00'),
(13, 9, '18', 1, 'ORD-20013', 2.00, 2500.00, 10.00, '2021-06-05 11:15:00'),
(14, 10, '21', 1, 'ORD-20014', 50.00, 210.00, 5.00, '2022-07-20 14:30:00'),
(15, 11, '12', 1, 'ORD-20015', 500.00, 99.00, 0.00, '2017-12-10 09:00:00'),
(16, 13, '14', 1, 'ORD-20016', 25.00, 430.00, 12.50, '2022-09-10 10:45:00'),
(17, 14, '27', 1, 'ORD-20017', 100.00, 140.00, 20.00, '2021-03-20 16:00:00'),
(18, 15, '11', 1, 'ORD-20018', 300.00, 100.50, 0.00, '2020-05-28 11:30:00'),
(19, 17, '8', 1, 'ORD-20019', 40.00, 380.00, 30.00, '2019-10-15 15:20:00'),
(20, 18, '13', 1, 'ORD-20020', 400.00, 100.00, 0.00, '2021-09-05 09:30:00'),
(21, 20, '7', 1, 'ORD-20021', 500.00, 160.00, 150.00, '2016-02-01 10:00:00'),
(22, 21, '16', 1, 'ORD-20022', 150.00, 80.00, 15.00, '2022-04-10 13:15:00'),
(23, 22, '14', 1, 'ORD-20023', 100.00, 450.00, 25.00, '2021-06-25 11:00:00'),
(24, 24, '2', 1, 'ORD-20024', 400.00, 140.00, 35.00, '2020-12-10 14:00:00'),
(25, 25, '15', 1, 'ORD-20025', 2000.00, 102.00, 100.00, '2018-07-25 09:45:00'),
(26, 27, '19', 1, 'ORD-20026', 100.00, 95.00, 12.00, '2022-10-10 16:10:00'),
(27, 29, '16', 1, 'ORD-20027', 500.00, 85.00, 30.00, '2021-03-05 10:30:00'),
(28, 30, '9', 1, 'ORD-20028', 1000.00, 300.00, 500.00, '2015-11-20 09:15:00'),
(29, 30, '17', 1, 'ORD-20029', 10.00, 15000.00, 200.00, '2017-05-14 11:00:00'),
(30, 30, '17', 2, 'ORD-20030', 5.00, 45000.00, 300.00, '2021-02-18 15:45:00');

-- ==========================================
-- 10. PORTFELJ IMOVINA (30 zapisa - Stanje u portfeljima)
-- ==========================================
INSERT INTO portfelj_imovina (id, portfelj_id, imovina_id, kolicina) VALUES
(1, 1, 1, 100.00),
(2, 1, 7, 10.00),
(3, 2, 11, 40.00),
(4, 3, 17, 3.50),
(5, 4, 8, 20.00),
(6, 4, 9, 15.00),
(7, 6, 2, 50.00),
(8, 6, 3, 30.00),
(9, 7, 1, 150.00),
(10, 8, 14, 200.00),
(11, 8, 15, 500.00),
(12, 9, 18, 2.00),
(13, 10, 21, 50.00),
(14, 11, 12, 500.00),
(15, 13, 14, 25.00),
(16, 14, 27, 100.00),
(17, 15, 11, 300.00),
(18, 17, 8, 40.00),
(19, 18, 13, 400.00),
(20, 20, 7, 500.00),
(21, 21, 16, 150.00),
(22, 22, 14, 100.00),
(23, 24, 2, 400.00),
(24, 25, 15, 2000.00),
(25, 27, 19, 100.00),
(26, 29, 16, 500.00),
(27, 30, 9, 1000.00),
(28, 30, 17, 5.00),
(29, 1, 2, 15.00),
(30, 3, 18, 1.25);

-- ==========================================
-- 11. POVIJESNA CIJENA IMOVINE (30 zapisa proračunatih promjena)
-- ==========================================
INSERT INTO povijesna_cijena_imovine (id, imovina_id, cijena, datum) VALUES
(1, 1, 29.50, '2023-01-01 17:00:00'),
(2, 1, 31.00, '2023-06-01 17:00:00'),
(3, 1, 32.50, '2024-01-01 17:00:00'),
(4, 2, 145.00, '2023-01-01 17:00:00'),
(5, 2, 152.00, '2023-08-15 17:00:00'),
(6, 2, 160.00, '2024-03-01 17:00:00'),
(7, 7, 150.00, '2022-05-10 16:00:00'),
(8, 7, 165.00, '2023-01-15 16:00:00'),
(9, 7, 175.30, '2024-02-20 16:00:00'),
(10, 8, 320.00, '2022-03-01 16:00:00'),
(11, 8, 380.00, '2023-05-12 16:00:00'),
(12, 8, 420.15, '2024-04-01 16:00:00'),
(13, 9, 250.00, '2022-01-10 16:00:00'),
(14, 9, 480.00, '2023-06-14 16:00:00'),
(15, 9, 900.80, '2024-05-10 16:00:00'),
(16, 17, 30000.00, '2023-01-01 00:00:00'),
(17, 17, 45000.00, '2023-10-15 00:00:00'),
(18, 17, 65200.00, '2024-04-15 00:00:00'),
(19, 18, 1800.00, '2023-01-01 00:00:00'),
(20, 18, 2500.00, '2023-11-01 00:00:00'),
(21, 18, 3450.25, '2024-03-10 00:00:00'),
(22, 14, 410.00, '2022-12-31 17:00:00'),
(23, 14, 445.00, '2023-07-31 17:00:00'),
(24, 14, 485.60, '2024-04-30 17:00:00'),
(25, 3, 75.00, '2022-05-05 17:00:00'),
(26, 3, 79.00, '2023-02-18 17:00:00'),
(27, 3, 82.00, '2024-01-12 17:00:00'),
(28, 11, 100.00, '2021-01-01 09:00:00'),
(29, 11, 100.50, '2022-01-01 09:00:00'),
(30, 11, 101.25, '2023-01-01 09:00:00');

-- ==========================================
-- 12. DIVIDENDA (30 zapisa isplata za HT, Podravku, Apple, itd.)
-- ==========================================
INSERT INTO dividenda (id, imovina_id, datum, iznos) VALUES
(1, 1, '2020-05-20 00:00:00', 1.10),
(2, 1, '2021-05-18 00:00:00', 1.20),
(3, 1, '2022-05-23 00:00:00', 1.30),
(4, 1, '2023-05-19 00:00:00', 1.40),
(5, 2, '2020-08-10 00:00:00', 2.50),
(6, 2, '2021-08-12 00:00:00', 2.70),
(7, 2, '2022-08-11 00:00:00', 3.00),
(8, 2, '2023-08-14 00:00:00', 3.20),
(9, 3, '2021-07-05 00:00:00', 4.00),
(10, 3, '2022-07-04 00:00:00', 4.20),
(11, 3, '2023-07-03 00:00:00', 4.50),
(12, 7, '2021-02-15 00:00:00', 0.22),
(13, 7, '2021-05-17 00:00:00', 0.22),
(14, 7, '2021-08-16 00:00:00', 0.22),
(15, 7, '2021-11-15 00:00:00', 0.22),
(16, 7, '2022-02-14 00:00:00', 0.23),
(17, 7, '2022-05-16 00:00:00', 0.23),
(18, 7, '2022-08-15 00:00:00', 0.23),
(19, 7, '2022-11-14 00:00:00', 0.23),
(20, 8, '2022-03-10 00:00:00', 0.62),
(21, 8, '2022-06-09 00:00:00', 0.62),
(22, 8, '2022-09-08 00:00:00', 0.62),
(23, 8, '2022-12-08 00:00:00', 0.68),
(24, 26, '2023-02-10 00:00:00', 0.15),
(25, 26, '2023-05-12 00:00:00', 0.15),
(26, 26, '2023-08-11 00:00:00', 0.15),
(27, 26, '2023-11-10 00:00:00', 0.15),
(28, 6, '2022-06-25 00:00:00', 1.50),
(29, 6, '2023-06-28 00:00:00', 1.80),
(30, 5, '2023-07-15 00:00:00', 5.00);
