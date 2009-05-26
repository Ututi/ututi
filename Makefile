#!/usr/bin/make
#
# Makefile for UTUTI Sandbox
#

BOOTSTRAP_PYTHON=python2.5

.PHONY: all
all: python/bin/python bin/buildout bin/paster

python/bin/python:
	$(MAKE) BOOTSTRAP_PYTHON=$(BOOTSTRAP_PYTHON) bootstrap

bin/buildout: bootstrap.py
	$(MAKE) BOOTSTRAP_PYTHON=$(BOOTSTRAP_PYTHON) bootstrap

bin/test: buildout.cfg bin/buildout setup.py
	bin/buildout

bin/paster: buildout.cfg bin/buildout setup.py
	bin/buildout

bin/tags: buildout.cfg bin/buildout setup.py
	bin/buildout

instance/var/data/postgresql.conf:
	mkdir -p instance/var/data
	/usr/lib/postgresql/8.3/bin/initdb -D instance/var/data -E UNICODE

export PGPORT ?= 4455
PG_PATH = /usr/lib/postgresql/8.3

instance/var/data/initialized:
	${PG_PATH}/bin/createuser --createdb    --no-createrole --no-superuser --login admin -h ${PWD}/instance/var/run
	${PG_PATH}/bin/createuser --no-createdb --no-createrole --no-superuser --login test -h ${PWD}/instance/var/run
	${PG_PATH}/bin/createdb --owner test -E UTF8 test -h ${PWD}/instance/var/run
	${PG_PATH}/bin/createlang plpgsql test -h ${PWD}/instance/var/run
	${PG_PATH}/bin/createdb --owner admin -E UTF8 development -h ${PWD}/instance/var/run
	${PG_PATH}/bin/createlang plpgsql development -h ${PWD}/instance/var/run
	touch instance/var/data/initialized

instance/done: instance/var/data/postgresql.conf
	$(MAKE) start_database
	$(MAKE) instance/var/data/initialized
	$(MAKE) stop_database
	touch instance/done

instance/var/run/.s.PGSQL.${PGPORT}:
	mkdir -p instance/var/run
	mkdir -p instance/var/log
	${PG_PATH}/bin/pg_ctl -D instance/var/data -o "-c unix_socket_directory=${PWD}/instance/var/run/" start  -l instance/var/log/pg.log
	sleep 5

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
	bin/buildout

.PHONY: test
test: bin/test instance/done instance/var/run/.s.PGSQL.${PGPORT}
	bin/test

.PHONY: utest
testall: bin/test
	bin/test -u

.PHONY: ftest
ftest: bin/test instance/done instance/var/run/.s.PGSQL.${PGPORT}
	bin/test -f --at-level 2

.PHONY: run
run: bin/paster instance/done instance/var/run/.s.PGSQL.${PGPORT}
	bin/paster serve development.ini

.PHONY: clean
clean:
	rm -rf bin/ parts/ develop-eggs/ src/ututi.egg-info/ python/ tags TAGS ID .installed.cfg

.PHONY: coverage
coverage: build
	rm -rf coverage
	bin/test -u --coverage=coverage
	mv parts/test/coverage .
	@cd coverage && ls | grep -v tests | xargs grep -c '^>>>>>>' | grep -v ':0$$'

.PHONY: coverage-reports-html
coverage-reports-html:
	rm -rf coverage/reports
	mkdir coverage/reports
	bin/coverage
	ln -s ututi.html coverage/reports/index.html
