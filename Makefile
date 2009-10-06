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
	mkdir -p ${PWD}/instance/var/data
	${PG_PATH}/bin/initdb -D ${PWD}/instance/var/data -E UNICODE

instance/var/data/initialized:
	${PG_PATH}/bin/createuser --createdb    --no-createrole --no-superuser --login admin -h ${PWD}/instance/var/run
	${PG_PATH}/bin/createuser --no-createdb --no-createrole --no-superuser --login test -h ${PWD}/instance/var/run
	${PG_PATH}/bin/createdb --owner test -E UTF8 test -h ${PWD}/instance/var/run
	${PG_PATH}/bin/createlang plpgsql test -h ${PWD}/instance/var/run
	${PG_PATH}/bin/createdb --owner admin -E UTF8 development -h ${PWD}/instance/var/run
	${PG_PATH}/bin/createlang plpgsql development -h ${PWD}/instance/var/run
	bin/paster setup-app development.ini
	echo 1 > ${PWD}/instance/var/data/initialized

instance/done: instance/var/data/postgresql.conf
	$(MAKE) start_database
	$(MAKE) instance/var/data/initialized
	$(MAKE) stop_database
	echo 1 > ${PWD}/instance/done

instance/var/run/.s.PGSQL.${PGPORT}:
	mkdir -p ${PWD}/instance/var/run
	mkdir -p ${PWD}/instance/var/log
	${PG_PATH}/bin/pg_ctl -D ${PWD}/instance/var/data -o "-c unix_socket_directory=${PWD}/instance/var/run/ -c custom_variable_classes='ututi' -c ututi.active_user=0" start  -l ${PWD}/instance/var/log/pg.log
	sleep 5

.PHONY: testpsql
testpsql:
	psql -h ${PWD}/instance/var/run/ -d test

.PHONY: devpsql
devpsql:
	psql -h ${PWD}/instance/var/run/ -d development

reset_devdb: instance/var/run/.s.PGSQL.${PGPORT}
	psql -h ${PWD}/instance/var/run/ -d development -c "drop schema public cascade"
	psql -h ${PWD}/instance/var/run/ -d development -c "create schema public"
	rm -rf ${PWD}/instance/uploads
	bin/paster setup-app development.ini

.PHONY: instance
instance: instance/done

.PHONY: start_database
start_database: instance/var/data/postgresql.conf instance/var/run/.s.PGSQL.${PGPORT}

.PHONY: stop_database
stop_database:
	test -f ${PWD}/instance/var/data/postmaster.pid && ${PG_PATH}/bin/pg_ctl -D ${PWD}/instance/var/data stop -o "-c unix_socket_directory=${PWD}/instance/var/run/" || true

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
	bin/test --coverage=coverage
	mv parts/test/coverage .
	@cd coverage && ls | grep -v tests | xargs grep -c '^>>>>>>' | grep -v ':0$$'

.PHONY: extract-translations
extract-translations: bin/py
	rm -rf src/ututi/templates_py
	cp -r data/templates src/ututi/templates_py
	bin/py setup.py extract_messages
	rm -rf src/ututi/templates_py
	bin/py setup.py update_catalog

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
	 apt-get build-dep python-psycopg2 python-imaging python-lxml; \
	 apt-get install build-essential python-all python-all-dev postgresql; \
	 apt-get install enscript; \
	 apt-get install myspell-lt; \
	 apt-get remove  python-egenix-mx-base-dev; \
	 echo "Installation Complete: Next... Run 'make'."; \
	} fi

.PHONY: shell
shell: bin/paster instance/done instance/var/run/.s.PGSQL.${PGPORT}
	bin/paster --plugin=Pylons shell development.ini

export BUILD_ID ?= `date +%Y-%m-%d_%H-%M-%S`

.PHONY: package_release
package_release:
	git archive --prefix=ututi${BUILD_ID}/ HEAD | gzip > ututi${BUILD_ID}.tar.gz

.PHONY: download_backup
download_backup:
	scp ututi.lt:/srv/u2ti.com/backup/dbdump ./backup/dbdump

.PHONY: import_backup
import_backup: instance/var/run/.s.PGSQL.${PGPORT}
	psql -h ${PWD}/instance/var/run/ -d development -c "drop schema public cascade"
	psql -h ${PWD}/instance/var/run/ -d development -c "create schema public"
	/usr/lib/postgresql/8.3/bin/pg_restore -d development -h ${PWD}/instance/var/run --no-owner < backup/dbdump || true

.PHONY: download_backup_files
download_backup_files:
	rsync -rtv ututi.lt:/srv/u2ti.com/backup/files_dump/ ./backup/files_dump/

.PHONY: test_migration
test_migration: instance/var/run/.s.PGSQL.${PGPORT}
	psql -h ${PWD}/instance/var/run/ -d development -c "drop schema public cascade"
	psql -h ${PWD}/instance/var/run/ -d development -c "create schema public"
	/usr/lib/postgresql/8.3/bin/pg_restore -d development -h ${PWD}/instance/var/run --no-owner < backup/dbdump || true
	/usr/lib/postgresql/8.3/bin/pg_dump --format=p -h ${PWD}/instance/var/run/ -p 4455 -d development -s > before_migration.txt
	${PWD}/bin/migrate development.ini upgrade_once
	/usr/lib/postgresql/8.3/bin/pg_dump --format=p -h ${PWD}/instance/var/run/ -p 4455 -d development -s > after_migration.txt
	${PWD}/bin/migrate development.ini downgrade
	/usr/lib/postgresql/8.3/bin/pg_dump --format=p -h ${PWD}/instance/var/run/ -p 4455 -d development -s > after_downgrade.txt

.PHONY: test_migration_2
test_migration_2: instance/var/run/.s.PGSQL.${PGPORT}
	psql -h ${PWD}/instance/var/run/ -d development -c "drop schema public cascade"
	psql -h ${PWD}/instance/var/run/ -d development -c "create schema public"
	${PWD}/bin/paster setup-app development.ini
	/usr/lib/postgresql/8.3/bin/pg_dump --format=p -h ${PWD}/instance/var/run/ -p 4455 -d development -s > default.txt
	psql -h ${PWD}/instance/var/run/ -d development -c "drop schema public cascade"
	psql -h ${PWD}/instance/var/run/ -d development -c "create schema public"
	/usr/lib/postgresql/8.3/bin/pg_restore -d development -h ${PWD}/instance/var/run --no-owner < backup/dbdump || true
	${PWD}/bin/migrate development.ini
	/usr/lib/postgresql/8.3/bin/pg_dump --format=p -h ${PWD}/instance/var/run/ -p 4455 -d development -s > actual.txt
