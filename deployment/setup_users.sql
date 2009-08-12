/*
run:

/usr/bin/psql -f deployment/setup_users.sql

then run:

sudo -u postgres /usr/lib/postgresql/8.3/bin/createlang plpgsql ututi_testing
sudo -u postgres /usr/lib/postgresql/8.3/bin/createlang plpgsql ututi_release
bin/paster setup-app deployment/release.ini
bin/paster setup-app deployment/testing.ini
*/
sudo -u postgres psql -c "CREATE USER u2release WITH NOCREATEDB NOCREATEUSER UNENCRYPTED password 'release'"
sudo -u postgres psql -c "CREATE USER u2testing WITH NOCREATEDB NOCREATEUSER UNENCRYPTED password 'testing'"
sudo -u postgres psql -c "CREATE DATABASE ututi_release WITH OWNER = u2release ENCODING = 'UTF-8'"
sudo -u postgres psql -c "CREATE DATABASE ututi_testing WITH OWNER = u2testing ENCODING = 'UTF-8'"

/*
sudo -u postgres psql -c "DROP DATABASE ututi_release"
sudo -u postgres psql -c "DROP DATABASE ututi_testing"
sudo -u postgres psql -c "DROP USER u2release"
sudo -u postgres psql -c "DROP USER u2testing"
*/
