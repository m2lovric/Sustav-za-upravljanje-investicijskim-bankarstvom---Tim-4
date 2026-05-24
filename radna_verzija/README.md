# DOKUMENTACIJA ZA PROJEKTNI ZADATAK "SUSTAV ZA UPRAVLJANJE INVESTICIJSKIM BANKARSTVOM"

## TIM 4

### Studenti: Luka Batarelo, Adrijan Drašćić, Vilibald Kovač, Matteo Lovrić, Benjamin Mihoci


#### 1. OPIS PROJEKTA

Sustav modelira proces investicijskog bankarstva za građane, omogućujući upravljanje korisnicima, njihovim investicijskim računima te ulaganjima u različite financijske instrumente.

Proces započinje registracijom klijenta u sustav, pri čemu se pohranjuju osnovni osobni podaci. Klijent zatim može otvoriti jedan ili više investicijskih računa u odabranoj banci. Svaki investicijski račun pripada točno jednom klijentu i jednoj banci.

Unutar investicijskog računa klijent može kreirati jedan ili više portfelja koji predstavljaju skupove ulaganja. Svaki portfelj sadrži različite vrste imovine, poput dionica, fondova, obveznica, kriptovaluta i slično. Odnos između portfelja i imovine je višestruk (M:N), što znači da jedan portfelj može sadržavati više vrsta imovine, a ista imovina može biti dio više portfelja različitih klijenata.

Sustav omogućuje evidentiranje uplata i isplata novčanih sredstava na investicijski račun, čime se prati stanje raspoloživih sredstava za ulaganje.

Kupnja i prodaja imovine evidentira se kroz transakcije koje su povezane s investicijskim računom i konkretnom imovinom. Svaka transakcija ima definirani tip (npr. kupnja ili prodaja), količinu i cijenu, čime se omogućuje praćenje aktivnosti ulaganja.

Za svaku imovinu sustav bilježi povijest cijena kroz vrijeme, što omogućuje analizu kretanja vrijednosti i izračun prinosa. Također, za određene vrste imovine evidentiraju se dividende koje predstavljaju dodatni prihod za klijenta.

Klasifikacija imovine i transakcija ostvarena je putem zasebnih pomoćnih (lookup) tablica, čime se osigurava konzistentnost i proširivost sustava.

Na taj način sustav omogućuje cjelovito praćenje investicijskog ciklusa - od unosa klijenta i upravljanja računima, preko ulaganja i transakcija, do analize tržišnih podataka i ostvarivanja prihoda.


#### 2. ER dijagram:
![ERD](radna_verzija_ER.png)


#### 3. OPIS ER DIJAGRAMA:

1) Klijent posjeduje investicijski račun (one to many, klijent može imati više investicijski računa, ali svaki investicijski račun pripada samo jednom klijentu)

2) Banka upravlja investicijskim računom (one to many, banka može upravljati većim brojem računa, ali račun pripad samo jednoj banci)

3) Skup entiteta uplata_isplata evidentira uplate i isplate na određenom investicijskom računom (one to many, investicijski račun može imati više uplata koje se odnose na njega, ali jedna uplata ili isplata se odnosi isključivo na jedan račun)

4) Portfelj pripada investicijskom računu (one to many, račun može imati više portfelja, ali portfelj se odnosi samo na jedan račun)

5) Portfelj sadrži imovinu (many to many, portfelj može sadržavati više imovina, koje mogu sudjelovati u više portfelja) [budući da je riječ o many to many vezi, količina imovine je označena kao opisni atribut te ovdje nastaje nova relacija]

6) Tip imovine kategorizira pojedinu imovinu (one to many, jedan tip se odnosi na više imovina, ali imovina ima samo jedan tip)

7) Povijesna cijena bilježi kretanje cijena imovine kroz vrijeme (one to many, jedna imovina ima više različitih cijena, ali svaka cijena se odnosi na samo jednu imovinu) Također, ovo je slabi entitet, a diskriminator je predstavljen datumom

8) Dividenda se isplaćuje za pojedinu imovinu (one to many, jedna imovina može imati više dividendi, ali dividende isplaćuju za samo jednu imovinu) Također, ovo je slab entitet (označen dvostrukim rombom), a diskriminator je predstavljen "brojem_isplate"

9) Tip transkacije definira vrstu transakcije (one to many, tip se može odnositi na više transakcija, ali transkacija ima samo jedan tip)

10) Transakcija se izvodi s imovinama (one to many, s jednom imovinom su moguće različite transkacije, ali jedna transkacija se odnosi na samo jednu imovinu)

11) Transkacija bilježi i na koji se investicijski račun odnosi (one to many)


#### 4. RELACIJSKI MODEL (sheme)



#### 5. EER

![EER](radna_verzija_EER.png)


#### 6. TABLICE

**VAŽNA NAPOMENA**: U sljedećem dijelu se objašnjavaju tablice naše baze. Pojedine stvari će se radi izbjegavanja nepotrebnog gomilanja teksta objasniti samo tamo gdje se prvi put pojavljuju. Drugim riječima: ako smo jednom pojasnili da ograničenje NOT NULL onemogućava unos redaka bez određenog atributa, to vrijedi svugdje gdje se to koristi. Jednako tako, **id** je u svakoj tablici primaran ključ (surogat) te se ni to neće posebno isticati u svakoj tablici.

##### 6.1 TABLICA klijent

``` sql
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
```

Tablica klijent služi za vođenje evidencije o klijentima sustava.

Atribut **id** je PRIMARY KEY tipa INT s obzirom na to da je riječ o brojčanoj vrijednosti. Budući da je riječ o primarnom ključu UNIQUE i NOT NULL nije potrebno navoditi. AUTO_INCREMENT služi automatskom dodavanju jedinstvene brojčane vrijednosti prilikom unošenja novog retka u tablicu. 

Atributi **ime** i **prezime** su tipa VARCHAR te ne očekujemo da će biti duži od 45 znakova. Ograničenje NOT NULL služi obveznom unosu tih podataka.

Atribut **OIB** osim što mora biti unesen (NOT NULL), mora biti i jedinstven (UNIQUE). Također, mora sadržavati točno 11 brojčanih znakova, što je zajamčeno CHECK-om i regularnim izrazima. Korištenje tipa INT ne bi imalo smisla zbog mogućih nula na početku broja. Također, OIB je ključ kandidat.

Atributi **email** i **telefon** također moraju biti uneseni i biti jedinstveni. VARCHAR se koristi za telefon iz istog razloga kao i za OIB (vodeće nule), ali i zbog mogućnosti upisivanja znakova poput '+' i '-'.

Atribut **ulica_i_kucni_broj** ne mora biti jedinstven (zbog mogućnosti da dva klijenta žive na istoj adresi) dok za **postanski_broj** CHECK-om ponovo jamčimo da će se raditi o točno pet znamenki.

##### 6.2. TABLICA banka

``` sql
CREATE TABLE banka(
	id INT PRIMARY KEY AUTO_INCREMENT,
	ime VARCHAR(255) NOT NULL UNIQUE
);
```
Primarni ključ predstavljen je atributom **id**, a **ime** označava službeni naziv institucije. Budući da je ono jedinstveno, predstavlja ključ-kandidat.

##### 6.3 TABLICA investicijski_racun

``` sql

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
```

**broj_racuna** se ovdje odnosi na IBAN, a CHECK-om i REGEX-om provjeravamo da počinje dvama slovima HR, nakon kojih slijedi 19 numeričkih znakova.

**stanje** označava dostupna sredstva na pojedinom računu, a koristi tip podatka DECIMAL (koji je fixed point čime se izbjegavaju nepreciznosti floating pointa koji nije uputno koristiti za novac) s 38 mogućih znamenki prije i 12 znamenki iza decimalne točke. [Budući da se naš hipotetski sustav odvija u Hrvatskoj i služi hrvatskim klijentima i bankama, pretpostavlja se da je riječ o eurima]

**datum_otvaranja** je tipa DATE, a predstavlja datum stvaranja određenog investicijskog računa.

Strani ključevi **klijent_id** i **banka_id**, označeni ključnom riječi FOREIGN KEY, povezuju tablicu s tablicama "klijent" i "banka" preko tamošnjih atributa **id** što je određeno ključnom riječi REFERENCES.

ON DELETE CASCADE kod stranog ključa **klijent_id** jamči da će se prilikom brisanja pojedinog retka iz tablice "klijent", obrisati i odgovarajući retci u ovoj tablici.

ON DELETE RESTRICT kod stranog ključa **banka_id** pak će spriječiti brisanje retka iz tablice "banka" ako još uvijek postoje retci u ovoj tablici povezani s njima, odnosno ako još uvijek postoje računi kojima ta banka upravlja. ON DELETE RESTRICT je također defaultno ponašanje.

##### 6.4 TABLICA portfelj

``` sql
CREATE TABLE portfelj(
	id INT PRIMARY KEY AUTO_INCREMENT,
	investicijski_racun_id INT NOT NULL,
	ime VARCHAR(100) NOT NULL,
	datum_otvaranja DATETIME NOT NULL,
	FOREIGN KEY (investicijski_racun_id) REFERENCES investicijski_racun (id) ON DELETE CASCADE,
	UNIQUE (investicijski_racun_id, ime) 
);
```

**ime** portfelja mora biti uneseno. Ne mora biti jedinstveno samo po sebi, ali mora biti jedinstveno unutar jednog investicijskog računa, što je zajamčeno ograničenjem UNIQUE (investicijski_racun_id, ime), pri čemu je **investicijski_racun_id** strani ključ koji tablicu povezuje s tablicom "investicijski_racun".

Ponovo, ON DELETE CASCADE će obrisati portfelj ako se obrisao investicijski račun kojemu pripada.

##### 6.5 TABLICA uplata_isplata

``` sql
CREATE TABLE uplata_isplata(
	id INT PRIMARY KEY AUTO_INCREMENT,
	investicijski_racun_id INT NOT NULL,
	broj_transakcije VARCHAR(45) NOT NULL UNIQUE,
	iznos DECIMAL(38,12) UNSIGNED NOT NULL,
	datum DATETIME NOT NULL,
	vrsta_prometa ENUM("uplata", "isplata") NOT NULL,
	FOREIGN KEY (investicijski_racun_id) REFERENCES investicijski_racun (id) ON DELETE CASCADE
);
```

**broj_transkacije** je ovdje ključ kandidat i služi prije svega korisničkoj strani (dok se sama baza i dalje oslanja na surogat ključ **id**)

**iznos** se odnosi na količinu novca koja se uplaćuje ili isplaćuje (što je određeno atributom **vrsta_prometa* koji je tip ENUM)

**datum** zapravo predstavlja datum i vrijeme određene transakcije tipom DATETIME


##### 6.6. TABLICA tip_imovine

``` sql
CREATE TABLE tip_imovine(
	id INT PRIMARY KEY AUTO_INCREMENT,
	tip VARCHAR(45) NOT NULL UNIQUE
);
```

Atribut **tip** označava vrstu određene imovine te je ključ kandidat s obzirom na to da je jedinstven.

##### 6.7 TABLICA imovina

``` sql
CREATE TABLE imovina(
	id INT PRIMARY KEY AUTO_INCREMENT,
	ime VARCHAR(45) NOT NULL UNIQUE,
	tip_imovine_id INT NOT NULL,
	trenutna_cijena DECIMAL(38,18) UNSIGNED NOT NULL,
	FOREIGN KEY (tip_imovine_id) REFERENCES tip_imovine(id) ON DELETE RESTRICT
);
```
**ime** predstavlja jedinstveni naziv neke imovine, a **trenutna_cijena** njezinu sadašnju cijenu. Kako ona nikada ne može biti manja od 0, koristi se ograničenje UNSIGNED.

Također, **tip_imovine_id** predstavlja strani ključ iz tablice tip_imovine, odakle ga nije moguće obrisati dokle god postoji poveznica s njim u ovoj tablici.

##### 6.8 TABLICA tip_transakcije
``` sql
CREATE TABLE tip_transakcije(
	id INT PRIMARY KEY AUTO_INCREMENT,
	tip VARCHAR(45) NOT NULL UNIQUE
);
```
**tip** je ključ kandidat, a označava jedinstvenu vrstu transakcije poput "kupovina" ili "prodaja".

##### 6.9 TABLICA transakcija

``` sql
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
```

**broj_naloga** ima istu funkciju kao i **broj_transkacije** iz tablice "uplata_isplata", odnosno riječ je o ključu kandidatu koji služi korisničkoj strani za razliku od surogata **id**.

**kolicina** se odnosi na količinu imovine koja se kupuje ili prodaje. UNSIGNED jer ne može biti negativna vrijednost, a isto vrijedi i za **cijenu** (određene imovine) i **naknadu**.

**naknada** se odnosi na eventualnu cijenu same transakcije koja može biti NULL ako naknade nema.

##### 6.10 TABLICA portfelj_imovina

``` sql
CREATE TABLE portfelj_imovina(
	id INT PRIMARY KEY AUTO_INCREMENT,
	portfelj_id INT NOT NULL,
	imovina_id INT NOT NULL,
	kolicina DECIMAL(38,18) UNSIGNED NOT NULL,
	UNIQUE (portfelj_id, imovina_id),
	FOREIGN KEY (portfelj_id) REFERENCES portfelj (id) ON DELETE CASCADE,
	FOREIGN KEY (imovina_id) REFERENCES imovina (id) ON DELETE RESTRICT
);
```

Ova tablica vodi evidenciju o tome koliko koji portfelj ima koje imovine, što se postiže stranim ključevima **portfelj_id** i **imovina_id** te atributom **kolicina**.
Pritom se ne može ista imovina više puta pojaviti u istom portfelju, što je zajamčeno ograničenjem UNIQUE (portfelj_id, imovina_id).

##### 6.11 TABLICA povijesna_cijena_imovine 
``` sql
CREATE TABLE povijesna_cijena_imovine(
	id INT PRIMARY KEY AUTO_INCREMENT,
	imovina_id INT NOT NULL,
	cijena DECIMAL(38,18) UNSIGNED NOT NULL,
	datum DATETIME NOT NULL,
	FOREIGN KEY (imovina_id) REFERENCES imovina (id) ON DELETE CASCADE
);
```

U ovoj tablici se vode povijesne cijene imovine na određeni **datum**, no ostavljen je tip DATETIME u slučaju da se želi početi gledati i kretanje cijena kroz sate ili minute.

##### 6.12 TABLICA dividenda

``` sql
CREATE TABLE dividenda(
	id INT PRIMARY KEY AUTO_INCREMENT,
	imovina_id INT NOT NULL,
	datum DATETIME NOT NULL,
	iznos DECIMAL(38,18) UNSIGNED NOT NULL,
	FOREIGN KEY (imovina_id) REFERENCES imovina(id) ON DELETE CASCADE
);
```

U ovoj tablici se vodi evidencija o isplaćenim dividendama za određene vrste imovine, što je predstavljeno atributom **iznos** koji se isplaćuje na određeni **datum**.

