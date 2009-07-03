import re
"""Helper functions

Consists of functions to typically be used within templates, but also
available to Controllers. This module is available to templates as 'h'.
"""
# Import helpers as desired, or define your own, ie:
#from webhelpers.html.tags import checkbox, password
from routes import url_for
from webhelpers.html.tags import stylesheet_link, javascript_link, image

def get_urls(text):
    urls = re.findall("http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+",text)
    return urls

def ellipsis(text, max = 20):
    if (len(text) > max):
        return text[0:max-3] + '...'
    else:
        return text
