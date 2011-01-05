import unittest

from ututi.tests import UtutiErrorsLayer
from ututi.tests.functional import collect_ftests

def test_suite():
    return unittest.TestSuite([collect_ftests(exclude=["real_import_smoke_test.txt", "errors.txt", "forum_paging.txt"]),
                               collect_ftests(filenames=["errors.txt"], layer=UtutiErrorsLayer),
                               collect_ftests(filenames=["real_import_smoke_test.txt", "forum_paging.txt"],
                                              level=2)])
