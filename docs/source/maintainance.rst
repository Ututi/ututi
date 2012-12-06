Sistemos Priežiūra
==================

Čia apžvelgiamos pagrindinės serverio administravimo komandos ir
operacijos.

Fabric
------

Serverio konfigūracija generuojama iš duomenų esančių ``fabfile.py``,
administravimui naudojamas įrankis `Fabric`. Visų komandų sąrašą
galite pamatyti paleisdamin komandą::

  bin/fab --list

Ututi serverio ir duomenų bazės valdymo kodas laikomas
`libs/nous_deploy/`, konfigūracijos failų šablonai laikomi
kataloguose::

  libs/nous_deploy/src/nous_deploy/ubuntu/config_templates
  libs/nous_deploy/src/nous_deploy/ututi/config_templates
  libs/nous_deploy/src/nous_deploy/psql/config_templates

Pakeitus konfigūracijos parametrus galima atnaujinti konfigūraciją
paleidžiant pvz.::

   bin/fab vututi_vututi_configure

Atspausdinti visus ututi serverio nustatymus galite paleisdami
komandą::

   bin/fab vututi_vututi_current_settings

Tai reikalinga jei norite sužinoti kokie šio serverio parametrai (pvz.
kur saugomos atsarginės duomenų kopijos, kur saugomi skriptai ir t.t.)


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


Serverio paleidmas/sustabdymas/perkrovimas
------------------------------------------

Ututi serveriui::

  bin/fab vututi_vututi_start
  bin/fab vututi_vututi_stop
  bin/fab vututi_vututi_restart

Ututi serverio duomenų bazei::

  bin/fab vututi_ututi_db_start
  bin/fab vututi_ututi_db_stop


Atsarginės kopijos
------------------

Padaryti naują atsarginę kopiją galite paleisdami komandą::

   bin/fab vututi_vututi_backup

Atsarginės kopijos daromos automatiškai kiekvieną naktį. Laikomos
paskutinės 5 atsarginės duomenų kopijos. Galite parsisiųsti paskutinę
duomenų bazės kopiją į savo kompiuterį paleisdami komandą::

   bin/fab vututi_vututi_download_backup

Įkelti paskutinę atsarginę kopiją galite paleisdami komandą::

   bin/fab vututi_vututi_import_backup

Jei norite įkelti ne paskutinę, o kurią nors kitą duomenų bazės kopiją
nurodykite ją kaip `import_backup` komandos parametrą, pvz.::

   bin/fab vututi_vututi_import_backup:daily/2012-12-05_16-17-37

