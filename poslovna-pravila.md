# Poslovna pravila

1. Jedan klijent može imati više investicijskih računa.

2. Jedan investicijski račun pripada točno jednom klijentu.

3. Jedna banka može upravljati s više investicijskih računa.

4. Jedan investicijski račun pripada točno jednoj banci.

5. Jedan investicijski račun može sadržavati više portfelja.

6. Jedan portfelj pripada točno jednom investicijskom računu.

7. Jedan portfelj može sadržavati više vrsta imovine.

8. Jedna imovina može se nalaziti u više portfelja.

9. Jedna transakcija odnosi se na jednu imovinu.

10. Jedna imovina može imati više povijesnih cijena.

11. Jedan klijent može imati samo jedan zapis osobnih podataka.

12. Jedan zapis osobnih podataka pripada točno jednom klijentu.

## Kardinalnosti veza

- klijent → investicijski_racun : 1:N
- banka → investicijski_racun : 1:N
- investicijski_racun → portfelj : 1:N
- portfelj ↔ imovina : M:N
- tip_imovine → imovina : 1:N
- tip_transakcije → transakcija : 1:N
- investicijski_racun → transakcija : 1:N
- imovina → dividenda : 1:N
- imovina → povijesna_cijena : 1:N
- klijent → osobni_podaci : 1:1