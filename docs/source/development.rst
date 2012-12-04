Sistemos vystymas
=================

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
