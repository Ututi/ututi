#
import os
import unittest
import subprocess
import shutil
from datetime import date

from pkg_resources import resource_string, resource_stream

from zope.testing import doctest

from pylons import config

from nous.mailpost import processEmailAndPost

import ututi
from ututi.model import Group, meta, LocationTag, User, GroupMember, GroupMembershipType, Subject

def ftest_setUp(test):
    ututi.tests.setUp(test)
    g = Group('moderators', u'Moderatoriai', LocationTag.get(u'vu'), date.today(), u'U2ti moderatoriai.')
    u = User.get('admin@ututi.lt')

    role = GroupMembershipType.get('administrator')
    gm = GroupMember()
    gm.user = u
    gm.group = g
    gm.role = role
    meta.Session.add(g)
    meta.Session.add(gm)

    meta.Session.add(Subject(u'mat_analize', u'Matematin\u0117 analiz\u0117', LocationTag.get(u'vu'), u'prof. E. Misevi\u010dius'))

    meta.Session.commit()


def collect_ftests(package=None, level=None, layer=None, filenames=None,
                   exclude=None):
    """Collect all functional doctest files in a given package.

    If `package` is None, looks up the call stack for the right module.

    Returns a unittest.TestSuite.
    """
    package = doctest._normalize_module(package)
    testdir = os.path.dirname(package.__file__)
    if filenames is None:
        filenames = [fn for fn in os.listdir(testdir)
                     if fn.endswith('.txt') and not fn.startswith('.')]
    if exclude is not None:
        for fn in exclude:
            filenames.remove(fn)
    optionflags = (doctest.ELLIPSIS | doctest.REPORT_NDIFF |
                   doctest.NORMALIZE_WHITESPACE |
                   doctest.REPORT_ONLY_FIRST_FAILURE)
    suites = []
    for filename in filenames:
        suite = doctest.DocFileSuite(filename,
                                     package=package,
                                     optionflags=optionflags,
                                     setUp=ftest_setUp,
                                     tearDown=ututi.tests.tearDown)
        suite.layer = ututi.tests.PylonsLayer
        if level is not None:
            suite.level = level
        suites.append(suite)
    return unittest.TestSuite(suites)


def listUploads(files_path=None):
    if files_path is None:
        files_path = config['files_path']
    for dir_name, subdirs, files in os.walk(files_path):
        if files:
            for file_name in files:
                full_name = os.path.join(dir_name, file_name)
                print full_name.replace(files_path, "/uploads")


def send_test_message(email_file, message_id, to, reply_to=None):
    message = resource_string("ututi.tests.functional.emails", email_file)
    if reply_to is not None:
        reply_to = "\nIn-Reply-To: <%s>" % reply_to
    else:
        reply_to = ''
    processEmailAndPost('http://localhost/got_mail',
                        message % {'message_id': message_id,
                                   'to': to,
                                   'reply_to': reply_to},
                        config['files_path'])


def make_file(filename):
    stream = resource_stream("ututi.tests.functional.import", filename)
    return (stream, 'text/plain', filename)


def import_csv(browser, formname, filename):
    browser.open('http://localhost/admin')
    form = browser.getForm(name=formname)
    form.getControl('CSV File').add_file(*make_file(filename))
    form.getControl('Upload').click()


def dump_database():

    executable = "/usr/lib/postgresql/8.3/bin/pg_dump"
    path = os.path.join(config['global_conf']['here'], 'instance/var/run')
    os.environ["PGPORT"] = os.environ.get("PGPORT", "4455")

    p = subprocess.Popen([executable, "test", "-Fc", "-O", "-h", path],
                         stdout=subprocess.PIPE)
    shutil.copyfileobj(p.stdout, open("dbdump", "w"))
    shutil.rmtree("files_dump", ignore_errors=True)
    shutil.copytree(config["files_path"], "files_dump")
