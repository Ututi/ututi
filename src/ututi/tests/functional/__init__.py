# -*- encoding: utf-8 -*-
import os
import unittest
import re
import subprocess
import shutil
from zope.testing.renormalizing import RENormalizing
from datetime import date

from pkg_resources import resource_string, resource_stream
import pylons.test

import doctest

from nous.mailpost import processEmailAndPost

import ututi
from ututi.tests.data import create_user
from ututi.lib.mailer import mail_queue
from ututi.model.events import Event
from ututi.model import (Group, meta, LocationTag, SimpleTag, User, Teacher,
                         Subject, Email, Region)

def ftest_setUp(test):
    ututi.tests.setUp(test)

    # U-niversity and D-epartment
    # should be used in writing new functional tests

    uni = LocationTag(u'U-niversity', u'uni', u'', member_policy='PUBLIC')
    dep = LocationTag(u'D-epartment', u'dep', u'', uni, member_policy='PUBLIC')
    meta.Session.add(uni)
    meta.Session.add(dep)
    meta.Session.commit()

    # Admin user, named 'Adminas Adminovix' for backward compatibility
    create_user('Adminas Adminovix', 'admin@uni.ututi.com', 'xnIVufqLhFFcgX+XjkkwGbrY6kBBk0vvwjA7', 'uni')

    # Below are old locations, users, groups and subjects for backward compatibility
    # Note: objects that didn't have their location specified are now assigned to U-niversity

    vu = LocationTag(u'Vilniaus universitetas', u'vu', u'Seniausias universitetas Lietuvoje.',
                     member_policy='PUBLIC')
    ef = LocationTag(u'Ekonomikos fakultetas', u'ef', u'', vu, member_policy='PUBLIC')
    gf = LocationTag(u'Geografijos fakultetas', u'gf', u'', vu, member_policy='PUBLIC')
    meta.Session.add(vu)
    meta.Session.add(ef)
    meta.Session.add(gf)

    region = Region(u'Mazowieckie', u'lt')
    meta.Session.add(region)

    # Users:

    first = User(u'Alternative user', 'user@ututi.lt', uni, 'password', True)
    meta.Session.add(first)
    email = Email('user@ututi.lt')
    email.confirmed = True
    first.emails.append(email)

    second = User(u'Second user', 'user2@ututi.lt', uni, 'password', True)
    meta.Session.add(second)
    email = Email('user2@ututi.lt')
    email.confirmed = True
    second.emails.append(email)
    second.phone_number = '+37067412345'
    second.phone_confirmed = True

    admin = User.get('admin@uni.ututi.com', uni)
    admin.phone_number = '+37067812375'
    admin.phone_confirmed = True

    # Third user has hist email uncofirmed
    third = User(u'Third user', 'user3@ututi.lt', uni, 'password', True)
    meta.Session.add(third)
    email = Email('user3@ututi.lt')
    email.confirmed = False
    third.emails.append(email)

    # A verified teacher Benas
    benas = Teacher(fullname=u'Benas',
                    username='benas@ututi.lt',
                    location=uni,
                    password='password',
                    gen_password=True)
    benas.teacher_verified = True
    meta.Session.add(benas)
    email = Email('benas@ututi.lt')
    email.confirmed = True
    benas.emails.append(email)

    # Groups:

    meta.Session.execute("SET LOCAL ututi.active_user TO %d" % admin.id)

    moderators = Group('moderators', u'Moderatoriai', uni, date(date.today().year, 1, 1), u'U2ti moderatoriai.')
    meta.Session.add(moderators)

    moderators.add_member(admin, True)
    moderators.add_member(third)

    testgroup = Group('testgroup', u'Testing group', LocationTag.get(u'vu'), date(date.today().year, 1, 1), u'Testing group')
    meta.Session.add(testgroup)
    testgroup.mailinglist_enabled = False
    testgroup.add_member(admin, True)
    testgroup.add_member(second)

    # Subjects:

    math = Subject(u'mat_analize', u'Matematin\u0117 analiz\u0117', LocationTag.get(u'vu'), u'prof. E. Misevi\u010dius')
    meta.Session.add(math)
    third.watchSubject(math)

    # Tags:

    tag = SimpleTag(u'simple_tag')
    meta.Session.add(tag)

    meta.Session.commit()


def collect_ftests(package=None, level=None,
                   layer=ututi.tests.UtutiLayer,
                   filenames=None, exclude=None,
                   setUp=ftest_setUp, tearDown=ututi.tests.tearDown):
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
    suites = []
    checker = RENormalizing([
            (re.compile('[0-9]*[.][0-9]* seconds'), '0.000 seconds'),
            (re.compile('[0-9]* second[s]* ago'), '0 seconds ago'),
            ])
    optionflags = (doctest.ELLIPSIS | doctest.REPORT_NDIFF |
                   doctest.NORMALIZE_WHITESPACE |
                   doctest.REPORT_ONLY_FIRST_FAILURE)
    for n, filename in enumerate(filenames):
        suite = doctest.DocFileSuite(filename,
                                     package=package,
                                     optionflags=optionflags,
                                     checker=checker,
                                     setUp=setUp,
                                     tearDown=tearDown)

        if isinstance(layer, list):
            suite.layer = layer[n % len(layer)]
        else:
            suite.layer = layer

        if level is not None:
            suite.level = level
        suites.append(suite)
    return unittest.TestSuite(suites)


def listUploads(files_path=None):
    if files_path is None:
        files_path = pylons.test.pylonsapp.config['files_path']
    for dir_name, subdirs, files in os.walk(files_path):
        if files:
            for file_name in files:
                full_name = os.path.join(dir_name, file_name)
                print full_name.replace(files_path, "/uploads")


def send_test_message(email_file, message_id='', to='', reply_to=None, subject=''):
    message = resource_string("ututi.tests.functional.emails", email_file)
    if reply_to is not None:
        reply_to = "\nIn-Reply-To: <%s>" % reply_to
    else:
        reply_to = ''

    if message_id or to or reply_to:
        message = message % {'message_id': message_id,
                             'to': to,
                             'reply_to': reply_to,
                             'subject': subject}

    processEmailAndPost('http://localhost/got_mail',
                        message,
                        pylons.test.pylonsapp.config['files_path'])


def make_file(filename, upload_name=None):
    if upload_name is None:
        upload_name = filename
    stream = resource_stream("ututi.tests.functional.files", filename)
    return (stream, 'text/plain', upload_name)


def dump_database():
    executable = "/usr/lib/postgresql/8.3/bin/pg_dump"
    path = os.path.join(pylons.test.pylonsapp.config['global_conf']['here'], 'instance/var/run')
    os.environ["PGPORT"] = os.environ.get("PGPORT", "4455")

    p = subprocess.Popen([executable, "test", "-Fc", "-O", "-h", path],
                         stdout=subprocess.PIPE)
    shutil.copyfileobj(p.stdout, open("dbdump", "w"))
    shutil.rmtree("files_dump", ignore_errors=True)
    shutil.copytree(pylons.test.pylonsapp.config["files_path"], "files_dump")


def setEventTime(dt):
    for event in meta.Session.query(Event).all():
        event.created = dt
    meta.Session.commit()


def printEmails():
    for email in sorted(mail_queue, key=lambda e: e.recipients):
        print email.recipients
        print email.payload()


def setup_university_export():
    uni = LocationTag.get('uni')
    uni.description = u'U-niversity description'

    for i in ('1', '2', '3'):
        f = LocationTag(u'Faculty ' + i, u'f' + i, u'U-niversity faculty ' + i, uni, member_policy='PUBLIC')
        meta.Session.add(f)

    meta.Session.commit()
