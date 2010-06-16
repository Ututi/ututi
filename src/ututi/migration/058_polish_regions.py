from ututi.migration import sql_migrate

m_upgrade, m_downgrade = sql_migrate(__name__)


def upgrade(engine, lang):
    if lang != 'pl':
        return
    m_upgrade(engine, lang)


def downgrade(engine, lang):
    if lang != 'pl':
        return
    m_downgrade(engine, lang)
