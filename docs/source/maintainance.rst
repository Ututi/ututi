Sistemos Priežiūra
==================

Naujo Vututi serverio konfigūracija ir paleidimas
-------------------------------------------------

fabfile.py įkelti ssh viešus raktus vartotojams, kurie turi galėti
jungtis prie serverio.

Pvz.::

  ignas = ('ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEA1k5A4ViR29O3XEride/ZIO52LNwEPVyTh'
           'v8Rk9pweyMrlPoyg43TG+slndvy4Vju73tnd1fGWDrmAast9WVLm5Pd5GaWCtP4WU8I24'
           'nsohf7Gz0bo84SMp7ROFAmcnPuq2j5/39KZzbDW810fVCpxD5+qsDTusTcCA4yrROxjUU'
           '= ignas@pow.lt')
  ...


  servers = [ubuntu.Server(host='vututi.mif.vu.lt',
                           name='vututi',
                           settings={'identities': [('', ignas),
                                                    ('ututi', hudson),
                                                    ('git', hudson)]},
  ...

Jei nurodoma pora '<vartotojo vardas>': raktas, nurodytas raktas įdiegiamas tik nurodytam vartotojui.
Jei vartotojo vardas paliekamas tuščias, raktas įdiegiamas visiems vartotojams.

Pastaba: įsitinkite, kad root vartotojui įdiegtas jūsų SSH raktas.

Tuomet paleisti komandą::

  bin/fab vututi_prepare

Sistema automatiškai įdiegs visus reikalingus paketus.
Pastaba: į pranešimą kad PostgreSQL 8.4 paketas pasenęs nekreipti dėmesio.

Toliau rekia sukurti vartotoją ir įdiegti SSH raktus::

  bin/fab ensure_user:vututi
  bin/fab ssh_update_identities

Po to sukonfigūruoti pačią sistemą::

  bin/fab vututi_vututi_db_setup

Kodo kataloge::

  make package_release

Ši komanda sugeneruos failą::

  ututi<timestamp>.tar.gz

Tuomet reikia įvykdyti komandą (po dvitaškio - ankstesnės komandos sugeneruotas failas)::

  bin/fab vututi_vututi_setup:ututi<timestamp>.tar

Pirminių duomenų įkėlimas į sistemą::

  bin/fab vututi_vututi_import_inital_backup:vututi_dbdump

Serverio paleidimas::

  bin/fab vututi_vututi_start

Atnaujintos versijos diegimas
-----------------------------

Kodo kataloge(lokaliai)::

  make package_release

Ši komanda sugeneruos failą::

  ututi<timestamp>.tar.gz

  bin/fab vututi_vututi_upload_release:ututi<timestamp>.tar.gz
  bin/fab vututi_vututi_build
  bin/fab vututi_vututi_release

Įprastos operacijos
-------------------

Makefile guli dažniausiai atliekamos operacijos, tokios kaip paleisti
testus ar paleisti serverį.
