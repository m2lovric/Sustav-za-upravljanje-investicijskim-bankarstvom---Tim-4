-- ==============================================================================
-- ======= ZAGRIJAVANJE (ODRAĐENO) ========
-- ==============================================================================

SELECT k.ime, k.prezime, ROUND(r.stanje, 2) AS stanje_racuna
FROM klijent AS k 
JOIN investicijski_racun AS r ON k.id = r.klijent_id;

SELECT k.ime, k.prezime, k.mjesto, ROUND(r.stanje, 2) AS stanje_racuna
FROM klijent AS k 
JOIN investicijski_racun AS r ON k.id = r.klijent_id
WHERE k.mjesto = 'Zagreb'
ORDER BY r.stanje DESC;
                
SELECT *
FROM tip_transakcije;


-- ==============================================================================
-- STRUKTURA PROJEKTA: RASPODJELA PO ČLANOVIMA TIMA (MEMBER 1 - MEMBER 5) PRIJEDLOZI
-- ==============================================================================

-- ==============================================================================
-- 👤 ČLAN TIMA: MEMBER 1
-- ==============================================================================

-- ==============================================================================
-- VIEW 1: NAKNADE I PROFIT BANAKA (ODRAĐENO)
-- POSLOVNI PROBLEM:
-- Financijski odjel mora pratiti koliko novca na ime naknada trošimo u kojoj 
-- pozadinskoj banci, odvojeno za transakcije kupnje i prodaje, ali samo za 
-- one banke gdje su troškovi prešli kritičnu granicu od 100 EUR.
--
-- LOGIKA I GRADIVO:
-- Da bih filtrirao banke koje imaju ukupne naknade veće od 100 eura, na kraj 
-- upita dodajem klauzulu HAVING, a ne WHERE. Razlog tome je logički redoslijed 
-- izvršavanja upita u bazi podataka (FROM -> WHERE -> GROUP BY -> HAVING -> SELECT). 
-- Budući da se WHERE izvršava prije grupiranja, on ne može filtrirati agregirane 
-- vrijednosti jer one u tom trenutku još nisu izračunate. HAVING se izvršava 
-- nakon što je baza odradila GROUP BY i izračunala SUM(t.naknada), što nam 
-- omogućuje točno filtriranje konačnog rezultata.
-- ==============================================================================

CREATE VIEW naknade_profit_banaka AS 
SELECT b.ime, SUM(t.naknada) AS ukupno, tt.tip
FROM banka AS b 
JOIN investicijski_racun AS r ON b.id = r.banka_id
JOIN transakcija AS t ON r.id = t.investicijski_racun_id
JOIN tip_transakcije AS tt ON t.tip_transakcije_id = tt.id
GROUP BY b.ime, tt.tip
HAVING SUM(t.naknada) > 100; 

SELECT * FROM naknade_profit_banaka;


-- ==============================================================================
-- VIEW 2: MJESEČNI SAŽETAK VOLUMENA TRGOVANJA
-- POSTAVKA ZADATKA / POSLOVNI PROBLEM:
-- Uprava platforme i odjel financija trebaju dugoročni strateški izvještaj o 
-- prometu. Potrebno je kreirati pogled koji će analizirati historiju transakcija 
-- te za svaki mjesec i godinu izvući ukupan broj izvršenih transakcija, 
-- ukupnu sumu okrenutog novca (kolicina * cijena), te prosječnu vrijednost 
-- pojedinačne transakcije. Izvještaj mora ignorisati mjesece u kojima je 
-- ukupni promet bio manji od 5.000 EUR.
--
-- LOGIKA I GRADIVO KOJE SE DOKAZUJE:
-- Ekstrakcija dijelova datuma (funkcije za mjesec i godinu), napredne agregacijske 
-- funkcije COUNT(), SUM(kolicina * cijena) i AVG(kolicina * cijena), grupisanje 
-- po više kriterija (GROUP BY godina, mjesec) te filtriranje agregiranih 
-- vrijednosti pomoću HAVING klauzule.
-- ==============================================================================
-- Ovdje Member 1 piše svoj: CREATE VIEW mjesecni_sazetak_trgovanja AS ...




-- ==============================================================================
-- UPIT 1: KLIJENTI S NATPROSJEČNIM VOLUMENOM TRGOVANJA
-- POSTAVKA ZADATKA / POSLOVNI PROBLEM:
-- Odjel za upravljanje VIP klijentima (Premium Wealth Management) zahtijeva popis 
-- ključnih korisnika. Potrebno je ispisati ime, prezime i e-mail klijenta, ukupan 
-- broj transakcija koje je izvršio, te ukupnu sumu novca (volumen = kolicina * cijena). 
-- U izvještaj smiju ući samo oni klijenti čiji je ukupni volumen trgovanja strogo 
-- veći od prosječne vrijednosti pojedinačne transakcije na razini cijele platforme.
--
-- LOGIKA I GRADIVO KOJE SE DOKAZUJE:
-- Spajanje minimalno 3 tablice (klijent, racun, transakcija), funkcije SUM() i COUNT(), 
-- GROUP BY po identifikatoru i podacima klijenta, te napredni ugniježđeni podupit 
-- unutar HAVING klauzule koji dinamički računa AVG(kolicina * cijena) na nivou cijele baze.
-- ==============================================================================
-- Ovdje Member 1 piše svoj: SELECT upit ...




-- ==============================================================================
-- UPIT 2: NAJPOPULARNIJA IMOVINA NA PLATFORMI
-- POSTAVKA ZADATKA / POSLOVNI PROBLEM:
-- Odjel nabavke i analize tržišta želi znati koje investicijske instrumente (dionice 
-- ili kriptovalute) klijenti najviše preferiraju. Potrebno je ispisati naziv imovine 
-- (npr. 'Apple' ili 'Bitcoin'), ukupan broj transakcija koje su vezane za tu imovinu, 
-- te ukupnu sumu novca (kolicina * cijena) koja je uložena u nju. Rezultat sortirati 
-- od najpopularnije prema najmanje popularnoj.
--
-- LOGIKA I GRADIVO KOJE SE DOKAZUJE:
-- Višestruki JOIN (spajanje tablica imovine i transakcija), primjena COUNT() i 
-- SUM(kolicina * cijena) funkcija, grupisanje po nazivu imovine (GROUP BY) 
-- i sortiranje rezultata od najvećeg prema najmanjem (ORDER BY ... DESC).
-- ==============================================================================
-- Ovdje Member 1 piše svoj: SELECT upit ...






-- ==============================================================================
-- 👤 ČLAN TIMA: MEMBER 2
-- ==============================================================================

-- ==============================================================================
-- VIEW 3: KATALOG IMOVINE S TRENUTNIM CIJENAMA (ODRAĐENO)
-- POSTAVKA ZADATKA / POSLOVNI PROBLEM:
-- Unutar aplikacije na ekranu "Katalog imovine" potrebno je klijentima prikazati 
-- popis svih dionica i kriptovaluta, ali isključivo s njihovom zadnjom (trenutnom) 
-- cijenom. Budući da tablica 'povijest_cijena_imovine' sadrži sve promjene cijena kroz 
-- vrijeme, cilj je kreirati pogled koji će za svaku imovinu izolirati samo onaj 
-- redak koji ima najnoviji 'datum'. Ako se cijena promijeni, pogled mora 
-- automatski prikazivati taj najnoviji zapis.
-- ==============================================================================

CREATE VIEW katalog_imovine_cijene AS 
SELECT i.ime, ti.tip, ROUND(pci.cijena,2) AS trenutna_cijena, pci.datum
FROM imovina AS i 
JOIN tip_imovine AS ti ON i.tip_imovine_id = ti.id
JOIN povijesna_cijena_imovine AS pci ON i.id = pci.imovina_id
WHERE pci.datum = (
    SELECT MAX(pci2.datum)
    FROM povijesna_cijena_imovine AS pci2
    WHERE pci2.imovina_id = pci.imovina_id
);

SELECT * FROM katalog_imovine_cijene;


-- ==============================================================================
-- VIEW 4: ANALIZA EKSTREMNIH STANJA INVESTICIJSKIH RAČUNA
-- POSTAVKA ZADATKA / POSLOVNI PROBLEM:
-- Služba za usklađenost s propisima (Compliance odjel) prati ponašanje računa 
-- radi prevencije anomalija. Potrebno je kreirati pogled koji za svaki račun u bazi 
-- prikazuje IBAN/broj računa, vrijednost njegove najmanje izvršene transakcije 
-- (kolicina * cijena), vrijednost najveće izvršene transakcije, te ukupnu sumu 
-- svih transakcija na tom računu. Pogled treba prikazati samo račune koji su ukupno 
-- okrenuli više od 1.000 EUR.
--
-- LOGIKA I GRADIVO KOJE SE DOKAZUJE:
-- Korištenje ekstremnih agregacijskih funkcija MIN() i MAX() u kombinaciji sa SUM(), 
-- izračun vrijednosti preko (kolicina * cijena), obavezno grupiranje preko GROUP BY 
-- i post-filtriranje kroz HAVING klauzulu.
-- ==============================================================================
-- Ovdje Member 2 piše svoj: CREATE VIEW analiza_ekstrema_racuna AS ...




-- ==============================================================================
-- UPIT 3: KLIJENTI BEZ IKAKVE IMOVINE (ODRAĐENO)
-- POSLOVNI PROBLEM:
-- Odjel marketinga priprema novu kampanju za aktivaciju korisnika. Trebaju popis 
-- svih klijenata (ime, prezime, e-mail) koji su otvorili račun u našoj aplikaciji, 
-- ali na njemu nemaju apsolutno nikakvu imovinu (nisu kupili niti jednu dionicu 
-- niti kriptovalutu). Žele im poslati poseban promo kod kako bi ih potaknuli 
-- na prvu investiciju.
--
-- LOGIKA I GRADIVO: 
-- Koristi se strukturirani podupit uz NOT IN kako bi se pronašla razlika između 
-- skupa svih klijenata i skupa klijenata koji imaju zapise u portfelju s količinom > 0.
-- ==============================================================================

SELECT k.ime, k.prezime, k.email
FROM klijent AS k
WHERE k.id NOT IN (
    SELECT ir.klijent_id
    FROM investicijski_racun AS ir 
    JOIN portfelj as p ON ir.id = p.investicijski_racun_id
    JOIN portfelj_imovina AS pi ON p.id = pi.portfelj_id
    WHERE pi.kolicina > 0
);


-- ==============================================================================
-- UPIT 4: BANKE S NATPROSJEČNIM POJEDINAČNIM PRIJENOSIMA
-- POSTAVKA ZADATKA / POSLOVNI PROBLEM:
-- Likvidnost platforme ovisi o partnerskim pozadinskim bankama preko kojih se 
-- poravnavaju transakcije. Odjel analitike želi popis svih banaka (naziv banke) 
-- kod kojih je prosječna vrijednost pojedinačne transakcije (kolicina * cijena) veća 
-- od općeg prosjeka svih transakcija pohranjenih u sustavu.
--
-- LOGIKA I GRADIVO KOJE SE DOKAZUJE:
-- Kompleksno spajanje tablica (banka, investicijski_racun, transakcija), računanje 
-- prosjeka preko funkcije AVG(kolicina * cijena), GROUP BY po nazivu banke, te 
-- ugniježđeni podupit unutar HAVING klauzule za usporedbu lokalnog prosjeka 
-- s globalnim prosjekom baze.
-- ==============================================================================
-- Ovdje Member 2 piše svoj: SELECT upit ...






-- ==============================================================================
-- 👤 ČLAN TIMA: MEMBER 3
-- ==============================================================================

-- ==============================================================================
-- VIEW 5: TRENUTNA VRIJEDNOST PORTFELJA KLIJENATA
-- POSTAVKA ZADATKA / POSLOVNI PROBLEM:
-- Na korisničkom profilu unutar aplikacije potrebno je klijentu u realnom vremenu 
-- prikazati ukupnu financijsku vrijednost njegove imovine. Potrebno je napraviti 
-- pogled koji spaja klijente i njihovu imovinu, uzima trenutnu količinu koju klijent 
-- posjeduje (iz portfelj_imovina) te je množi s najnovijom cijenom imovine, dajući 
-- ukupnu vrijednost portfelja za svakog klijenta (ime, prezime, ukupna_vrijednost).
--
-- LOGIKA I GRADIVO KOJE SE DOKAZUJE:
-- Robusni JOIN koji povezuje različite tablice relacijskog modela, izvođenje 
-- matematičkih operacija množenja atributa unutar agregacijske funkcije 
-- SUM(pi.kolicina * i.trenutna_cijena) te grupiranje podataka po klijentu.
-- ==============================================================================
-- Ovdje Member 3 piše svoj: CREATE VIEW trenutna_vrijednost_portfelja AS ...




-- ==============================================================================
-- VIEW 6: PROSJEČNI TRGOVANI IZNOS PO KLASI IMOVINE
-- POSTAVKA ZADATKA / POSLOVNI PROBLEM:
-- Sektor za makroanalizu tržišta želi pratiti trendove i usporediti ponašanje 
-- investitora u različitim klasama imovine. Potrebno je kreirati pogled koji će 
-- grupirati transakcije prema tipu imovine (Dionice naspram Kriptovaluta) te 
-- izračunati prosječnu financijsku vrijednost investicije (kolicina * cijena) 
-- za svaku klasu, kao i ukupan broj transakcija.
--
-- LOGIKA I GRADIVO KOJE SE DOKAZUJE:
-- Povezivanje entiteta preko više razina JOIN-a (tip_imovine, imovina, transakcija), 
-- primjena funkcija AVG(kolicina * cijena) i COUNT(), te GROUP BY po tekstualnom 
-- nazivu tipa imovine.
-- ==============================================================================
-- Ovdje Member 3 piše svoj: CREATE VIEW prosjeci_po_klasama AS ...




-- ==============================================================================
-- UPIT 5: SEGMENTACIJA TRANSAKCIJA PO RIZIČNOSTI / VELIČINI
-- POSTAVKA ZADATKA / POSLOVNI PROBLEM:
-- Odjel za upravljanje rizikom (Risk Management) treba izvještaj o svim obavljenim 
-- transakcijama u sustavu, ali s jasnom oznakom kategorije veličine transakcije. 
-- Žele da se svaka transakcija automatski svrsta u jednu od tri kategorije na 
-- temelju ukupne vrijednosti (kolicina * cijena):
--   * Vrijednost manja od 1.000 EUR -> 'Mala transakcija'
--   * Vrijednost između 1.000 EUR i 10.000 EUR -> 'Standardna transakcija'
--   * Vrijednost veća od 10.000 EUR -> 'Visokorizična / Velika transakcija'
--
-- LOGIKA I GRADIVO: 
-- Koristi se uvjetna logika CASE WHEN unutar SELECT liste za dinamičko 
-- kreiranje kategorija na temelju izračuna vrijednosti (kolicina * cijena).
-- ==============================================================================
-- Ovdje Member 3 piše svoj: SELECT upit s CASE WHEN strukturom ...




-- ==============================================================================
-- UPIT 6: DIVERSIFIKACIJA (KLIJENTI KOJI IMAJU I DIONICE I KRIPTOVALUTE)
-- POSTAVKA ZADATKA / POSLOVNI PROBLEM:
-- Investicijski savjetnici žele identificirati klijente koji su uspješno 
-- diversificirali svoj portfelj, odnosno posjeduju barem jednu dionicu i barem 
-- jednu kriptovalutu istovremeno. Ovim klijentima se nudi napredni modul analize.
--
-- LOGIKA I GRADIVO KOJE SE DOKAZUJE:
-- Napredna struktura podupita koja koristi operator EXISTS (ili skupovni INTERSECT) 
-- kako bi se provjerilo postojanje zapisa o posjedovanju različitih tipova imovine 
-- za istog klijenta, čime se demonstrira teorija presjeka skupova iz relacijske algebre.
-- ==============================================================================
-- Ovdje Member 3 piše svoj: SELECT upit ...






-- ==============================================================================
-- 👤 ČLAN TIMA: MEMBER 4
-- ==============================================================================

-- ==============================================================================
-- VIEW 7: GODIŠNJA STATISTIKA AKTIVNOSTI PARTNERSKIH BANAKA
-- POSTAVKA ZADATKA / POSLOVNI PROBLEM:
-- Odjel za odnose s partnerima (B2B Relations) pregovara o novim ugovorima o 
-- naknadama s bankama. Potrebno je kreirati pogled koji za svaku banku prikazuje 
-- njezin naziv, ukupan broj jedinstvenih investicijskih računa otvorenih kod nje, 
-- te sumu svih naknada (iz tablice transakcija) koje je ta banka obradila. U obzir 
-- dolaze samo banke koje su prikupile više od 100 EUR naknada.
--
-- LOGIKA I GRADIVO KOJE SE DOKAZUJE:
-- Spajanje tablica, upotreba ključne riječi DISTINCT unutar agregacijske funkcije 
-- COUNT(DISTINCT r.id) kako bi se izbjeglo duplo brojanje istih računa kroz 
-- transakcije, SUM(t.naknada) funkcija, GROUP BY i HAVING filtriranje.
-- ==============================================================================
-- Ovdje Member 4 piše svoj: CREATE VIEW statistika_partnerskih_banaka AS ...




-- ==============================================================================
-- VIEW 8: KLIJENTI S MINIMALNO TRI VELIKE INVESTICIJE
-- POSTAVKA ZADATKA / POSLOVNI PROBLEM:
-- Odjel za odnose s javnošću i marketing želi provesti anketu među "lojalnim teškim 
-- investitorima". Potrebno je kreirati pogled koji izbacuje ime, prezime i telefon 
-- klijenata koji su u povijesti aplikacije napravili minimalno 3 pojedinačne 
-- transakcije čija je financijska vrijednost (kolicina * cijena) bila veća od 2.000 EUR.
--
-- LOGIKA I GRADIVO KOJE SE DOKAZUJE:
-- Kombinacija WHERE klauzule (koja filtrira transakcije iznad 2.000 EUR prije 
-- grupiranja) i HAVING klauzule (koja nakon grupisanja provjerava uvjet 
-- COUNT(t.id) >= 3), uz standardni JOIN tablica.
-- ==============================================================================
-- Ovdje Member 4 piše svoj: CREATE VIEW klijenti_velike_investicije AS ...




-- ==============================================================================
-- UPIT 7: BANKE BEZ RIZIČNIH TRANSAKCIJA
-- POSTAVKA ZADATKA / POSLOVNI PROBLEM:
-- Sektor za kontrolu stabilnosti želi izdvojiti banke partneri koje se smatraju 
-- "sigurnima", odnosno one banke preko čijih računa nikada nije izvršena niti 
-- jedna pojedinačna transakcija s vrijednošću (kolicina * cijena) većom od 20.000 EUR.
--
-- LOGIKA I GRADIVO KOJE SE DOKAZUJE:
-- Demonstracija negacije i kontrole postojanja zapisa pomoću koreliranog podupita i 
-- operatora NOT EXISTS (alternativno NOT IN), povezujući vanjski upit nad bankama s 
-- unutrašnjim filterom nad transakcijama.
-- ==============================================================================
-- Ovdje Member 4 piše svoj: SELECT upit ...




-- ==============================================================================
-- UPIT 8: IMOVINA S NAJVEĆIM ISTORIJSKIM PADOM VRIJEDNOSTI
-- POSTAVKA ZADATKA / POSLOVNI PROBLEM:
-- Odjel za upravljanje kriznim situacijama analizira volatilnost instrumenata. 
-- Potrebno je pronaći imovinu kod koje je zabilježena najveća razlika između njezine 
-- povijesno najviše (maksimalne) i povijesno najniže (minimalne) cijene, kako bi 
-- se identificirao resurs s najvećim padom/rasponom cijene. Ispisati naziv i razliku.
--
-- LOGIKA I GRADIVO KOJE SE DOKAZUJE:
-- Primjena matematičke operacije oduzimanja nad dvije različite agregacijske funkcije 
-- unutar istog SELECT-a: (MAX(cijena) - MIN(cijena)) AS raspon_vrijednosti, uz 
-- GROUP BY po imovini i ORDER BY za sortiranje anomalije na vrh.
-- ==============================================================================
-- Ovdje Member 4 piše svoj: SELECT upit ...






-- ==============================================================================
-- 👤 ČLAN TIMA: MEMBER 5
-- ==============================================================================

-- ==============================================================================
-- VIEW 9: STRUKTURA PORTFELJA KORISNIKA (DIONICE VS. KRIPTOVALUTE)
-- POSTAVKA ZADATKA / POSLOVNI PROBLEM:
-- Služba za korisničku podršku (Helpdesk) treba brzi uvid u diverzifikaciju imovine 
-- klijenta kada on podnese upit. Potrebno je kreirati pogled koji za svakog klijenta 
-- (ime, prezime) ispisuje kategoriju imovine (Dionica / Kriptovaluta) te ukupnu 
-- količinu koju klijent posjeduje unutar te specifične kategorije.
--
-- LOGIKA I GRADIVO KOJE SE DOKAZUJE:
-- Kompleksno grupisanje podataka po više stupaca iz različitih tablica 
-- (GROUP BY klijent_id, tip_imovine) uz primjenu funkcije SUM(pi.kolicina) i 
-- višestruki JOIN entiteta.
-- ==============================================================================
-- Ovdje Member 5 piše svoj: CREATE VIEW struktura_portfelja_korisnika AS ...




-- ==============================================================================
-- VIEW 10: ANALIZA OPTEREĆENJA NAKNADAMA PO KLIJENTU
-- POSTAVKA ZADATKA / POSLOVNI PROBLEM:
-- Odjel za retenciju korisnika želi nagraditi klijente koji generišu najviše 
-- prihoda samoj platformi kroz naknade. Potrebno je napraviti pogled koji prikazuje 
-- klijenta, ukupnu sumu svih naknada koje je platio tokom trgovanja, te prosječnu 
-- naknadu po transakciji. U obzir dolaze klijenti s ukupnim naknadama iznad 50 EUR.
--
-- LOGIKA I GRADIVO KOJE SE DOKAZUJE:
-- Povezivanje klijenata s transakcijama kroz račune, istovremeno korištenje SUM(naknada) 
-- za ukupni trošak i AVG(naknada) za prosjek naknade, grupisanje po klijentu i HAVING filter.
-- ==============================================================================
-- Ovdje Member 5 piše svoj: CREATE VIEW analiza_naknada_klijenta AS ...




-- ==============================================================================
-- UPIT 9: PROFILIRANJE "DAY TRADERA" (VISOKA AKTIVNOST, PRAZAN PORTFELJ)
-- POSTAVKA ZADATKA / POSLOVNI PROBLEM:
-- Sistem treba detektovati specifičnu vrstu korisnika - špekulativne dnevne trgovce 
-- (Day Traderi). To su klijenti koji su izrazito aktivni u trgovanju (izvršili su 
-- više od 10 transakcija), ali je trenutno stanje količine imovine u njihovom 
-- portfelju jednako nuli (sve što kupe, brzo i rasprodaju).
--
-- LOGIKA I GRADIVO KOJE SE DOKAZUJE:
-- Složeni upit s višestrukim spajanjem tablica, upotrebom više različitih uvjeta 
-- unutar HAVING klauzule razdvojenih logičkim operatorom AND (npr. HAVING COUNT(t.id) > 10).
-- OPREZ (ZAMKA): Budući da klijent nema imovinu, možda uopće nema redove u tablici 
-- 'portfelj_imovina'. Zato je potrebno koristiti LEFT JOIN te provjeravati SUM uz IFNULL 
-- ili COALESCE, npr: AND SUM(IFNULL(pi.kolicina, 0)) = 0.
-- ==============================================================================
-- Ovdje Member 5 piše svoj: SELECT upit ...




-- ==============================================================================
-- UPIT 10: KLIJENT S APSOLUTNO NAJVIŠIM POJEDINAČNIM ULAGANJEM
-- POSTAVKA ZADATKA / POSLOVNI PROBLEM:
-- Uprava kompanije priprema godišnju nagradu za "Transakciju godine". Potrebno je 
-- izvući ime, prezime i e-mail klijenta, te točnu vrijednost transakcije koja drži 
-- apsolutni rekord kao financijski najveća pojedinačna transakcija ikada izvršena.
--
-- LOGIKA I GRADIVO KOJE SE DOKAZUJE:
-- Upotreba ugniježđenog podupita u WHERE klauzuli. Glavni upit traži detalje klijenta 
-- i vrijednost (kolicina * cijena) za uvjet gdje je ta vrijednost jednaka maksimalnoj 
-- vrijednosti koju vraća podupit: SELECT MAX(kolicina * cijena) FROM transakcija.
-- time se izbjegava hardkodiranje fiksnih iznosa.
-- ==============================================================================
-- Ovdje Member 5 piše svoj: SELECT upit ...