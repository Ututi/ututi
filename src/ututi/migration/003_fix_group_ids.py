# Fix group ids that have slashes or + signs
import re

def group_exists(connection, group_id):
    groups = list(connection.execute("select id, group_id from groups where group_id = '%(group_id)s'" % dict(group_id=group_id)))
    return len(groups) > 0


def fix_group_id(connection, group):
    """Remove offending chars from the group's id and test the id for uniqueness."""
    content_id = group[0]
    group_id = group[1]
    year = group[2].year

    p = re.compile(r'(/|\+|\\)')
    new_id = p.sub('', group_id)

    ids = [
        '%(gid)s' % dict(gid=new_id),
        '%(gid)s-%(year)i' % dict(gid=new_id, year=year),
        '%(gid)s-%(id)i' % dict(gid=new_id, id=content_id)
        ]

    for id in ids:
        if not group_exists(connection, id):
            return id
    return None


def upgrade(engine):
    connection = engine.connect()
    connection.execute("create table groups_fixed (id int8, group_id varchar(250) not null)")
    groups = list(connection.execute(r"select id, group_id, year from groups where group_id like '%%/%%' or group_id like '%%+%%' or group_id like '%%\\%%'"))
    for group in groups:
        new_id = fix_group_id(connection, group)
        connection.execute("update groups set group_id = '%(newid)s' where id = %(id)i" % dict(newid=new_id, id=group[0]))
        connection.execute("insert into groups_fixed (id, group_id) values (%(id)i, '%(group_id)s')" % dict(id=group[0], group_id=group[1]))


def downgrade(engine):
    connection = engine.connect()
    groups = list(connection.execute(r"select * from groups_fixed"))
    for group in groups:
        connection.execute("update groups set group_id = '%(gid)s' where id = %(id)i" % dict(gid=group[1], id=group[0]))

    connection.execute("drop table if exists groups_fixed")

