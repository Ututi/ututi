export PGPORT ?= 4455
PG_PATH ?= $(shell if test -d /usr/lib/postgresql/8.4; then echo /usr/lib/postgresql/8.4; else echo /usr/lib/postgresql/8.3; fi)
PG_DIR = ${PWD}/instance/var
PG_DATA = ${PG_DIR}/data
PG_RUN = ${PG_DIR}/run
PG_LOG = ${PG_DIR}/log
PG_SOCKET = ${PG_RUN}/.s.PGSQL.${PGPORT}
PGPARAMS = -D ${PG_DATA} -o "-F -c unix_socket_directory=${PWD}/instance/var/run/ -c custom_variable_classes='ututi' -c ututi.active_user=0" -l ${PG_LOG}/pg.log


${PG_DATA}/postgresql.conf:
	mkdir -p ${PG_DATA}
	${PG_PATH}/bin/initdb -D ${PG_DATA} -E UNICODE

${PG_DATA}/initialized:
	${PG_PATH}/bin/createdb -E UTF8 development -h ${PG_RUN}
	${PG_PATH}/bin/createlang plpgsql development -h ${PG_RUN} || true
	${PG_PATH}/bin/createdb -E UTF8 test -h ${PG_RUN}
	${PG_PATH}/bin/createlang plpgsql test -h ${PG_RUN} || true
	${PG_PATH}/bin/createdb -E UTF8 test2 -h ${PG_RUN}
	${PG_PATH}/bin/createlang plpgsql test2 -h ${PG_RUN} || true
	bin/paster setup-app development.ini
	echo 1 > ${PG_DATA}/initialized

instance/done: ${PG_DATA}/postgresql.conf
	$(MAKE) start_database
	$(MAKE) ${PG_DATA}/initialized
	$(MAKE) stop_database
	echo 1 > ${PWD}/instance/done

${PG_SOCKET}:
	mkdir -p ${PG_RUN}
	mkdir -p ${PG_LOG}
	${PG_PATH}/bin/pg_ctl $(PGPARAMS) start
	sleep 5

.PHONY: testpsql
testpsql:
	${PG_PATH}/bin/psql -h ${PG_RUN}/ -d test

.PHONY: testpsql2
testpsql2:
	${PG_PATH}/bin/psql -h ${PG_RUN}/ -d test2

.PHONY: devpsql
devpsql: ${PG_RUN}/.s.PGSQL.${PGPORT}
	${PG_PATH}/bin/psql -h ${PG_RUN}/ -d development

.PHONY: reset_development
reset_development: ${PG_SOCKET}
	${PG_PATH}/bin/psql -h ${PG_RUN}/ -d development -c "drop schema public cascade"
	${PG_PATH}/bin/psql -h ${PG_RUN}/ -d development -c "create schema public"

.PHONY: reset_test
reset_test: ${PG_SOCKET}
	${PG_PATH}/bin/psql -h ${PG_RUN}/ -d test -c "drop schema public cascade"
	${PG_PATH}/bin/psql -h ${PG_RUN}/ -d test -c "create schema public"

.PHONY: start_database
start_database: ${PG_DATA}/postgresql.conf ${PG_RUN}/.s.PGSQL.${PGPORT}

.PHONY: force_start_database
force_start_database:
	${PG_PATH}/bin/pg_ctl $(PGPARAMS) start
	sleep 5

.PHONY: database_status
database_status:
	${PG_PATH}/bin/pg_ctl $(PGPARAMS) status

.PHONY: stop_database
stop_database:
	test -f ${PG_DATA}/postmaster.pid && ${PG_PATH}/bin/pg_ctl $(PGPARAMS) stop -m f || true

schema.sql:
	${PG_PATH}/bin/pg_dump --format=p -h ${PG_RUN}/ development -s -x -O > schema.sql

.PHONY: import_backup
import_backup: ${PG_SOCKET}
	${PG_PATH}/bin/psql -h ${PG_RUN}/ -d development -c "drop schema public cascade"
	${PG_PATH}/bin/droplang plpgsql development -h ${PG_RUN}/ || true
	${PG_PATH}/bin/psql -h ${PG_RUN}/ -d development -c "create schema public"
	${PG_PATH}/bin/pg_restore -j 2 -d development -h ${PG_RUN} --no-owner backup/dbdump || true
	psql -h ${PWD}/instance/var/run/ -d development -c "update users set password = '2M/gReXQLaGpx28PT7mBFLWS0sC04eClUH80'"
	psql -h ${PWD}/instance/var/run/ -d development -c "update admin_users set password = '2M/gReXQLaGpx28PT7mBFLWS0sC04eClUH80'"

.PHONY: import_backup_schema_into_test
import_backup_schema_into_test: ${PG_SOCKET}
	${PG_PATH}/bin/psql -h ${PG_RUN}/ -d test -c "drop schema public cascade"
	${PG_PATH}/bin/droplang plpgsql test -h ${PG_RUN}/ || true
	${PG_PATH}/bin/psql -h ${PG_RUN}/ -d test -c "create schema public"
	time ${PG_PATH}/bin/pg_restore -d test -h ${PG_RUN} --no-owner -s < backup/dbdump || true
	${PG_PATH}/bin/pg_restore -d test -h ${PG_RUN} --no-owner -a -t db_versions < backup/dbdump || true

.PHONY: dbdump
dbdump: ${PG_SOCKET}
	${PG_PATH}/bin/pg_dump --format=c -h ${PG_RUN}/ development > dbdump

.PHONY: vututi_initial_db
vututi_initial_db: ${PG_SOCKET}
	${PG_PATH}/bin/psql -h ${PG_RUN}/ -d development -c "drop schema public cascade"
	${PG_PATH}/bin/droplang plpgsql development -h ${PG_RUN}/ || true
	${PG_PATH}/bin/psql -h ${PG_RUN}/ -d development -c "create schema public"
	${PG_PATH}/bin/pg_restore -j 2 -d development -h ${PG_RUN} --no-owner backup/dbdump || true
	${PWD}/bin/migrate development.ini
	bin/py scripts/strip_nonmif_data.py
	${PG_PATH}/bin/pg_dump --format=c -h ${PG_RUN}/ development > vututi_dbdump
