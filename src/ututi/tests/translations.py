from translate.filters.pofilter import cmdlineparser
from translate.filters.checks import StandardChecker

from translate.filters.checks import CheckerConfig

ututiconfig = CheckerConfig(
    canchangetags = [("a", "title", None),
                     ("img", "alt", None)]
    )

class UtutiChecker(StandardChecker):

    def __init__(self, **kwargs):
        checkerconfig = kwargs.get("checkerconfig", None)
        if checkerconfig is None:
            checkerconfig = CheckerConfig()
            kwargs["checkerconfig"] = checkerconfig
        checkerconfig.update(ututiconfig)
        StandardChecker.__init__(self, **kwargs)


def main():
    parser = cmdlineparser()
    parser.add_option("", "--ututi", dest="filterclass",
        action="store_const", default=None, const=UtutiChecker,
        help="use the standard checks for Ututi translations")

    parser.run()
