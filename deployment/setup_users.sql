/*
run:

/usr/bin/psql -f deployment/setup_users.sql

then run:

sudo -u postgres /usr/lib/postgresql/8.3/bin/createlang plpgsql ututi_testing
sudo -u postgres /usr/lib/postgresql/8.3/bin/createlang plpgsql ututi_release
bin/paster setup-app deployment/release.ini
bin/paster setup-app deployment/testing.ini
*/
CREATE USER u2release WITH NOCREATEDB NOCREATEUSER UNENCRYPTED password 'release';
CREATE USER u2testing WITH NOCREATEDB NOCREATEUSER UNENCRYPTED password 'testing';
CREATE DATABASE ututi_release WITH OWNER = u2release ENCODING = 'UTF-8';
CREATE DATABASE ututi_testing WITH OWNER = u2testing ENCODING = 'UTF-8';

/*
sudo -u postgres psql
DROP DATABASE ututi_release;
DROP DATABASE ututi_testing;
DROP USER u2release;
DROP USER u2testing;
*/
