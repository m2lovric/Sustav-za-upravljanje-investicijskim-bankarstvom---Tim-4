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

