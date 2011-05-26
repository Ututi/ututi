import re
import pkg_resources

css_files = ['books.css',
             'fixed.css',
             'ie.css',
             'layout.css',
             'portlets.css',
             'style.css',
             'widgets.css']

def get_all_rules():
    rules = []
    for css_file in css_files:
        res = pkg_resources.resource_string('ututi', 'public/%s' % css_file)
        res = res.replace('\n', ', ')
        for pattern in [r'{[^{}]*?}',
                        r'{[^{}]*?}',
                        r'/\*.*?\*/']:
            res = re.sub(pattern, '', res)

        for rule in res.split(','):
            for xak in [':hover', ':active', ':visited', ':after', '::-moz-focus-inner',
                        '@media screen and (-webkit-min-device-pixel-ratio:0)']:
                rule = rule.replace(xak, '')
            rule = rule.strip()
            if rule:
                rules.append((css_file, rule))

    return rules
