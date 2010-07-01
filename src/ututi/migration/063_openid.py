from ututi.migration import sql_migrate

upgrade, downgrade = sql_migrate(__name__)
