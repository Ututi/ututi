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

bin/test: buildout.cfg bin/buildout
	bin/buildout

bin/paster: buildout.cfg bin/buildout
	bin/buildout

.PHONY: bootstrap
bootstrap:
	$(BOOTSTRAP_PYTHON) bootstrap.py

.PHONY: buildout
buildout:
	bin/buildout

.PHONY: test
test: bin/test
	bin/test -u

.PHONY: testall
testall: bin/test
	bin/test

.PHONY: ftest
ftest: bin/test
	bin/test -f --at-level 2

.PHONY: run
run: bin/paster
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
