import re
import string
import translitcodec
import trans
import traceback

def urlify(text, maxlen=None):
    """
    Urlify a string by transliterating it, changing all whitespace to dashes and limitting its length to
    the specified number of chars.
    """

    text = text.lower().encode('transliterate')
    text = text.lower().encode('trans/id')

    text = text.encode("ascii", "ignore")

    if maxlen is not None:
        text = text[:maxlen]
    return text


def _split(line):
    part = ""
    line = list(line)
    while line:
        s = line.pop(0)
        if s != ';':
            part += s
            if s == '"':
                prev = ''
                while line:
                    s = line.pop(0)
                    part += s
                    if s == '"' and prev != '\\':
                        break
                    prev = s
            continue
        else:
            yield part
            part = ""
    yield part


def _parse_header(line):
    """Parse a Content-type like header.

    Return the main content-type and a dictionary of options.

    """
    plist = [x.strip() for x in _split(line)]
    key = plist.pop(0).lower()
    pdict = {}
    for p in plist:
        i = p.find('=')
        if i >= 0:
            name = p[:i].strip().lower()
            value = p[i+1:].strip()
            if len(value) >= 2 and value[0] == value[-1] == '"':
                value = value[1:-1]
                value = value.replace('\\\\', '\\').replace('\\"', '"')
            pdict[name] = value
    return key, pdict


def monkeypatch():
    import cgi
    cgi.parse_header = _parse_header
    old_extract_tb = traceback.extract_tb
    def _extract_tb(*args, **kwargs):
        result = old_extract_tb(*args, **kwargs)
        return [(filename, lineno, function, line or '')
                for (filename, lineno, function, line) in result]
    traceback.extract_tb = _extract_tb
