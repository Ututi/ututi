from StringIO import StringIO
from urllib import urlencode

def convert_latex_to_html(text):
    return '<code><img class="latex" alt="" src="http://l.wordpress.com/latex.php?bg=ffffff&amp;fg=000000&amp;s=0&amp;' + urlencode({'latex': "\\displaystyle " + text.replace("&gt;", ">").replace("&lt;", "<")}) + '" /><script type="application/x-latex">' + text + '</script></code>'

def replace_latex_to_html(text):
    result = StringIO()
    text = text.split('$$')

    for n, snippet in enumerate(text):
        if n % 2 == 1:
             if '<' not in snippet:
                 result.write(convert_latex_to_html(snippet))
             else:
                 result.write('$$')
                 result.write(snippet)
                 result.write('$$')
        else:
            result.write(snippet)
    return result.getvalue()
