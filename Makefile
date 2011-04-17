#!/usr/bin/make
#
# Makefile for UTUTI Sandbox
#

BOOTSTRAP_PYTHON=python2.6
TIMEOUT=1
BUILDOUT = bin/buildout -t $(TIMEOUT) && touch bin/*

export LC_ALL := en_US.utf8


.PHONY: all
all: python/bin/python bin/buildout bin/paster

python/bin/python:
	$(MAKE) BOOTSTRAP_PYTHON=$(BOOTSTRAP_PYTHON) bootstrap

bin/buildout: bootstrap.py
	$(MAKE) BOOTSTRAP_PYTHON=$(BOOTSTRAP_PYTHON) bootstrap

bin/test: buildout.cfg bin/buildout setup.py versions.cfg
	$(BUILDOUT)

bin/coverage: buildout.cfg bin/buildout setup.py versions.cfg
	$(BUILDOUT)

bin/py: buildout.cfg bin/buildout setup.py versions.cfg
	$(BUILDOUT)

bin/paster: buildout.cfg bin/buildout setup.py versions.cfg
	$(BUILDOUT)

bin/tags: buildout.cfg bin/buildout setup.py versions.cfg
	$(BUILDOUT)

export PGPORT ?= 4455

PG_PATH = $(shell if test -d /usr/lib/postgresql/8.3; then echo /usr/lib/postgresql/8.3; else echo /usr/lib/postgresql/8.4; fi)

instance/var/data/postgresql.conf:
	mkdir -p ${PWD}/instance/var/data
	${PG_PATH}/bin/initdb -D ${PWD}/instance/var/data -E UNICODE
	echo 'fsync = off' >> instance/var/data/postgresql.conf

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
	bin/test --list-tests

.PHONY: utest
testall: bin/test
	bin/test -u

.PHONY: ftest
ftest: bin/test instance/done instance/var/run/.s.PGSQL.${PGPORT}
	bin/test -f --at-level 2

.PHONY: run
run: bin/paster instance/done instance/var/run/.s.PGSQL.${PGPORT}
	bin/paster serve development.ini --reload --monitor-restart

.PHONY: clean
clean:
	rm -rf bin/ parts/ develop-eggs/ src/ututi.egg-info/ python/ tags TAGS ID .installed.cfg
	find src/ -name '*.pyc' -exec rm '{}' ';'

.PHONY: coverage
coverage: bin/test bin/coverage instance/done instance/var/run/.s.PGSQL.${PGPORT}
	rm -rf .coverage
	bin/coverage run bin/test

COVERAGE_OMIT_PARAMS="src/ututi/migration/*","src/ututi/tests/*","/*/eggs/*","eggs/*","src/facebook*","src/daemon*"

.PHONY: coverage_report
coverage_report: bin/test .coverage
	rm -rf coverage
	bin/coverage html -d ./coverage/ --omit=$(COVERAGE_OMIT_PARAMS)

.PHONY: coverage_report_hudson
coverage_report_hudson: bin/coverage .coverage
	bin/coverage xml --omit=$(COVERAGE_OMIT_PARAMS)

.PHONY: extract-translations
extract-translations: bin/py
	bin/py setup.py extract_messages --no-location -c TRANSLATORS
	bin/py setup.py update_catalog --ignore-obsolete=yes --no-fuzzy-matching
	for file in $$(find src/ututi/i18n -name "*.po" -type f); do \
	   sed -e "s/#, fuzzy, python-format/#, python-format/ig" $$file > /tmp/tempfile.tmp; \
	   mv /tmp/tempfile.tmp $$file; \
	   echo "Modified: " $$file; \
	done

.PHONY: compile-translations
compile-translations: bin/py
	bin/py setup.py compile_catalog

.PHONY: ubuntu-environment
ubuntu-environment:
	@if [ `whoami` != "root" ]; then { \
	 echo "You must be root to create an environment."; \
	 echo "I am running as $(shell whoami)"; \
	 exit 3; \
	} else { \
	 apt-get build-dep python-psycopg2 python-imaging ; \
	 apt-get install build-essential python-all python-all-dev postgresql enscript myspell-lt myspell-en-gb myspell-pl libxslt1-dev libpq-dev python-pyrex python-setuptools python-geoip; \
	 apt-get remove python-egenix-mx-base-dev; \
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
	mkdir -p backup
	scp ututi.lt:/srv/u2ti.com/backup/dbdump ./backup/dbdump

.PHONY: download_pl_backup
download_pl_backup:
	mkdir -p backup
	scp ututi.lt:/srv/ututi.pl/backup/dbdump ./backup/dbdump

.PHONY: import_backup
import_backup: instance/var/run/.s.PGSQL.${PGPORT}
	psql -h ${PWD}/instance/var/run/ -d development -c "drop schema public cascade"
	droplang plpgsql development -h ${PWD}/instance/var/run/ || true
	psql -h ${PWD}/instance/var/run/ -d development -c "create schema public"
	${PG_PATH}/bin/pg_restore -d development -h ${PWD}/instance/var/run --no-owner < backup/dbdump || true
	psql -h ${PWD}/instance/var/run/ -d development -c "update users set password = '2M/gReXQLaGpx28PT7mBFLWS0sC04eClUH80'"

.PHONY: download_backup_files
download_backup_files:
	rsync -rtv ututi.lt:/srv/u2ti.com/backup/files_dump/ ./backup/files_dump/

.PHONY: test_migration
test_migration: instance/var/run/.s.PGSQL.${PGPORT}
	psql -h ${PWD}/instance/var/run/ -d development -c "drop schema public cascade"
	droplang plpgsql development -h ${PWD}/instance/var/run/ || true
	psql -h ${PWD}/instance/var/run/ -d development -c "create schema public"
	${PG_PATH}/bin/pg_restore -d development -h ${PWD}/instance/var/run --no-owner < backup/dbdump || true
	${PG_PATH}/bin/pg_dump --format=p -h ${PWD}/instance/var/run/ development -s > before_migration.txt
	${PWD}/bin/migrate development.ini upgrade_once
	${PG_PATH}/bin/pg_dump --format=p -h ${PWD}/instance/var/run/ development -s > after_migration.txt
	${PWD}/bin/migrate development.ini downgrade
	${PG_PATH}/bin/pg_dump --format=p -h ${PWD}/instance/var/run/ development -s > after_downgrade.txt

.PHONY: dbdump
dbdump: instance/var/run/.s.PGSQL.${PGPORT}
	${PG_PATH}/bin/pg_dump --format=c -h ${PWD}/instance/var/run/ development > dbdump

.PHONY: test_migration_2
test_migration_2: instance/var/run/.s.PGSQL.${PGPORT}
	psql -h ${PWD}/instance/var/run/ -d development -c "drop schema public cascade"
	psql -h ${PWD}/instance/var/run/ -d development -c "create schema public"
	${PWD}/bin/paster setup-app development.ini
	${PG_PATH}/bin/pg_dump --format=p -h ${PWD}/instance/var/run/ development -s > default.txt
	psql -h ${PWD}/instance/var/run/ -d development -c "drop schema public cascade"
	droplang plpgsql development -h ${PWD}/instance/var/run/ || true
	psql -h ${PWD}/instance/var/run/ -d development -c "create schema public"
	${PG_PATH}/bin/pg_restore -d development -h ${PWD}/instance/var/run --no-owner < backup/dbdump || true
	${PWD}/bin/migrate development.ini
	${PG_PATH}/bin/pg_dump --format=p -h ${PWD}/instance/var/run/ development -s > actual.txt

.PHONY: test_translations
test_translations: bin/pofilter
	bin/py setup.py update_catalog --ignore-obsolete=yes --no-fuzzy-matching
	bin/pofilter --progress=none -t xmltags -t printf --nous ${PWD}/src/ututi/i18n/ -o ${PWD}/parts/test_translations/
	diff -r -u ${PWD}/src/ututi/tests/expected_i18n_errors/lt ${PWD}/parts/test_translations/lt
	diff -r -u ${PWD}/src/ututi/tests/expected_i18n_errors/pl ${PWD}/parts/test_translations/pl

.coverage: bin/coverage bin/test
	bin/coverage run bin/test

# Test for files that were not touched at all such files may contain
# code, but if the files were not imported during the test run they
# will not show up in the coverage report, we want to at least get a
# warning when that happens
.PHONY: test_coverage
test_coverage: bin/coverage .coverage
	bin/coverage report --include "data/*" | grep '^data/' | awk  '{print $$1}' | sed s/data/src\\/ututi/ | sort > parts/test/covered_templates.txt
	find src/ututi -name "*.mako" | sort > parts/test/all_templates.txt
	diff -u parts/test/all_templates.txt parts/test/covered_templates.txt || true

	bin/coverage report --omit="src/ututi/migration/*","src/ututi/tests/*","src/facebook*","src/daemon*" --include="src/*" | grep '^src/' | awk  '{print $$1}' | sort > parts/test/covered_code.txt
	find src/ututi -name "*.py" | grep -v "src/ututi/migration" | grep -v "src/ututi/tests" | sed s/\\.py// | sort > parts/test/all_code.txt
	diff -u parts/test/all_code.txt parts/test/covered_code.txt || true

.PHONY: update_expected_translations
update_expected_translations: bin/pofilter
	bin/pofilter --progress=none -t xmltags -t printf --nous ${PWD}/src/ututi/i18n/ -o ${PWD}/parts/test_translations/
	rm -rf ${PWD}/src/ututi/tests/expected_i18n_errors/
	mv ${PWD}/parts/test_translations/ ${PWD}/src/ututi/tests/expected_i18n_errors/

.PHONY: test_all
test_all: bin/test instance/done instance/var/run/.s.PGSQL.${PGPORT}
	! git --no-pager grep 'console.log' -- *.js *.mako *.html | grep -v '\(jquery\|ckeditor\|uservoice\)'
	! git --no-pager grep 'pdb.set_trace' -- *.py
	rm -rf data/templates/
	$(MAKE) test_translations

.PHONY: test_all_coverage
test_all_coverage: bin/test bin/coverage instance/done instance/var/run/.s.PGSQL.${PGPORT}
	rm -rf data/templates/
	bin/coverage run bin/test --all
	$(MAKE) test_coverage
	$(MAKE) test_translations

migrate: instance/var/run/.s.PGSQL.${PGPORT}
	${PWD}/bin/migrate development.ini

downgrade: instance/var/run/.s.PGSQL.${PGPORT}
	${PWD}/bin/migrate development.ini downgrade

start_sms: instance/var/run/.s.PGSQL.${PGPORT}
	${PWD}/bin/sms_daemon start

stop_sms:
	${PWD}/bin/sms_daemon stop

ssh:
	ssh -nNT -R 7137:localhost:5000 u2ti.com
