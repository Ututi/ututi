Sistemos vystymas
=================

Įprastos operacijos
-------------------

Makefile guli dažniausiai atliekamos operacijos, tokios kaip paleisti
testus ar paleisti development serverį.

Development serverio paleidimas
-------------------------------

Development serveris paleidžiamas komanda::

  make run

Tai automatiškai paleis duomenų bazę, jei ji dar nepaleista.

Atsarginės duomenų kopijos naudojimas vystant sistemą
-----------------------------------------------------

Jei parsisiuntėte atsarginę duomenų bazės kopiją komanda::

  make download_backup

Galite ją importuoti į development duomenų bazę paleisdami::

  make import_backup

Atsarginė duomenų bazės kopija siunčiama be failų kurie įkelti į
dalykus, tam, kad taupyti disko ir tinklo resursus.

Išvalyti duomenų bazę ir atstatyti ją į tuščią ututi duomenų bazę
galite paleisdami komandą::

  make reset_devdb

Vertimai
--------

XXX

Duomenų modelio migracija
-------------------------

Pirmiausia reikia padaryti norimus pakeitimus ``model/defaults.sql`` faile.

Įsitikinkite, kad turite naujausią duomenų modelio kopiją padarytą iš
atsarginės kopijos (komanda `make download_backup` ir `make import_backup`).

Tada paleiskite::

  cd src/ututi/migration
  ./new_version.py migracijos_skripto_pavadinimas

Jeigu prieš tai norite pasižiūrėti, kaip atrodys pakeitimai, paleiskite
`make schema_diff`.

Įgyvendinti naujus pakeitimus ant lokalios duomeų kopijos galite paleidę
komandą `make migrate`.
