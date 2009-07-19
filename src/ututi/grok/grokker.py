"""Grokking utilites for pylons."""
import martian

the_multi_grokker = martian.MetaMultiGrokker()
the_module_grokker = martian.ModuleGrokker(the_multi_grokker)


def skip_tests(name):
    return name in ['tests', 'ftests']


def grokDirective(_context, package):
    do_grok(package.__name__, _context)


def do_grok(dotted_name, config):
    martian.grok_dotted_name(
        dotted_name, the_module_grokker, exclude_filter=skip_tests,
        config=config
        )
