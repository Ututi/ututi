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

export PGPORT := 4455

instance/done: instance/var/data/postgresql.conf instance/var/run/.s.PGSQL.${PGPORT}
	/usr/lib/postgresql/8.3/bin/createuser --createdb    --no-createrole --no-superuser --login admin -h ${PWD}/instance/var/run
	/usr/lib/postgresql/8.3/bin/createuser --no-createdb --no-createrole --no-superuser --login test -h ${PWD}/instance/var/run
	/usr/lib/postgresql/8.3/bin/createdb --owner test -E UTF8 test -h ${PWD}/instance/var/run
	/usr/lib/postgresql/8.3/bin/createlang plpgsql test -h ${PWD}/instance/var/run
	/usr/lib/postgresql/8.3/bin/createdb --owner admin -E UTF8 development -h ${PWD}/instance/var/run
	/usr/lib/postgresql/8.3/bin/createlang plpgsql development -h ${PWD}/instance/var/run

	/usr/lib/postgresql/8.3/bin/pg_ctl -D instance/var/data stop -o "-c unix_socket_directory=${PWD}/instance/var/run/"
	touch instance/done

instance/var/run/.s.PGSQL.${PGPORT}:
	mkdir -p instance/var/run
	/usr/lib/postgresql/8.3/bin/pg_ctl -D instance/var/data -o "-c unix_socket_directory=${PWD}/instance/var/run/" start
	sleep 5

.PHONY: instance
instance: instance/done

.PHONY: start_database
start_database: instance/var/data/postgresql.conf
	mkdir -p instance/var/run
	mkdir -p instance/var/log
	/usr/lib/postgresql/8.3/bin/pg_ctl -D instance/var/data -o "-c unix_socket_directory=${PWD}/instance/var/run/" start -l instance/var/log/pg.log

.PHONY: stop_database
stop_database:
	/usr/lib/postgresql/8.3/bin/pg_ctl -D instance/var/data stop -o "-c unix_socket_directory=${PWD}/instance/var/run/"

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
test: bin/test instance/done
	bin/test -u

.PHONY: testall
testall: bin/test instance/done
	bin/test

.PHONY: ftest
ftest: bin/test instance/done
	bin/test -f --at-level 2

.PHONY: run
run: bin/paster instance/done
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
