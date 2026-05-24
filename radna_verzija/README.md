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

#### 3. OPIS ER DIJAGRAMA

1. **klijent** i **investicijski_racun** su u vezi tipa **one-to-many (1:M)**. Jedan klijent može posjedovati više investicijskih računa, dok pojedini investicijski račun pripada točno jednom klijentu. Veza je sa strane investicijskog računa **potpuno uključena (totalna participacija)**, što znači da je pri unosu računa obavezno definirati pripadajućeg klijenta.<br>
2. **banka** i **investicijski_racun** su u vezi tipa **one-to-many (1:M)**. Jedna banka može upravljati većim brojem investicijskih računa, dok pojedini investicijski račun pripada točno jednoj banci. Veza je sa strane investicijskog računa **potpuno uključena** jer svaki račun mora biti otvoren unutar jedne konkretne banke.<br>
3. **investicijski_racun** i **uplata_isplata** su u vezi tipa **one-to-many (1:M)**. Na jednom investicijskom računu može se izvršiti više uplata ili isplata, dok se svaka pojedinačna uplata ili isplata odnosi na točno jedan investicijski račun. Svaki novčani promet mora biti evidentiran na točno određenom računu.<br>
4. **investicijski_racun** i **portfelj** su u vezi tipa **one-to-many (1:M)**. Jedan investicijski račun može sadržavati više portfelja, dok pojedini portfelj pripada točno jednom investicijskom računu. Veza je sa strane portfelja **potpuno uključena** jer je portfelj nužno vezan za krovni investicijski račun.<br>
5. **portfelj** i **imovina** su u vezi tipa **many-to-many (M:N)**. Jedan portfelj može sadržavati više različitih imovina, a ista imovina može biti dio više različitih portfelja. Budući da je riječ o **many-to-many** vezi, količina imovine unutar pojedinog portfelja modelirana je kao **opisni atribut** ove veze.<br>
6. **tip_imovine** i **imovina** su u vezi tipa **one-to-many (1:M)**. Jedan tip imovine kategorizira više različitih imovina, dok pojedina imovina pripada točno jednom tipu imovine. Veza je sa strane imovine **potpuno uključena** jer svaka imovina mora biti klasificirana pod jedan definiran tip.<br>
7. **imovina** i **povijesna_cijena_imovine** su u **identifikacijskoj vezi** tipa **one-to-many (1:M)**. Povijesna cijena je **slabi skup entiteta** čije postojanje egzistencijalno ovisi o jakom skupu entiteta imovina, a njezin parcijalni ključ (**diskriminator**) je predstavljen atributom datum. Slabi entitet podrazumijeva i potpunu uključenost.<br>
8. **imovina** i **dividenda** su u **identifikacijskoj vezi** tipa **one-to-many (1:M)**. Dividenda je **slabi skup entiteta** čije postojanje egzistencijalno ovisi o jakom skupu entiteta imovina, a njezin parcijalni ključ (**diskriminator**) je predstavljen datumom.<br>
9. **tip_transakcije** i **transakcija** su u vezi tipa **one-to-many (1:M)**. Jedan tip transakcije definira vrstu za više različitih transakcija, dok pojedina transakcija ima točno jedan definiran tip. Veza je sa strane transakcije **potpuno uključena** jer svaka transakcija mora imati određenu vrstu (npr. kupovina ili prodaja).<br>
10. **imovina** i **transakcija** su u vezi tipa **one-to-many (1:M)**. Nad jednom imovinom može se izvršiti više različitih transakcija, dok se svaka pojedinačna transakcija odnosi na točno jednu imovinu. Veza je sa strane transakcije **potpuno uključena (totalna participacija)** jer se transakcija mora provesti nad konkretnom imovinom.<br>
11. **investicijski_racun** i **transakcija** su u vezi tipa **one-to-many (1:M)**. Na jednom investicijskom računu može se izvršiti više transakcija, dok se svaka pojedinačna transakcija veže za točno jedan investicijski račun. Veza je sa strane transakcije **potpuno uključena** jer svaka transakcija mora teretiti ili odobravati točno određeni investicijski račun.<br>

---

#### 4. RELACIJSKI MODEL (sheme)

U fazi relacijskog modeliranja uvodimo surogatne ključeve za sve entitete radi optimizacije performansi i lakše implementacije u SQL-u. 
*(Napomena: **Podebljani** atributi su primarni ključevi, a *kosi* atributi su strani ključevi).*

* **klijent** (**klijent_id**, ime, prezime, OIB, email, telefon, ulica_i_kucni_broj, postanski_broj, mjesto)
* **banka** (**banka_id**, ime)
* **investicijski_racun** (**investicijski_racun_id**, *klijent_id*, *banka_id*, broj_racuna, stanje, datum_otvaranja)
* **portfelj** (**portfelj_id**, *investicijski_racun_id*, ime, datum_otvaranja)
* **uplata_isplata** (**uplata_isplata_id**, *investicijski_racun_id*, broj_transakcije, iznos, datum, vrsta_prometa)
* **tip_imovine** (**tip_imovine_id**, tip)
* **imovina** (**imovina_id**, ime, trenutna_cijena, *tip_imovine_id*)
* **tip_transakcije** (**tip_transakcije_id**, tip)
* **transakcija** (**transakcija_id**, *imovina_id*, *tip_transakcije_id*, broj_naloga, kolicina, cijena, naknada, datum)
* **portfelj_imovina** (**portfelj_imovina_id**, *portfelj_id*, *imovina_id*, kolicina)
* **povijesna_cijena_imovine** (**povijesna_cijena_imovine_id**, *imovina_id*, cijena, datum)
* **dividenda** (**dividenda_id**, *imovina_id*, datum, iznos)

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
	mjesto VARCHAR(45) NOT NULL,
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

Atribut **mjesto** mora biti unesen, ali ne mora biti UNIQUE jer se odnosi i na sela (a moguće je da se neka isto zovu).

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


Ova tablica vodi evidenciju o svim novčanim tokovima na investicijskom računu. Iako je na konceptualnom ERD dijagramu kao primarni ključ identificiran prirodni poslovni ključ **broj_transakcije** (budući da bankarski sustavi koriste jedinstvene interne brojeve transakcija), u relacijskom modelu i SQL kodu uveden je surogatni ključ id radi optimizacije performansi baze i lakšeg mapiranja stranih ključeva.

Prirodni ključ **broj_transakcije** je u kodu zadržan kao ključ kandidat uz ograničenje **UNIQUE**, čime je osigurano da se unutar sustava ne može pojaviti dupli unos iste bankovne transakcije. Atribut **iznos** odnosi se na količinu novca, što je određeno atributom **vrsta_prometa** koji je tip ENUM. 

Ograničenje UNSIGNED kod iznosa osigurava da ne mogu postojati negativne vrijednosti. Atribut **datum** (tip DATETIME) precizno bilježi točan trenutak izvršenja prometa.


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
**broj_naloga** ima istu funkciju kao i **broj_transakcije** iz tablice "uplata_isplata". Na konceptualnom ERD-u je to primarni ključ, no u SQL-u smo uveli surogat **id** kao primarni ključ baze, dok je **broj_naloga** ostao kao ključ kandidat uz **UNIQUE** ograničenje koji služi korisničkoj strani za razlikovanje pojedinačnih transakcija.

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
	FOREIGN KEY (imovina_id) REFERENCES imovina (id) ON DELETE CASCADE,
	UNIQUE (imovina_id, datum)
);
```

Na konceptualnoj razini (ERD), povijesna_cijena_imovine je slabi skup entiteta kojemu je **datum** parcijalni ključ (diskriminator). Međutim, prilikom prevođenja u relacijski model i SQL, uveli smo surogatni ključ **id** kao primarni ključ radi lakše implementacije. Međutim, nad kombinacijom atributa imovina_id i datum uveli smo UNIQUE ograničenje, čime se u praksi sprječava višestruki unos različitih cijena za istu imovinu u istom vremenskom trenutku.


##### 6.12 TABLICA dividenda

``` sql
CREATE TABLE dividenda(
	id INT PRIMARY KEY AUTO_INCREMENT,
	imovina_id INT NOT NULL,
	datum DATETIME NOT NULL,
	iznos DECIMAL(38,18) UNSIGNED NOT NULL,
	FOREIGN KEY (imovina_id) REFERENCES imovina(id) ON DELETE CASCADE,
	UNIQUE (imovina_id, datum)
);
```

Ova tablica bilježi iznos isplaćenih dividendi za određenu imovinu na zadani **datum**.
Primijenjena je identična logika kao kod povijesnih cijena: uz surogatni **id**, ograničenje UNIQUE (imovina_id, datum) definira tu kombinaciju kao ključ kandidat i sprječava dvostruki unos isplate dividende za istu imovinu u istom trenutku.
