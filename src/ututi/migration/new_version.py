#!/usr/bin/python

import os
import sys
import re

MIGRATION_FILE_TEMPLATE = """\
from ututi.migration import sql_migrate

upgrade, downgrade = sql_migrate(__name__)
"""

UPGRADE_FILE_TEMPLATE = """\
-- alter table users add column net_worth integer not null default 0;
-- alter table users add column last_daily_money timestamp not null default (now() at time zone 'UTC');
-- create table admins (
--        id bigserial not null,
--        login varchar(20) not null,
--        password char(36),
--        primary key(id));;
"""

DOWNGRADE_FILE_TEMPLATE = """\
-- alter table users drop column net_worth;
-- drop table admins;
"""

def new_version(name, editor='vim'):
    # Increment version number in __init__.
    conf_file = file('__init__.py').read()
    old_version = re.search('MIN_VERSION = (.*)', conf_file).group(1)
    version = int(old_version) + 1
    conf_file = conf_file.replace('MIN_VERSION = %s' % old_version,
                                  'MIN_VERSION = %s' % version)

    # Create upgrade / downgrade scripts.
    schema_diff = 'sh -c "cd ../../../ && make schema_diff"'
    schema_diff_result = os.popen(schema_diff).read()

    migration_fn = '%03d_%s.py' % (version, name)
    upgrade_fn = '%03d_%s_upgrade.sql' % (version, name)
    downgrade_fn = '%03d_%s_downgrade.sql' % (version, name)

    file('__init__.py', 'w').write(conf_file)
    file(migration_fn, 'w').write(MIGRATION_FILE_TEMPLATE)
    file(upgrade_fn, 'w').write(UPGRADE_FILE_TEMPLATE + schema_diff_result)
    file(downgrade_fn, 'w').write(DOWNGRADE_FILE_TEMPLATE + schema_diff_result)

    os.system('%s %s %s' % (editor, upgrade_fn, downgrade_fn))
    os.system('git add __init__.py')
    os.system('git add %s' % migration_fn)
    os.system('git add %s' % upgrade_fn)
    os.system('git add %s' % downgrade_fn)


if __name__ == '__main__':
    try:
        name = sys.argv[1]
        editor = 'vim'
        if len(sys.argv) > 2:
            editor = sys.argv[2]
    except IndexError:
        print 'Usage: ./new_version.py version_name [editor]'
        sys.exit(1)
    new_version(name, editor)
