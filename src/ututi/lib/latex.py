import cgi
from StringIO import StringIO
from urllib import urlencode
from webhelpers.html.builder import literal

latex_template = '<img class="latex"'\
                 ' alt="%(latex_alt)s"'\
                 ' src="http://l.wordpress.com/latex.php?bg=ffffff&amp;fg=000000&amp;s=0&amp;%(latex_code)s" />'

def convert_latex_to_html(text):
    return latex_template % {'latex_alt': text,
                             'latex_code': urlencode({'latex': "\\displaystyle " + text.encode('utf-8').replace("&gt;", ">").replace("&lt;", "<")})}

def replace_latex_to_html(text):
    result = StringIO()
    text = text.split('$$')

    x = 1
    for n, snippet in enumerate(text):
        if n % 2 == x:
            if not ('<' in snippet or
                    '>' in snippet or
                    '"' in snippet):
                result.write(convert_latex_to_html(snippet))
            else:
                result.write('$$')
                result.write(snippet)
                x += 1
                x = x % 2
        else:
            result.write(snippet)
    return literal(result.getvalue())
