# Sustav-za-upravljanje-investicijskim-bankarstvom---Tim-4

https://gist.github.com/bluka1/a4a593316491c9c9202ec595ba8b58c9

## Opis projekta

Sustav modelira proces investicijskog bankarstva za građane, omogućujući upravljanje korisnicima, njihovim investicijskim računima te ulaganjima u različite financijske instrumente.

Proces započinje registracijom klijenta u sustav, pri čemu se pohranjuju osnovni osobni podaci. Klijent zatim može otvoriti jedan ili više investicijskih računa u odabranoj banci. Svaki investicijski račun pripada točno jednom klijentu i jednoj banci.

Unutar investicijskog računa klijent može kreirati jedan ili više portfelja koji predstavljaju skupove ulaganja. Svaki portfelj sadrži različite vrste imovine, poput dionica, fondova, obveznica, kriptovaluta i slično. Odnos između portfelja i imovine je višestruk (M:N), što znači da jedan portfelj može sadržavati više vrsta imovine, a ista imovina može biti dio više portfelja različitih klijenata.

Sustav omogućuje evidentiranje uplata i isplata novčanih sredstava na investicijski račun, čime se prati stanje raspoloživih sredstava za ulaganje.

Kupnja i prodaja imovine evidentira se kroz transakcije koje su povezane s investicijskim računom i konkretnom imovinom. Svaka transakcija ima definirani tip (npr. kupnja ili prodaja), količinu i cijenu, čime se omogućuje praćenje aktivnosti ulaganja.

Za svaku imovinu sustav bilježi povijest cijena kroz vrijeme, što omogućuje analizu kretanja vrijednosti i izračun prinosa. Također, za određene vrste imovine evidentiraju se dividende koje predstavljaju dodatni prihod za klijenta.

Klasifikacija imovine i transakcija ostvarena je putem zasebnih pomoćnih (lookup) tablica, čime se osigurava konzistentnost i proširivost sustava.

Na taj način sustav omogućuje cjelovito praćenje investicijskog ciklusa - od unosa klijenta i upravljanja računima, preko ulaganja i transakcija, do analize tržišnih podataka i ostvarivanja prihoda.

## EER dijagram

- MySQL workbench file dostupan [ovdje](./eer-dijagram/eer-dijagram.mwb)
- PDF file dostupan [ovdje](./eer-dijagram/eer-dijagram.pdf)
- .png file dostupan [ovdje](./eer-dijagram/eer-dijagram.png)
- SQL skripta generirana od strane MySQL workbencha na temelju EER dijagrama dostupna [ovdje](./eer-dijagram/eer-dijagram.sql)
