from lxml.html.clean import Cleaner

def html_cleanup(input):
    cleaner = Cleaner(
        scripts = True,
        javascript = True,
        comments = True,
        style = False,
        links = True,
        meta = True,
        page_structure = True,
        processing_instructions = True,
        embedded = False,
        frames = True,
        forms = True,
        annoying_tags = True,
        allow_tags = ['a', 'img', 'span', 'div'],
        remove_unknown_tags = False,
        safe_attrs_only = True,
        host_whitelist = ['youtube.com', 'google.com'],
        whitelist_tags = ['iframe', 'embed', 'script', 'img']
        )
    return cleaner.clean_html("<div>%s</div>"%input)
