# -*- coding: utf-8 -*-
def upgrade(engine, lang):
    connection = engine.connect()
    if lang == 'lt':
        title = u'Bendras'
        description = u'Diskusijos apie viską ir visus'
    elif lang == 'pl':
        title = u'Ogólny'
        description = u'Dyskusje o wszystkim i niczym'
    else:
        title = u'General'
        description = u'Discussions on anything and everything'

    groups = list(connection.execute(r"select id from groups"))
    for group in groups:
        categories = list(connection.execute(r"select id from forum_categories where group_id = %d" % int(group[0])))
        if not categories:
            connection.execute(u"insert into forum_categories (group_id, title, description)"
                                 " values(%d, '%s', '%s')" % (int(group[0]), title, description))

def downgrade(engine, lang):
    pass

