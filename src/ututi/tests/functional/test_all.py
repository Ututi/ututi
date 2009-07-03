import unittest

from ututi.tests.functional import collect_ftests

def test_suite():
    return unittest.TestSuite([collect_ftests(exclude=["real_import_smoke_test.txt"]),
                               collect_ftests(filenames=["real_import_smoke_test.txt"],
                                              level=2)])
