#!/usr/bin/make
#
# Makefile for UTUTI Sandbox
#

BOOTSTRAP_PYTHON=python2.6
TIMEOUT=3
BUILDOUT_OPTIONS=
BUILDOUT = bin/buildout -t $(TIMEOUT) $(BUILDOUT_OPTIONS) && touch bin/*

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

include postgresql.mk

reset_devdb: ${PG_SOCKET}
	$(MAKE) reset_development
	rm -rf ${PWD}/instance/uploads
	bin/paster setup-app development.ini
	${PG_PATH}/bin/psql -h ${PG_RUN}/ -d development < src/ututi/model/data.sql

reset_testdb: ${PG_SOCKET}
	$(MAKE) reset_test
	bin/paster setup-app test.ini
	${PG_PATH}/bin/psql -h ${PG_RUN}/ -d test < src/ututi/model/data.sql

.PHONY: instance
instance: instance/done

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
test: test1 test2

.PHONY: test1
test1: bin/test instance/done ${PG_SOCKET} compile-translations
	bin/test --layer=Ututi

.PHONY: test2
test2: bin/test instance/done ${PG_SOCKET} compile-translations
	bin/test --layer=U2ti

.PHONY: utest
testall: bin/test compile-translations
	bin/test -u

.PHONY: ftest
ftest: bin/test instance/done ${PG_SOCKET} compile-translations
	bin/test -f --at-level 2

.PHONY: atest
atest: bin/test instance/done ${PG_SOCKET} compile-translations
	bin/test --all

.PHONY: run
run: bin/paster instance/done ${PG_SOCKET} compile-translations
	bin/paster serve development.ini --reload --monitor-restart

.PHONY: clean
clean:
	rm -rf bin/ parts/ develop-eggs/ src/ututi.egg-info/ python/ tags TAGS ID .installed.cfg
	find src/ -name '*.pyc' -exec rm '{}' ';'

.PHONY: coverage
coverage: bin/test bin/coverage instance/done ${PG_SOCKET} compile-translations
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
compile-translations: bin/py src/ututi/i18n/lt/LC_MESSAGES/ututi.mo src/ututi/i18n/pl/LC_MESSAGES/ututi.mo src/ututi/i18n/en/LC_MESSAGES/ututi.mo

src/ututi/i18n/lt/LC_MESSAGES/ututi.mo: src/ututi/i18n/lt/LC_MESSAGES/ututi.po
	bin/py setup.py compile_catalog

src/ututi/i18n/pl/LC_MESSAGES/ututi.mo: src/ututi/i18n/pl/LC_MESSAGES/ututi.po
	bin/py setup.py compile_catalog

src/ututi/i18n/en/LC_MESSAGES/ututi.mo: src/ututi/i18n/en/LC_MESSAGES/ututi.po
	bin/py setup.py compile_catalog

.PHONY: ubuntu-environment
ubuntu-environment:
	@if [ `whoami` != "root" ]; then { \
	 echo "You must be root to create an environment."; \
	 echo "I am running as $(shell whoami)"; \
	 exit 3; \
	} else { \
	 add-apt-repository ppa:fkrull/deadsnakes -y; \
	 apt-get update; \
	 apt-get install build-essential enscript libfreetype6-dev libjpeg-dev liblcms1-dev libpq-dev libsane-dev libxml2-dev libxslt1-dev myspell-en-gb myspell-lt myspell-pl postgresql python-all python-all-dbg python-all-dev python-geoip python-pyrex python-setuptools uuid-dev zlib1g-dev python-software-properties python2.6 python2.6-dev; \
	 echo "Installation Complete: Next... Run 'make'."; \
	} fi

.PHONY: shell
shell: bin/paster instance/done ${PG_SOCKET}
	bin/paster --plugin=Pylons shell development.ini

export BUILD_ID ?= `date +%Y-%m-%d_%H-%M-%S`

.PHONY: package_release
package_release:
	rm -f ututi*.tar.gz
	git archive --prefix=ututi${BUILD_ID}/ HEAD | gzip > ututi${BUILD_ID}.tar.gz

.PHONY: download_backup
download_backup:
	mkdir -p backup
	bin/fab vututi_vututi_download_backup

# XXX There is no such possibility at the moment
#.PHONY: download_backup_files
#download_backup_files:
# 	rsync -rtv ututi.lt:/srv/u2ti.com/backup/files_dump/ ./backup/files_dump/

.PHONY: test_migration
test_migration: ${PG_SOCKET}
	$(MAKE) import_backup
	${PG_PATH}/bin/pg_dump --format=p -h ${PWD}/instance/var/run/ development -s > before_migration.txt
	${PWD}/bin/migrate development.ini upgrade_once
	${PG_PATH}/bin/pg_dump --format=p -h ${PWD}/instance/var/run/ development -s > after_migration.txt
	${PWD}/bin/migrate development.ini downgrade
	${PG_PATH}/bin/pg_dump --format=p -h ${PWD}/instance/var/run/ development -s > after_downgrade.txt

.PHONY: test_migration_2
test_migration_2: ${PG_SOCKET}
	psql -h ${PWD}/instance/var/run/ -d development -c "drop schema public cascade"
	psql -h ${PWD}/instance/var/run/ -d development -c "create schema public"
	${PWD}/bin/paster setup-app development.ini
	${PG_PATH}/bin/pg_dump --format=p -h ${PWD}/instance/var/run/ development -s > default.txt
	$(MAKE) import_backup
	${PWD}/bin/migrate development.ini
	${PG_PATH}/bin/pg_dump --format=p -h ${PWD}/instance/var/run/ development -s > actual.txt

.PHONY: test_translations
test_translations: bin/pofilter
	bin/py setup.py update_catalog --ignore-obsolete=yes --no-fuzzy-matching
	bin/pofilter --progress=none -t xmltags -t printf --nous ${PWD}/src/ututi/i18n/ -o ${PWD}/parts/test_translations/
	diff -r -x .gitkeep -u ${PWD}/src/ututi/tests/expected_i18n_errors/lt ${PWD}/parts/test_translations/lt
	diff -r -x .gitkeep -u ${PWD}/src/ututi/tests/expected_i18n_errors/pl ${PWD}/parts/test_translations/pl

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
test_all: bin/test instance/done ${PG_SOCKET} compile-translations
	! git --no-pager grep 'console.log' -- *.js *.mako *.html | grep -v '\(jquery\|ckeditor\|uservoice\)'
	! git --no-pager grep 'pdb.set_trace' -- *.py
	rm -rf data/templates/
	bin/test --all -vvv
	$(MAKE) test_translations

.PHONY: test_all_coverage
test_all_coverage: bin/test bin/coverage instance/done ${PG_SOCKET}
	rm -rf data/templates/
	bin/coverage run bin/test --all
	$(MAKE) test_coverage
	$(MAKE) test_translations

migrate: ${PG_SOCKET}
	${PWD}/bin/migrate development.ini

downgrade: ${PG_SOCKET}
	${PWD}/bin/migrate development.ini downgrade

start_sms: ${PG_SOCKET}
	${PWD}/bin/sms_daemon start

stop_sms:
	${PWD}/bin/sms_daemon stop

ssh:
	ssh -nNT -R 7137:localhost:5000 u2ti.com

.PHONY: schema_diff
schema_diff: ${PG_SOCKET}
	@$(MAKE) import_backup_schema_into_test  > schema_diff.log 2>&1
	@${PWD}/bin/migrate test.ini > schema_diff.log  2>&1
	@${PG_PATH}/bin/pg_dump --format=p -h ${PG_RUN}/ test -s > actual.txt
	@$(MAKE) reset_testdb > schema_diff.log 2>&1
	@${PG_PATH}/bin/pg_dump --format=p -h ${PG_RUN}/ test -s > default.txt
	@echo "-- upgrade"
	@apgdiff actual.txt default.txt
	@echo "-- downgrade"
	@apgdiff default.txt actual.txt
	@echo "/* Diff"
	@git diff src/ututi/model/defaults.sql
	@echo "*/"
