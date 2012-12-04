Sistemos paruošimas darbui su ja
================================

Su Ututi produkto kodu geriausia dirbti Ubuntu_ Linux aplinkoje.  Čia
pateiktos instrukcijos yra pritaikytos ir patikrintos būtent šioje
aplinkoje.

Git kliento diegimas ir serverio konfigūravimas
-----------------------------------------------

Į ``~/.ssh/config`` įrašykite::

  Host vututi
  Hostname klevas.mif.vu.lt
  Port 22126

Versijavimui naudojame Git_. Darbiniame kataloge įvykdykite::

  sudo apt-get install git-core
  git clone ssh://git@vututi:/git/ututi vututi
  cd vututi

**Svarbu prieš tai darant Vutui serveryje sukonfigūruoti git acccess**

Python ir reikalingų bibliotekų diegimas
----------------------------------------

``vututi`` kataloge įvykdykite::

  sudo make ubuntu-environment
  make

.. _Ubuntu: http://www.ubuntu.com/
.. _Git: http://git-scm.com/
.. _Python: http://www.python.org/
