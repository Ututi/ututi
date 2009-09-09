import re
import string
import translitcodec
import trans

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
