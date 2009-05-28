-- run:
-- /usr/bin/psql -f deployment/setup_users.sql
-- then run:
-- bin/paster setup-app deployment/release.ini
-- bin/paster setup-app deployment/testing.ini
CREATE USER u2release WITH NOCREATEDB NOCREATEUSER UNENCRYPTED password 'release';
CREATE USER u2testing WITH NOCREATEDB NOCREATEUSER UNENCRYPTED password 'testing';
CREATE DATABASE ututi_release WITH OWNER = u2release ENCODING = 'UTF-8';
CREATE DATABASE ututi_testing WITH OWNER = u2testing ENCODING = 'UTF-8';
