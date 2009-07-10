import unittest

from ututi.tests.functional import collect_ftests

def test_suite():
    return unittest.TestSuite([collect_ftests(exclude=["real_import_smoke_test.txt", "mailing_list_import.txt"]),
                               collect_ftests(filenames=["real_import_smoke_test.txt", "mailing_list_import.txt"],
                                              level=2)])
