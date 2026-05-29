DROP DATABASE IF EXISTS InvesticijskoBankarstvo;

CREATE DATABASE InvesticijskoBankarstvo;
USE InvesticijskoBankarstvo;

CREATE TABLE klijent(
  id INT PRIMARY KEY AUTO_INCREMENT,
  ime VARCHAR(45) NOT NULL,
  prezime VARCHAR(45) NOT NULL,
  OIB CHAR(11) NOT NULL UNIQUE,
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
  ime VARCHAR(255) NOT NULL UNIQUE,
  swift_kod VARCHAR(11) NOT NULL UNIQUE,
  oib CHAR(11) NOT NULL UNIQUE,
  ulica_i_kucni_broj VARCHAR(100) NOT NULL,
  postanski_broj VARCHAR(5) NOT NULL,
  mjesto VARCHAR(100),
  CHECK (OIB REGEXP '^[0-9]{11}$'),
  CHECK (postanski_broj REGEXP '^[0-9]{5}$'),
  CHECK (CHAR_LENGTH(swift_kod) IN (8, 11))
);

CREATE TABLE investicijski_racun(
  id INT PRIMARY KEY AUTO_INCREMENT,
  klijent_id INT NOT NULL,
  banka_id INT NOT NULL,
  broj_racuna VARCHAR(21) NOT NULL UNIQUE,
  stanje DECIMAL(38,12) NOT NULL DEFAULT 0,
  datum_otvaranja DATETIME NOT NULL,
  FOREIGN KEY (klijent_id) REFERENCES klijent (id) ON DELETE CASCADE,
  FOREIGN KEY (banka_id) REFERENCES banka (id) ON DELETE RESTRICT,
  CHECK (broj_racuna REGEXP '^HR[0-9]{19}$')
);

CREATE TABLE portfelj(
  id INT PRIMARY KEY AUTO_INCREMENT,
  investicijski_racun_id INT NOT NULL,
  ime VARCHAR(100) NOT NULL,
  sklonost_riziku ENUM('niska','srednja','visoka') NOT NULL,
  opis_portfelja VARCHAR(255),
  datum_otvaranja DATETIME NOT NULL,
  FOREIGN KEY (investicijski_racun_id) REFERENCES investicijski_racun (id) ON DELETE CASCADE,
  UNIQUE (investicijski_racun_id, ime) 
);

CREATE TABLE tip_imovine(
  id INT PRIMARY KEY AUTO_INCREMENT,
  tip VARCHAR(45) NOT NULL UNIQUE,
  dodatan_opis_imovine VARCHAR(255),
  razina_rizika ENUM('nizak', 'srednji', 'visok') NOT NULL
);

CREATE TABLE imovina(
  id INT PRIMARY KEY AUTO_INCREMENT,
  ime VARCHAR(45) NOT NULL UNIQUE,
  tip_imovine_id INT NOT NULL,
  oznaka_imovine VARCHAR(45) NOT NULL UNIQUE,
  FOREIGN KEY (tip_imovine_id) REFERENCES tip_imovine(id) ON DELETE RESTRICT
);

CREATE TABLE tip_transakcije(
  id INT PRIMARY KEY AUTO_INCREMENT,
  tip VARCHAR(45) NOT NULL UNIQUE,
  opis_transakcije VARCHAR(255)
);

CREATE TABLE transakcija(
  id INT PRIMARY KEY AUTO_INCREMENT,
  investicijski_racun_id INT NOT NULL,
  imovina_id INT,
  tip_transakcije_id INT NOT NULL,
  broj_naloga VARCHAR(45) NOT NULL UNIQUE,
  kolicina DECIMAL(38,18) UNSIGNED,
  cijena DECIMAL(38,18) UNSIGNED,
  naknada DECIMAL(38,18) UNSIGNED NOT NULL DEFAULT 2.00,
  datum DATETIME NOT NULL,
  iznos DECIMAL(38,18) UNSIGNED NOT NULL,
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
  FOREIGN KEY (imovina_id) REFERENCES imovina (id) ON DELETE CASCADE,
  UNIQUE (imovina_id, datum)
);

USE InvesticijskoBankarstvo;

-- ==========================================
-- 1. TIP IMOVINE
-- IZMJENA: dodana razina_rizika (NOT NULL ENUM)
-- ==========================================
INSERT INTO tip_imovine (id, tip, razina_rizika) VALUES
(1, 'Dionica',                    'visok'),
(2, 'Obveznica',                  'nizak'),
(3, 'ETF (Exchange Traded Fund)', 'srednji'),
(4, 'Kriptovaluta',               'visok'),
(5, 'Investicijski fond',         'srednji'),
(6, 'Novčani instrumenti',        'nizak');
 
-- ==========================================
-- 2. TIP TRANSAKCIJE (nepromijenjen)
-- ==========================================
INSERT INTO tip_transakcije (id, tip) VALUES
(1, 'Kupnja'),
(2, 'Prodaja'),
(3, 'Prijenos portfelja'),
(4, 'Squeeze-out');


-- ==========================================
-- 3. BANKA
-- IZMJENA: isključivo hrvatske banke i podružnice (ukupno 20),
-- usklađeno s OIB i poštanskim formatom.
-- ==========================================
INSERT INTO banka (id, ime, swift_kod, oib, ulica_i_kucni_broj, postanski_broj, mjesto) VALUES
(1,  'Zagrebačka banka d.d.',              'ZABAHR2X', '10010003623', 'Trg bana Josipa Jelačića 10', '10000', 'Zagreb'),
(2,  'Privredna banka Zagreb d.d.',        'PBZGHR2X', '02535697732', 'Radnička cesta 50',           '10000', 'Zagreb'),
(3,  'Erste & Steiermärkische Bank d.d.',  'ESBCHR22', '23057039320', 'Ivana Lučića 2',              '10000', 'Zagreb'),
(4,  'OTP banka d.d.',                     'OTPVHR2X', '44189401993', 'Domovinskog rata 61',         '21000', 'Split'),
(5,  'Raiffeisenbank Austria d.d.',        'RZBHHR2X', '53153927872', 'Petrinjska 59',               '10000', 'Zagreb'),
(6,  'Hrvatska poštanska banka d.d.',      'HPBZHR2X', '87939104217', 'Jurišićeva 4',                '10000', 'Zagreb'),
(7,  'KentBank d.d.',                      'KENTHR22', '72500276887', 'Slovenska 1',                 '10000', 'Zagreb'),
(8,  'Agram Banka d.d.',                   'AGEBHR2X', '30150388862', 'Trg Drage Iblera 10',         '10000', 'Zagreb'),
(9,  'Podravska banka d.d.',               'PODBHR2X', '12345000001', 'Ante Starčevića 14a',         '48000', 'Koprivnica'),
(10, 'Samoborska banka d.d.',              'SAMBHR2X', '23456000002', 'Trg kralja Tomislava 5',      '10430', 'Samobor'),
(11, 'Karlovačka banka d.d.',              'KARBHR2X', '34567000003', 'Gažanski trg 1',              '47000', 'Karlovac'),
(12, 'Istarska kreditna banka Umag d.d.',  'IKBUUR2X', '45678000004', 'Ernesta Miloša 1',            '52470', 'Umag'),
(13, 'Croatia banka d.d.',                 'CROAHR22', '56789000005', 'Mihovljanska 14',             '10000', 'Zagreb'),
(14, 'Partner banka d.d.',                 'PABKHR2X', '67890000006', 'Heinzelova 33',               '10000', 'Zagreb'),
(15, 'BKS Bank AG - Glavna podružnica HR', 'BFKKAT2K', '78901000007', 'Trg Petra Preradovića 4',     '10000', 'Zagreb'),
(16, 'Addiko Bank d.d.',                   'HAABHR22', '89012000016', 'Slavonska avenija 6',         '10000', 'Zagreb'),
(17, 'Slatinska banka d.d.',               'SLBCHR2X', '90123000017', 'Vladimira Nazora 2',          '33520', 'Slatina'),
(18, 'Banka Kovanica d.d.',                'KVACHR22', '01234000018', 'Preradovićeva 29',            '42000', 'Varaždin'),
(19, 'Imex banka d.d.',                    'IMXXHR22', '12345000019', 'Tolstojeva 6',                '21000', 'Split'),
(20, 'J&T banka d.d.',                     'JTBPCH2X', '23456000020', 'Ulica grada Vukovara 23a',    '10000', 'Zagreb');

-- ==========================================
-- 4. KLIJENT (nepromijenjen)
-- ==========================================
INSERT INTO klijent (id, ime, prezime, OIB, email, telefon, ulica_i_kucni_broj, postanski_broj, mjesto) VALUES
(1,  'Ivan',      'Horvat',    '12345678901', 'ivan.horvat@email.com',      '+385911234567', 'Ilica 20',                     '10000', 'Zagreb'),
(2,  'Marija',    'Kovačić',   '23456789012', 'marija.kovacic@email.com',   '+385912345678', 'Vukovarska 45',                '21000', 'Split'),
(3,  'Luka',      'Babić',     '34567890123', 'luka.babic@email.com',       '+385913456789', 'Strossmayerova 12',            '31000', 'Osijek'),
(4,  'Ana',       'Jurić',     '45678901234', 'ana.juric@email.com',        '+385914567890', 'Korzo 5',                      '51000', 'Rijeka'),
(5,  'Marko',     'Novak',     '56789012345', 'marko.novak@email.com',      '+385915678901', 'Zagrebačka 88',                '42000', 'Varaždin'),
(6,  'Petra',     'Matić',     '67890123456', 'petra.matic@email.com',      '+385916789012', 'Dubrovačka 3',                 '20000', 'Dubrovnik'),
(7,  'Filip',     'Tomat',     '78901234567', 'filip.tomat@email.com',      '+385917890123', 'Matije Gupca 14',              '35000', 'Slavonski Brod'),
(8,  'Elena',     'Knežević',  '89012345678', 'elena.knezevic@email.com',   '+385918901234', 'Poljana 2',                    '22000', 'Šibenik'),
(9,  'Karlo',     'Vuković',   '90123456789', 'karlo.vukovic@email.com',    '+385919012345', 'Ante Starčevića 54',           '23000', 'Zadar'),
(10, 'Lucija',    'Marković',  '01234567890', 'lucija.markovic@email.com',  '+385910123456', 'Gradišćanskih Hrvata 9',       '40000', 'Čakovec'),
(11, 'Mateo',     'Pavlović',  '11223344556', 'mateo.pavlovic@email.com',   '+385921112222', 'Domovinskog rata 31',          '21000', 'Split'),
(12, 'Martina',   'Blažević',  '22334455667', 'martina.blazevic@email.com', '+385922223333', 'Kneza Branimira 7',            '10000', 'Zagreb'),
(13, 'Antonio',   'Radić',     '33445566778', 'antonio.radic@email.com',    '+385923334444', 'Sisačka ulica 102',            '44000', 'Sisak'),
(14, 'Valentina', 'Stanić',    '44556677889', 'valentina.stanic@email.com', '+385924445555', 'Trg Slobode 4',                '31000', 'Osijek'),
(15, 'David',     'Filipović', '55667788990', 'david.filipovic@email.com',  '+385925556666', 'Kralja Tomislava 23',          '32100', 'Vinkovci'),
(16, 'Ivana',     'Vidović',   '66778899001', 'ivana.vidovic@email.com',    '+385926667777', 'Obala Alfirev 15',             '22211', 'Vodice'),
(17, 'Josip',     'Božić',     '77889900112', 'josip.bozic@email.com',      '+385927778888', 'Vukovarska avenija 1',         '10000', 'Zagreb'),
(18, 'Dorotea',   'Pavić',     '88990011223', 'dorotea.pavic@email.com',    '+385928889999', 'Opatijska 44',                 '51000', 'Rijeka'),
(19, 'Marin',     'Lovrić',    '99001122334', 'marin.lovric@email.com',     '+385951234567', 'Put Plokita 8',                '21000', 'Split'),
(20, 'Katarina',  'Medved',    '10101010101', 'katarina.medved@email.com',  '+385952345678', 'Gajeva 19',                    '49000', 'Krapina'),
(21, 'Bruno',     'Liović',    '20202020202', 'bruno.liovic@email.com',     '+385953456789', 'Frana Supila 11',              '52100', 'Pula'),
(22, 'Lara',      'Horvatić',  '30303030303', 'lara.horvatic@email.com',    '+385954567890', 'Trg bana Jelačića 2',          '10000', 'Zagreb'),
(23, 'Emanuel',   'Grgić',     '40404040404', 'emanuel.grgic@email.com',    '+385955678901', 'Osječka 60',                   '33000', 'Virovitica'),
(24, 'Monika',    'Barić',     '50505050505', 'monika.baric@email.com',     '+385956789012', 'Gundulićeva 13',               '31000', 'Osijek'),
(25, 'Leonardo',  'Zebić',     '60606060606', 'leonardo.zebic@email.com',   '+385957890123', 'Kapucinski trg 5',             '42000', 'Varaždin'),
(26, 'Sara',      'Perić',     '70707070707', 'sara.peric@email.com',       '+385958901234', 'Šetalište Carmen Sylve 2',     '51410', 'Opatija'),
(27, 'Mihael',    'Rupčić',    '80808080808', 'mihael.rupcic@email.com',    '+385959012345', 'Bjelovarska 33',               '43000', 'Bjelovar'),
(28, 'Teo',       'Abramović', '90909090909', 'teo.abramovic@email.com',    '+385991112222', 'Velebitska 90',                '21000', 'Split'),
(29, 'Nina',      'Mlinarić',  '12121212121', 'nina.mlinaric@email.com',    '+385992223333', 'Krapinska 4',                  '10000', 'Zagreb'),
(30, 'Viktor',    'Kosić',     '23232323232', 'viktor.kosic@email.com',     '+385993334444', 'Kružna ulica 8',               '51000', 'Rijeka');
 
-- ==========================================
-- 5. INVESTICIJSKI RAČUN (nepromijenjen)
-- ==========================================
INSERT INTO investicijski_racun (id, klijent_id, banka_id, broj_racuna, stanje, datum_otvaranja) VALUES
(1,  1,  1, 'HR1111111111111111111', 150000.50,   '2020-01-15'),
(2,  2,  2, 'HR2222222222222222222', 4500.00,     '2020-03-20'),
(3,  3,  3, 'HR3333333333333333333', 1250000.75,  '2019-06-10'),
(4,  4,  4, 'HR4444444444444444444', 32000.00,    '2021-11-01'),
(5,  5,  5, 'HR5555555555555555555', 0.00,        '2022-02-14'),
(6,  6,  6, 'HR6666666666666666666', 89500.20,    '2020-08-25'),
(7,  7,  1, 'HR7777777777777777777', 6200.00,     '2023-01-10'),
(8,  8,  2, 'HR8888888888888888888', 415000.00,   '2018-04-18'),
(9,  9,  3, 'HR9999999999999999999', 7430.55,     '2021-05-30'),
(10, 10, 4, 'HR0000000000000000000', 12500.00,    '2022-07-12'),
(11, 11, 5, 'HR1234567890123456789', 550000.00,   '2017-12-01'),
(12, 12, 6, 'HR9876543210987654321', 2300.00,     '2023-05-19'),
(13, 13, 1, 'HR1122334455667788990', 14200.00,    '2022-09-05'),
(14, 14, 2, 'HR5544332211009988776', 98000.00,    '2021-03-11'),
(15, 15, 3, 'HR1212121212121212121', 310000.15,   '2020-05-22'),
(16, 16, 4, 'HR3434343434343434343', 1500.00,     '2024-02-01'),
(17, 17, 5, 'HR5656565656565656565', 194500.00,   '2019-10-10'),
(18, 18, 6, 'HR7878787878787878787', 43000.80,    '2021-08-30'),
(19, 19, 1, 'HR9090909090909090909', 250.00,      '2023-11-15'),
(20, 20, 2, 'HR1313131313131313131', 890000.00,   '2016-01-20'),
(21, 21, 3, 'HR2424242424242424242', 17400.00,    '2022-04-05'),
(22, 22, 4, 'HR3535353535353535353', 62500.00,    '2021-06-17'),
(23, 23, 5, 'HR4646464646464646464', 3200.00,     '2023-09-21'),
(24, 24, 6, 'HR5757575757575757575', 105000.00,   '2020-12-05'),
(25, 25, 1, 'HR6868686868686868686', 412000.00,   '2018-07-19'),
(26, 26, 2, 'HR7979797979797979797', 8500.00,     '2024-01-10'),
(27, 27, 3, 'HR8080808080808080808', 29000.45,    '2022-10-02'),
(28, 28, 4, 'HR9191919191919191919', 1450.00,     '2023-03-14'),
(29, 29, 5, 'HR0202020202020202020', 67000.00,    '2021-02-28'),
(30, 30, 6, 'HR1414141414141414141', 2350000.00,  '2015-11-11');
 
-- ==========================================
-- 6. PORTFELJ
-- IZMJENA: dodana sklonost_riziku (NOT NULL ENUM)
-- ==========================================
INSERT INTO portfelj (id, investicijski_racun_id, ime, sklonost_riziku, datum_otvaranja) VALUES
(1,  1,  'Dugoročni Rast',        'visoka',  '2020-01-15 09:00:00'),
(2,  2,  'Konzervativni Portfelj','niska',   '2020-03-20 10:30:00'),
(3,  3,  'Agresivni Portfelj',    'visoka',  '2019-06-10 14:15:00'),
(4,  4,  'Tehnološke Dionice',    'visoka',  '2021-11-01 11:00:00'),
(5,  5,  'Crypto & Rizik',        'visoka',  '2022-02-14 16:45:00'),
(6,  6,  'Mirovinski Plan',       'niska',   '2020-08-25 09:15:00'),
(7,  7,  'Dividendni Prinos',     'srednja', '2023-01-10 13:00:00'),
(8,  8,  'Zlatna Rezerva',        'niska',   '2018-04-18 10:00:00'),
(9,  9,  'Glavni Portfelj',       'srednja', '2021-05-30 15:30:00'),
(10, 10, 'Štednja za Djecu',      'niska',   '2022-07-12 11:20:00'),
(11, 11, 'Nekretninski Fondovi',  'srednja', '2017-12-01 09:00:00'),
(12, 12, 'Osobni Portfelj',       'srednja', '2023-05-19 14:00:00'),
(13, 13, 'S&P 500 Fokus',         'srednja', '2022-09-05 10:45:00'),
(14, 14, 'Europske Dionice',      'srednja', '2021-03-11 16:00:00'),
(15, 15, 'Obveznički Miks',       'niska',   '2020-05-22 13:15:00'),
(16, 16, 'Pokusni račun',         'niska',   '2024-02-01 10:00:00'),
(17, 17, 'Glavni Portfelj',       'srednja', '2019-10-10 11:30:00'),
(18, 18, 'Zelena Energija',       'srednja', '2021-08-30 09:45:00'),
(19, 19, 'Osnovni',               'niska',   '2023-11-15 15:00:00'),
(20, 20, 'Veliki Likvidni',       'niska',   '2016-01-20 09:00:00'),
(21, 21, 'Srednji Rizik',         'srednja', '2022-04-05 14:30:00'),
(22, 22, 'Sve po malo',           'srednja', '2021-06-17 11:15:00'),
(23, 23, 'Špekulativni',          'visoka',  '2023-09-21 16:20:00'),
(24, 24, 'Domaće Tržište',        'srednja', '2020-12-05 10:00:00'),
(25, 25, 'Premium Invest',        'visoka',  '2018-07-19 13:00:00'),
(26, 26, 'Početnički',            'niska',   '2024-01-10 09:30:00'),
(27, 27, 'Alternativni',          'visoka',  '2022-10-02 15:45:00'),
(28, 28, 'Mali Portfelj',         'niska',   '2023-03-14 11:00:00'),
(29, 29, 'Uravnoteženi',          'srednja', '2021-02-28 14:00:00'),
(30, 30, 'Family Office',         'srednja', '2015-11-11 09:00:00');
 
-- ==========================================
-- 8. IMOVINA
-- IZMJENA: trenutna_cijena → oznaka_imovine (VARCHAR, NOT NULL UNIQUE)
-- ==========================================
INSERT INTO imovina (id, ime, tip_imovine_id, oznaka_imovine) VALUES
(1,  'Hrvatski Telekom d.d. (HT)',           1, 'HT-R-A'),
(2,  'Podravka d.d. (PODR)',                 1, 'PODR-R-A'),
(3,  'Adris Grupa d.d. (ADRS)',              1, 'ADRS-P-A'),
(4,  'Valamar Riviera d.d. (RIVP)',          1, 'RIVP-R-A'),
(5,  'Končar d.d. (KOEI)',                   1, 'KOEI-R-A'),
(6,  'Atlantic Grupa d.d. (ATGR)',           1, 'ATGR-R-A'),
(7,  'Apple Inc. (AAPL)',                    1, 'AAPL'),
(8,  'Microsoft Corp. (MSFT)',               1, 'MSFT'),
(9,  'NVIDIA Corp. (NVDA)',                  1, 'NVDA'),
(10, 'Tesla Inc. (TSLA)',                    1, 'TSLA'),
(11, 'Obveznica RH 2028 (HRRHMNO287A6)',     2, 'HRRHMNO287A6'),
(12, 'Obveznica RH 2032 (HRRHMNO327A2)',     2, 'HRRHMNO327A2'),
(13, 'Zelena Obveznica HEP 2027',            2, 'HRHEPNO270A1'),
(14, 'iShares Core S&P 500 UCITS ETF',       3, 'CSPX'),
(15, 'Vanguard FTSE All-World ETF',          3, 'VWRL'),
(16, 'iShares MSCI World EUR',               3, 'IWRD'),
(17, 'Bitcoin (BTC)',                        4, 'BTC'),
(18, 'Ethereum (ETH)',                       4, 'ETH'),
(19, 'Solana (SOL)',                         4, 'SOL'),
(20, 'Cardano (ADA)',                        4, 'ADA'),
(21, 'ZB Global Fond',                       5, 'ZB-GLOB-A'),
(22, 'Erste Asset Management Global',        5, 'ERSTE-GLOB'),
(23, 'PBZ International Fond',               5, 'PBZ-INT-A'),
(24, 'Blagajnički zapis Ministarstva Financija', 6, 'MFIN-BZ-01'),
(25, 'Komercijalni zapis kupca A',           6, 'KOM-ZAP-01'),
(26, 'Amazon.com Inc. (AMZN)',               1, 'AMZN'),
(27, 'Alphabet Inc. (GOOGL)',                1, 'GOOGL'),
(28, 'Meta Platforms Inc. (META)',           1, 'META'),
(29, 'iShares Core MSCI EM ETF',             3, 'IEMG'),
(30, 'Ripple (XRP)',                         4, 'XRP');
 
-- ========================================
-- 9. TRANSAKCIJA
-- IZMJENA: dodan iznos (NOT NULL); imovina_id bio citiran kao string
-- iznos = kolicina * cijena
-- ==========================================
INSERT INTO transakcija (id, investicijski_racun_id, imovina_id, tip_transakcije_id, broj_naloga, kolicina, cijena, naknada, datum, iznos) VALUES
(1,  1,  1,  1, 'ORD-20001', 100.00,   30.00,    5.00,   '2020-01-20 10:15:00',  3000.00),
(2,  1,  7,  1, 'ORD-20002', 10.00,    150.00,   7.50,   '2020-02-15 15:30:00',  1500.00),
(3,  2,  11, 1, 'ORD-20003', 40.00,    100.00,   0.00,   '2020-03-25 11:00:00',  4000.00),
(4,  3,  17, 1, 'ORD-20004', 5.00,     45000.00, 150.00, '2019-07-01 09:05:00',  225000.00),
(5,  3,  17, 2, 'ORD-20005', 1.50,     60000.00, 100.00, '2021-04-12 14:00:00',  90000.00),
(6,  4,  8,  1, 'ORD-20006', 20.00,    350.00,   15.00,  '2021-11-05 16:15:00',  7000.00),
(7,  4,  9,  1, 'ORD-20007', 15.00,    400.00,   12.00,  '2022-01-10 10:30:00',  6000.00),
(8,  6,  2,  1, 'ORD-20008', 50.00,    120.00,   10.00,  '2020-09-01 11:20:00',  6000.00),
(9,  6,  3,  1, 'ORD-20009', 30.00,    75.00,    8.00,   '2020-10-15 13:45:00',  2250.00),
(10, 7,  1,  1, 'ORD-20010', 150.00,   31.00,    6.50,   '2023-01-15 09:30:00',  4650.00),
(11, 8,  14, 1, 'ORD-20011', 200.00,   400.00,   40.00,  '2018-05-02 10:00:00',  80000.00),
(12, 8,  15, 1, 'ORD-20012', 500.00,   95.00,    25.00,  '2018-06-20 15:00:00',  47500.00),
(13, 9,  18, 1, 'ORD-20013', 2.00,     2500.00,  10.00,  '2021-06-05 11:15:00',  5000.00),
(14, 10, 21, 1, 'ORD-20014', 50.00,    210.00,   5.00,   '2022-07-20 14:30:00',  10500.00),
(15, 11, 12, 1, 'ORD-20015', 500.00,   99.00,    0.00,   '2017-12-10 09:00:00',  49500.00),
(16, 13, 14, 1, 'ORD-20016', 25.00,    430.00,   12.50,  '2022-09-10 10:45:00',  10750.00),
(17, 14, 27, 1, 'ORD-20017', 100.00,   140.00,   20.00,  '2021-03-20 16:00:00',  14000.00),
(18, 15, 11, 1, 'ORD-20018', 300.00,   100.50,   0.00,   '2020-05-28 11:30:00',  30150.00),
(19, 17, 8,  1, 'ORD-20019', 40.00,    380.00,   30.00,  '2019-10-15 15:20:00',  15200.00),
(20, 18, 13, 1, 'ORD-20020', 400.00,   100.00,   0.00,   '2021-09-05 09:30:00',  40000.00),
(21, 20, 7,  1, 'ORD-20021', 500.00,   160.00,   150.00, '2016-02-01 10:00:00',  80000.00),
(22, 21, 16, 1, 'ORD-20022', 150.00,   80.00,    15.00,  '2022-04-10 13:15:00',  12000.00),
(23, 22, 14, 1, 'ORD-20023', 100.00,   450.00,   25.00,  '2021-06-25 11:00:00',  45000.00),
(24, 24, 2,  1, 'ORD-20024', 400.00,   140.00,   35.00,  '2020-12-10 14:00:00',  56000.00),
(25, 25, 15, 1, 'ORD-20025', 2000.00,  102.00,   100.00, '2018-07-25 09:45:00',  204000.00),
(26, 27, 19, 1, 'ORD-20026', 100.00,   95.00,    12.00,  '2022-10-10 16:10:00',  9500.00),
(27, 29, 16, 1, 'ORD-20027', 500.00,   85.00,    30.00,  '2021-03-05 10:30:00',  42500.00),
(28, 30, 9,  1, 'ORD-20028', 1000.00,  300.00,   500.00, '2015-11-20 09:15:00',  300000.00),
(29, 30, 17, 1, 'ORD-20029', 10.00,    15000.00, 200.00, '2017-05-14 11:00:00',  150000.00),
(30, 30, 17, 2, 'ORD-20030', 5.00,     45000.00, 300.00, '2021-02-18 15:45:00',  225000.00);
 
-- ==========================================
-- 10. PORTFELJ IMOVINA (nepromijenjen)
-- ==========================================
INSERT INTO portfelj_imovina (id, portfelj_id, imovina_id, kolicina) VALUES
(1,  1,  1,  100.00),
(2,  1,  7,  10.00),
(3,  2,  11, 40.00),
(4,  3,  17, 3.50),
(5,  4,  8,  20.00),
(6,  4,  9,  15.00),
(7,  6,  2,  50.00),
(8,  6,  3,  30.00),
(9,  7,  1,  150.00),
(10, 8,  14, 200.00),
(11, 8,  15, 500.00),
(12, 9,  18, 2.00),
(13, 10, 21, 50.00),
(14, 11, 12, 500.00),
(15, 13, 14, 25.00),
(16, 14, 27, 100.00),
(17, 15, 11, 300.00),
(18, 17, 8,  40.00),
(19, 18, 13, 400.00),
(20, 20, 7,  500.00),
(21, 21, 16, 150.00),
(22, 22, 14, 100.00),
(23, 24, 2,  400.00),
(24, 25, 15, 2000.00),
(25, 27, 19, 100.00),
(26, 29, 16, 500.00),
(27, 30, 9,  1000.00),
(28, 30, 17, 5.00),
(29, 1,  2,  15.00),
(30, 3,  18, 1.25);
 
-- ==========================================
-- 11. POVIJESNA CIJENA IMOVINE (nepromijenjen)
-- ==========================================
INSERT INTO povijesna_cijena_imovine (id, imovina_id, cijena, datum) VALUES
(1,  1,  29.50,    '2023-01-01 17:00:00'),
(2,  1,  31.00,    '2023-06-01 17:00:00'),
(3,  1,  32.50,    '2024-01-01 17:00:00'),
(4,  2,  145.00,   '2023-01-01 17:00:00'),
(5,  2,  152.00,   '2023-08-15 17:00:00'),
(6,  2,  160.00,   '2024-03-01 17:00:00'),
(7,  7,  150.00,   '2022-05-10 16:00:00'),
(8,  7,  165.00,   '2023-01-15 16:00:00'),
(9,  7,  175.30,   '2024-02-20 16:00:00'),
(10, 8,  320.00,   '2022-03-01 16:00:00'),
(11, 8,  380.00,   '2023-05-12 16:00:00'),
(12, 8,  420.15,   '2024-04-01 16:00:00'),
(13, 9,  250.00,   '2022-01-10 16:00:00'),
(14, 9,  480.00,   '2023-06-14 16:00:00'),
(15, 9,  900.80,   '2024-05-10 16:00:00'),
(16, 17, 30000.00, '2023-01-01 00:00:00'),
(17, 17, 45000.00, '2023-10-15 00:00:00'),
(18, 17, 65200.00, '2024-04-15 00:00:00'),
(19, 18, 1800.00,  '2023-01-01 00:00:00'),
(20, 18, 2500.00,  '2023-11-01 00:00:00'),
(21, 18, 3450.25,  '2024-03-10 00:00:00'),
(22, 14, 410.00,   '2022-12-31 17:00:00'),
(23, 14, 445.00,   '2023-07-31 17:00:00'),
(24, 14, 485.60,   '2024-04-30 17:00:00'),
(25, 3,  75.00,    '2022-05-05 17:00:00'),
(26, 3,  79.00,    '2023-02-18 17:00:00'),
(27, 3,  82.00,    '2024-01-12 17:00:00'),
(28, 11, 100.00,   '2021-01-01 09:00:00'),
(29, 11, 100.50,   '2022-01-01 09:00:00'),
(30, 11, 101.25,   '2023-01-01 09:00:00');

 
-- ==============================================================================
-- UPITI
-- ==============================================================================
 
SELECT k.ime, k.prezime, ROUND(r.stanje, 2)
FROM klijent AS k
JOIN investicijski_racun AS r ON k.id = r.klijent_id;
 
SELECT ime, prezime, mjesto, ROUND(r.stanje, 2)
FROM klijent AS k
JOIN investicijski_racun AS r ON k.id = r.klijent_id
WHERE mjesto = 'Zagreb'
ORDER BY r.stanje DESC;
 
SELECT * FROM tip_transakcije;
 
-- ==============================================================================
-- UPIT 2: NAJPOPULARNIJA IMOVINA NA PLATFORMI
-- ==============================================================================
SELECT
    i.ime AS naziv_imovine,
    COUNT(t.id) AS ukupan_broj_transakcija,
    ROUND(SUM(t.kolicina * t.cijena), 2) AS ukupno_ulozen_novac
FROM imovina i
JOIN transakcija t ON i.id = t.imovina_id
GROUP BY i.id, i.ime
ORDER BY ukupno_ulozen_novac DESC;
 
-- ==============================================================================
-- VIEW 1: KATALOG IMOVINE S TRENUTNIM CIJENAMA
-- ==============================================================================
CREATE OR REPLACE VIEW katalog_imovine_cijene AS
SELECT i.ime, ti.tip, pci.cijena, pci.datum
FROM imovina i
JOIN tip_imovine ti ON i.tip_imovine_id = ti.id
JOIN povijesna_cijena_imovine pci ON i.id = pci.imovina_id
WHERE pci.datum = (
    SELECT MAX(pci2.datum)
    FROM povijesna_cijena_imovine pci2
    WHERE pci2.imovina_id = pci.imovina_id
);
 
SELECT * FROM katalog_imovine_cijene;
 
-- ==============================================================================
-- VIEW 2: STRUKTURA PORTFELJA KORISNIKA
-- ==============================================================================
CREATE OR REPLACE VIEW struktura_portfelja_korisnika AS
SELECT
    k.prezime,
    k.ime,
    ti.tip AS kategorija_imovine,
    SUM(pi.kolicina) AS ukupna_kolicina
FROM klijent k
JOIN investicijski_racun ir ON k.id = ir.klijent_id
JOIN portfelj p ON ir.id = p.investicijski_racun_id
JOIN portfelj_imovina pi ON p.id = pi.portfelj_id
JOIN imovina i ON pi.imovina_id = i.id
JOIN tip_imovine ti ON i.tip_imovine_id = ti.id
GROUP BY k.id, k.ime, k.prezime, ti.id, ti.tip;
 
SELECT * FROM struktura_portfelja_korisnika
ORDER BY prezime ASC, ime ASC;
