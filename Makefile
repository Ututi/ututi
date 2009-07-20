#!/usr/bin/make
#
# Makefile for UTUTI Sandbox
#

BOOTSTRAP_PYTHON=python2.5
TIMEOUT=1
BUILDOUT = bin/buildout -t $(TIMEOUT) && touch bin/*


.PHONY: all
all: python/bin/python bin/buildout bin/paster

python/bin/python:
	$(MAKE) BOOTSTRAP_PYTHON=$(BOOTSTRAP_PYTHON) bootstrap

bin/buildout: bootstrap.py
	$(MAKE) BOOTSTRAP_PYTHON=$(BOOTSTRAP_PYTHON) bootstrap

bin/test: buildout.cfg bin/buildout setup.py versions.cfg
	$(BUILDOUT)

bin/py: buildout.cfg bin/buildout setup.py versions.cfg
	$(BUILDOUT)

bin/paster: buildout.cfg bin/buildout setup.py versions.cfg
	$(BUILDOUT)

bin/tags: buildout.cfg bin/buildout setup.py versions.cfg
	$(BUILDOUT)

export PGPORT ?= 4455
PG_PATH = /usr/lib/postgresql/8.3

instance/var/data/postgresql.conf:
	mkdir -p instance/var/data
	${PG_PATH}/bin/initdb -D instance/var/data -E UNICODE

instance/var/data/initialized:
	${PG_PATH}/bin/createuser --createdb    --no-createrole --no-superuser --login admin -h ${PWD}/instance/var/run
	${PG_PATH}/bin/createuser --no-createdb --no-createrole --no-superuser --login test -h ${PWD}/instance/var/run
	${PG_PATH}/bin/createdb --owner test -E UTF8 test -h ${PWD}/instance/var/run
	${PG_PATH}/bin/createlang plpgsql test -h ${PWD}/instance/var/run
	${PG_PATH}/bin/createdb --owner admin -E UTF8 development -h ${PWD}/instance/var/run
	${PG_PATH}/bin/createlang plpgsql development -h ${PWD}/instance/var/run
	bin/paster setup-app development.ini
	echo 1 > instance/var/data/initialized

instance/done: instance/var/data/postgresql.conf
	$(MAKE) start_database
	$(MAKE) instance/var/data/initialized
	$(MAKE) stop_database
	echo 1 > instance/done

instance/var/run/.s.PGSQL.${PGPORT}:
	mkdir -p instance/var/run
	mkdir -p instance/var/log
	${PG_PATH}/bin/pg_ctl -D instance/var/data -o "-c unix_socket_directory=${PWD}/instance/var/run/" start  -l instance/var/log/pg.log
	sleep 5

.PHONY: testpsql
testpsql:
	psql -h ${PWD}/instance/var/run/ -d test

.PHONY: devpsql
devpsql:
	psql -h ${PWD}/instance/var/run/ -d development

reset_devdb:
	psql -h ${PWD}/instance/var/run/ -d development -c "drop schema public cascade"
	psql -h ${PWD}/instance/var/run/ -d development -c "create schema public"
	bin/paster setup-app development.ini

import_sample_data:
	curl -c cookie_jar http://localhost:5000/dologin -F login=admin@ututi.lt -F password=asdasd
	curl -c cookie_jar http://localhost:5000/admin/import_users -F file_upload=@src/ututi/tests/functional/import/export_users.csv
	curl -c cookie_jar http://localhost:5000/admin/import_groups -F file_upload=@src/ututi/tests/functional/import/export_groups.csv
	curl -c cookie_jar http://localhost:5000/admin/import_structure -F file_upload=@src/ututi/tests/functional/import/export_structure.csv
	curl -c cookie_jar http://localhost:5000/admin/import_subjects -F file_upload=@src/ututi/tests/functional/import/export_subjects.csv
	curl -c cookie_jar http://localhost:5000/admin/import_group_members -F file_upload=@src/ututi/tests/functional/import/export_group_members.csv
	curl -c cookie_jar http://localhost:5000/admin/import_user_logos -F file_upload=@src/ututi/tests/functional/import/export_user_logos.csv
	curl -c cookie_jar http://localhost:5000/admin/import_group_logos -F file_upload=@src/ututi/tests/functional/import/export_group_logos.csv
	curl -c cookie_jar http://localhost:5000/admin/import_structure_logos -F file_upload=@src/ututi/tests/functional/import/export_structure_logos.csv
	curl -c cookie_jar http://localhost:5000/admin/import_group_files -F file_upload=@src/ututi/tests/functional/import/export_group_files.csv
	curl -c cookie_jar http://localhost:5000/admin/import_subject_files -F file_upload=@src/ututi/tests/functional/import/export_subject_files.csv
	curl -c cookie_jar http://localhost:5000/admin/import_group_pages -F file_upload=@src/ututi/tests/functional/import/export_group_pages.csv
	curl -c cookie_jar http://localhost:5000/admin/import_subject_pages -F file_upload=@src/ututi/tests/functional/import/export_subject_pages.csv
	curl -c cookie_jar http://localhost:5000/admin/import_group_watched_subjects -F file_upload=@src/ututi/tests/functional/import/export_group_watched_subjects.csv
	curl -c cookie_jar http://localhost:5000/admin/import_user_ignored_subjects -F file_upload=@src/ututi/tests/functional/import/export_user_ignored_subjects.csv
	curl -c cookie_jar http://localhost:5000/admin/import_user_watched_subjects -F file_upload=@src/ututi/tests/functional/import/export_user_watched_subjects.csv

.PHONY: instance
instance: instance/done

.PHONY: start_database
start_database: instance/var/data/postgresql.conf instance/var/run/.s.PGSQL.${PGPORT}

.PHONY: stop_database
stop_database:
	test -f instance/var/data/postmaster.pid && ${PG_PATH}/bin/pg_ctl -D instance/var/data stop -o "-c unix_socket_directory=${PWD}/instance/var/run/" || true

tags: buildout.cfg bin/buildout setup.py bin/tags
	bin/tags

TAGS: buildout.cfg bin/buildout setup.py bin/tags
	bin/tags

ID: buildout.cfg bin/buildout setup.py bin/tags
	bin/tags

.PHONY: bootstrap
bootstrap:
	$(BOOTSTRAP_PYTHON) bootstrap.py

.PHONY: buildout
buildout:
	$(BUILDOUT)

.PHONY: test
test: bin/test instance/done instance/var/run/.s.PGSQL.${PGPORT}
	bin/test --all

.PHONY: utest
testall: bin/test
	bin/test -u

.PHONY: ftest
ftest: bin/test instance/done instance/var/run/.s.PGSQL.${PGPORT}
	bin/test -f --at-level 2

.PHONY: run
run: bin/paster instance/done instance/var/run/.s.PGSQL.${PGPORT}
	bin/paster serve development.ini --reload --monitor-restart

.PHONY: start_testing
start_testing: bin/paster
	bin/paster serve ${PWD}/deployment/testing.ini --daemon --pid-file=${PWD}/deployment/testing.pid --log-file=${PWD}/deployment/testing.log

.PHONY: start_debugging
start_debugging: bin/paster
	bin/paster serve ${PWD}/deployment/debugging.ini --daemon --pid-file=${PWD}/deployment/debugging.pid --log-file=${PWD}/deployment/testing.log

.PHONY: start_staging
start_staging: bin/paster
	bin/paster serve ${PWD}/deployment/staging.ini --daemon --pid-file=${PWD}/deployment/staging.pid --log-file=${PWD}/deployment/testing.log

.PHONY: start_release
start_release: bin/paster
	bin/paster serve ${PWD}/deployment/release.ini --daemon --pid-file=${PWD}/deployment/release.pid --log-file=${PWD}/deployment/testing.log

.PHONY: stop_testing
stop_testing: bin/paster
	bin/paster serve ${PWD}/deployment/testing.ini --stop-daemon --pid-file=${PWD}/deployment/testing.pid

.PHONY: stop_debugging
stop_debugging: bin/paster
	bin/paster serve ${PWD}/deployment/debugging.ini --stop-daemon --pid-file=${PWD}/deployment/debugging.pid

.PHONY: stop_staging
stop_staging: bin/paster
	bin/paster serve ${PWD}/deployment/staging.ini --stop-daemon --pid-file=${PWD}/deployment/staging.pid

.PHONY: stop_release
stop_release: bin/paster
	bin/paster serve ${PWD}/deployment/release.ini --stop-daemon --pid-file=${PWD}/deployment/release.pid

.PHONY: clean
clean:
	rm -rf bin/ parts/ develop-eggs/ src/ututi.egg-info/ python/ tags TAGS ID .installed.cfg

.PHONY: coverage
coverage: bin/test
	rm -rf coverage
	bin/test --all --coverage=coverage
	mv parts/test/coverage .
	@cd coverage && ls | grep -v tests | xargs grep -c '^>>>>>>' | grep -v ':0$$'

.PHONY: extract-translations
extract-translations: bin/py
	bin/py setup.py extract_messages

.PHONY: compile-translations
compile-translations: bin/py
	bin/py setup.py compile_catalog

.PHONY: coverage-reports-html
coverage-reports-html:
	rm -rf coverage/reports
	mkdir coverage/reports
	bin/coverage
	ln -s ututi.html coverage/reports/index.html

.PHONY: ubuntu-environment
ubuntu-environment:
	@if [ `whoami` != "root" ]; then { \
	 echo "You must be root to create an environment."; \
	 echo "I am running as $(shell whoami)"; \
	 exit 3; \
	} else { \
	 apt-get build-dep python-psycopg2; \
	 apt-get install build-essential python-all python-all-dev postgresql; \
	 apt-get install enscript; \
	 echo "Installation Complete: Next... Run 'make'."; \
	} fi
