"""Helper functions

Consists of functions to typically be used within templates, but also
available to Controllers. This module is available to templates as 'h'.
"""

import os
from pylons.templating import render_mako_def
from hashlib import md5
import re
import cgi

# Import helpers as desired, or define your own, ie:
#from webhelpers.html.tags import checkbox, password
from webhelpers.html.tags import stylesheet_link, javascript_link, image, select, radio
from webhelpers.html.tags import link_to as orig_link_to
from webhelpers.html.builder import literal

from webhelpers.html import HTML
from webhelpers.html.tags import convert_boolean_attrs

from ututi.lib.base import u_cache
from ututi.lib.latex import replace_latex_to_html as latex_to_html

from ututi.model.i18n import LanguageText

from pylons.i18n import _

import pytz


from webhelpers.pylonslib import Flash as _Flash
flash = _Flash()


def button_to(title, url='', **html_options):
    """Generate a form containing a sole button that submits to
    ``url``.

    Use this method instead of ``link_to`` for actions that do not have
    the safe HTTP GET semantics implied by using a hypertext link.

    The parameters are the same as for ``link_to``.  Any
    ``html_options`` that you pass will be applied to the inner
    ``input`` element. In particular, pass

        disabled = True/False

    as part of ``html_options`` to control whether the button is
    disabled.  The generated form element is given the class
    'button-to', to which you can attach CSS styles for display
    purposes.

    The submit button itself will be displayed as an image if you
    provide both ``type`` and ``src`` as followed:

         type='image', src='icon_delete.gif'

    The ``src`` path should be the exact URL desired.  A previous version of
    this helper added magical prefixes but this is no longer the case.

    Example 1::

        # inside of controller for "feeds"
        >> button_to("Edit", url(action='edit', id=3))
        <form method="POST" action="/feeds/edit/3" class="button-to">
        <div><input value="Edit" type="submit" /></div>
        </form>

    Example 2::

        >> button_to("Destroy", url(action='destroy', id=3),
        .. method='DELETE')
        <form method="POST" action="/feeds/destroy/3"
         class="button-to">
        <div>
            <input type="hidden" name="_method" value="DELETE" />
            <input value="Destroy" type="submit" />
        </div>
        </form>

    Example 3::

        # Button as an image.
        >> button_to("Edit", url(action='edit', id=3), type='image',
        .. src='icon_delete.gif')
        <form method="POST" action="/feeds/edit/3" class="button-to">
        <div><input alt="Edit" src="/images/icon_delete.gif"
         type="image" value="Edit" /></div>
        </form>

    .. note::
        This method generates HTML code that represents a form. Forms
        are "block" content, which means that you should not try to
        insert them into your HTML where only inline content is
        expected. For example, you can legally insert a form inside of
        a ``div`` or ``td`` element or in between ``p`` elements, but
        not in the middle of a run of text, nor can you place a form
        within another form.
        (Bottom line: Always validate your HTML before going public.)

    """

    if html_options:
        convert_boolean_attrs(html_options, ['disabled'])

    method_tag = ''
    method = html_options.pop('method', '')
    if method.upper() in ['PUT', 'DELETE']:
        method_tag = HTML.input(
            type='hidden', id='_method', name_='_method', value=method)

    form_method = (method.upper() == 'GET' and method.lower()) or 'post'

    url, title = url, title or url

    submit_type = html_options.get('type')
    img_source = html_options.get('src')
    if submit_type == 'image' and img_source:
        html_options["value"] = title
        html_options.setdefault("alt", title)
    else:
        html_options["type"] = "submit"
        html_options["value"] = title

    html_options.setdefault('class_', "btn")
    return HTML.form(method=form_method, action=url, class_="button-to",
                     c=[HTML.fieldset(c=[method_tag, HTML.button(c=[HTML.span(title)], **html_options)])])


def get_urls(text):
    urls = re.findall("http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+",text)
    return urls


def ellipsis(text, max=20):
    if len(text) > max:
        return text[0:max-3] + '...'
    else:
        return text

from ututi.lib.security import check_crowds


def selected_item(items):
    for item in items:
        if item.get('selected', False):
            return item


def unselected_items(items):
    return [item for item in items if not item.get('selected', False)]


def marked_list(items):
    items[-1]['last_item'] = True
    return items


def get_timezone():
    from pylons import tmpl_context
    tz = tmpl_context.timezone
    return pytz.timezone(tz)


def get_locale():
    from pylons import tmpl_context
    return tmpl_context.locale


def fmt_dt(dt):
    """Format date and time for output."""
    from babel import dates
    fmt = "yyyy MMM dd, HH:mm"
    localtime = pytz.utc.localize(dt).astimezone(get_timezone())
    return dates.format_datetime(localtime, fmt, locale=get_locale())


def fmt_shortdate(dt):
    """Format date and time for output."""
    from babel import dates
    fmt = "MMM dd, HH:mm"
    localtime = pytz.utc.localize(dt).astimezone(get_timezone())
    return dates.format_datetime(localtime, fmt, locale=get_locale())


def nl2br(text):
    return literal('<br/>'.join(cgi.escape(text).split("\n")))


EXPAND_QUOTED_TEXT_LINK = ('<a class="expand-quote" href="#">[...]</a>'
                           '<div class="quote" style="display: none">')

def wraped_text(text, max_length = 10, break_symbol = "<br />"):
    """Returning text separated with breaks"""
    words = text.split()

    #TODO: add short words join if they are not exceeding max_length
    word_pairs = []
    for i, word in enumerate(words):
        if i != 0 and len(words[i-1]) + len(word) < max_length:
            words[i] = words[i-1] + " " + word
            words.remove(words[i-1])

    splited_text = []
    for word in words:
        step = 0
        while step < len(word):
            part = word[step:(max_length+step)]
            step += max_length
            splited_text.append(part)
            splited_text.append(break_symbol)
    splited_text.pop() #removing last break
    return literal(''.join(splited_text))

def email_with_replies(text, omit=False):
    lines = cgi.escape(text).split("\n")
    # First preprocessing stage: remove consecutive newlines.
    cleaned_lines = []
    last_empty = False
    for line in list(lines):
        empty_line = not line.replace('&gt;', '').strip()
        if not empty_line or not last_empty:
            cleaned_lines.append(line)
        last_empty = empty_line

    # TODO: find and mark emails quoted without > and with full headers.

    cleaned_lines.append('') # Makes it easier to deal with end-conditions.
    result = []
    in_quote = False
    for line in cleaned_lines:
        line_is_quoted = line.strip().startswith('&gt;')
        if not in_quote and line_is_quoted:
            # Quote started.
            in_quote = True
            # Eat empty line (if any) above.
            # There shouldn't be several empty lines because of the filter above.
            if result and not result[-1].strip():
                del result[-1]
            if not result:
                result.append('')
            if not omit:
                result[-1] += ' ' + EXPAND_QUOTED_TEXT_LINK
        elif in_quote and not line_is_quoted:
            # Quote ended.
            in_quote = False
            if not omit:
                result[-1] += '</div>'
            if line:
                result.append('')
        if not in_quote or not omit:
            result.append(line)
    return literal('<br />'.join(result))


def html_cleanup(*args, **kwargs):
    from ututi.lib.validators import html_cleanup
    return literal(html_cleanup(*args, **kwargs))


def file_size(size):
    suffixes = [("", 2**10),
                ("k", 2**20),
                ("M", 2**30),
                ("G", 2**40),
                ("T", 2**50)]
    for suf, lim in suffixes:
        if size >= lim:
            continue
        elif size % (lim // 2**10) == 0:
            return "%s %sB" % (size // (lim // 2**10), suf)
        else:
            return "%s %sB" % (round(size / float(lim // 2**10), 2), suf)


def trackEvent(obj, action, label, category='navigation'):
    # _trackEvent(category, action, optional_label, optional_value)
    return literal("""onclick="_gaq.push(['_trackEvent', '%s', '%s', '%s']);" """ % (
            category,
            action,
            label))


def input_line(name, title, value='', help_text=None, right_next=None, **kwargs):
    expl = None
    if help_text is not None:
        expl = HTML.span(class_='helpText', c=help_text)
    next = None
    if right_next is not None:
        next = HTML.span(class_='rightNext', c=right_next)

    kwargs.setdefault('id', name)
    return HTML.div(class_='formField',
                    id='%s-field' % kwargs['id'],
                    c=[HTML.label(for_=name, c=[
                    HTML.span(class_='labelText', c=[title]),
                    HTML.span(class_='textField', c=[
                            HTML.input(type='text', value=value, name_=name, **kwargs),
                            ])]),
                       next,
                       HTML.literal('<form:error name="%s" />' % name),
                       expl])

def select_line(name, title, options, selected=[], help_text=None, right_next=None, **kwargs):
    expl = None
    if help_text is not None:
        expl = HTML.span(class_='helpText', c=help_text)
    next = None
    if right_next is not None:
        next = HTML.span(class_='rightNext', c=right_next)

    kwargs.setdefault('id', name)
    field = select(name, selected, options, **kwargs)
    return HTML.div(class_='formField',
                    id='%s-field' % kwargs['id'],
                    c=[HTML.label(for_=name, c=[
                    HTML.span(class_='labelText', c=[title]),
                    HTML.span(class_='textField', c=[
                            field,
                            ])]),
                       next,
                       HTML.literal('<form:error name="%s" />' % name),
                       expl])

def select_radio(name, title, options, selected=[], help_text=None, **kwargs):
    expl = None
    if help_text is not None:
        expl = HTML.span(class_='helpText', c=help_text)

    radios = []
    for value, label in options:
        checked = value in selected
        radios.append(radio(name, value, checked, label, **kwargs))

    return HTML.div(class_='formField',
                    id='%s-field' % name,
                    c=[HTML.label(for_=name, c=[
                    HTML.span(class_='labelText', c=[title]),
                    HTML.span(class_='radioField', c=radios)]),
                       HTML.literal('<form:error name="%s" />' % name),
                       expl])

def input_hidden(name, value='', **kwargs):
    kwargs.setdefault('id', name)
    return HTML.div(class_='formField',
                    id='%s-field' % kwargs['id'],
                    c=[HTML.input(type='hidden', value=value, name_=name, **kwargs),
                       HTML.literal('<form:error name="%s" />' % name)])

def input_psw(name, title, value='', help_text=None, **kwargs):
    expl = None
    if help_text is not None:
        expl = HTML.span(class_='helpText', c=help_text)

    kwargs.setdefault('id', name)
    return HTML.div(class_='formField',
                    id='%s-field' % kwargs['id'],
                    c=[HTML.label(for_=name, c=[
                    HTML.span(class_='labelText', c=[title]),
                    HTML.span(class_='textField', c=[
                            HTML.input(type='password', name_=name, value='', **kwargs),
                            ])]),
                       HTML.literal('<form:error name="%s" />' % name),
                       expl])


def input_area(name, title, value='', cols='50', rows='5', help_text=None, disabled=False, **kwargs):
    expl = None
    if help_text is not None:
        expl = HTML.span(class_='helpText', c=help_text)
    kwargs = {}
    if disabled:
        kwargs['disabled'] = 'disabled'

    return HTML.label(c=[
        HTML.span(class_='labelText', c=[title]),
        HTML.span(class_='textField', c=[
            HTML.textarea(name_=name, id_=name, cols=cols, rows=rows, c=[value], **kwargs),
            ]),
        expl,
        HTML.literal('<form:error name="%s" />' % name)])


def input_wysiwyg(name, title, value='', cols='60', rows='15'):
    return HTML.div(class_='form-field', c=[
            HTML.label(for_=name, c=[title]),
            HTML.textarea(class_='ckeditor', name_=name, id_=name, cols=cols, rows=rows, c=[value]),
            HTML.literal('<form:error name="%s" />' % name)
            ])


def input_submit(text=None, name=None, **kwargs):
    if text is None:
        from pylons.i18n import _
        text = _('Save')
    if name is not None:
        kwargs['name'] = name

    kwargs.setdefault('class_', "submit")
    kwargs.setdefault('value', text)
    return HTML.button(c=text, **kwargs)

def input_submit_text_button(text=None, name=None, **html_options):
    if text is None:
        from pylons.i18n import _
        text = _('Save')
    if name is not None:
        html_options['name'] = name

    html_options.setdefault('class_', "btn-text")
    html_options.setdefault('value', text)
    return HTML.button(c=[HTML.span(text)], **html_options)

def link_to(label, url='', max_length=None, **attrs):
    if max_length is not None:
        attrs['title'] = label
        label = ellipsis(label, max_length)

    return orig_link_to(label, url, **attrs)

def url_for(*args, **kwargs):
    from pylons import url
    return url.current(*args, **kwargs)


@u_cache(expire=3600, query_args=True, invalidate_on_startup=True)
def location_latest_groups(location_id, limit=5):
    from ututi.model import Tag, Group, meta
    location = Tag.get(int(location_id))
    ids = [t.id for t in location.flatten]
    grps =  meta.Session.query(Group).filter(Group.location_id.in_(ids)).order_by(Group.created_on.desc()).limit(limit).all()
    return [{'logo': group.logo,
             'url': group.url(),
             'title': group.title,
             'group_id': group.group_id,
             'member_count': len(group.members)}
            for group in grps]


@u_cache(expire=3600, query_args=True, invalidate_on_startup=True)
def location_count(location_id, object_type=None):
    from ututi.model import Tag
    location = Tag.get(int(location_id))
    return location.count(object_type)


@u_cache(expire=3600, invalidate_on_startup=True)
def group_members(group_id):
    from ututi.model import meta, GroupMember
    return meta.Session.query(GroupMember).filter_by(group_id=group_id).count()


@u_cache(expire=3600, invalidate_on_startup=True)
def subject_file_count(subject_id):
    from ututi.model import meta, File
    return meta.Session.query(File).filter_by(parent_id=subject_id).count()

@u_cache(expire=3600, invalidate_on_startup=True)
def subject_page_count(subject_id):
    from ututi.model import Subject
    return len(Subject.get_by_id(subject_id).pages)


def path_with_hash(fn):
    from pylons import config
    assert fn.startswith('/'), fn
    file_path = os.path.join(config['pylons.paths']['static_files'], fn[1:])
    digest = md5(file(file_path).read()).hexdigest()
    return '%s?hash=%s' % (fn, digest)

def coupons_available(user):
    from ututi.model import meta, GroupCoupon
    return meta.Session\
        .query(GroupCoupon)\
        .filter(~GroupCoupon.id.in_([coup.id for coup in user.coupons]))\
        .all()

def object_link(object):
    """Render a complete link to an object, dispatching on object type."""
    from ututi.model import Subject, Group, User, File, ForumPost, Page, PrivateMessage
    from ututi.model.users import AnonymousUser
    from ututi.model.mailing import GroupMailingListMessage
    if type(object) in [Subject, Group, Page]:
        return link_to(object.title, object.url())
    elif isinstance(object, (User, AnonymousUser)):
        return link_to(object.fullname, object.url())
    elif isinstance(object, File):
        return link_to(object.filename, object.url())
    elif type(object) in [GroupMailingListMessage, PrivateMessage]:
        return link_to(object.subject, object.url())
    elif isinstance(object, ForumPost):
        return link_to(object.title, object.url(new=True))

def when(time):
    """Formats now() - time in human readable format."""
    import datetime
    from pylons.i18n import ungettext
    difference = datetime.datetime.utcnow() - time
    if datetime.timedelta(seconds=60) > difference:
        num = difference.seconds
        return ungettext("%(num)s second ago",
                         "%(num)s seconds ago",
                         num) % {'num': num}
    elif datetime.timedelta(seconds=3600) > difference:
        num = difference.seconds / 60
        return ungettext("%(num)s minute ago",
                         "%(num)s minutes ago",
                         num) % {'num': num}
    elif datetime.timedelta(1) > difference:
        num = difference.seconds / 3600
        return ungettext("%(num)s hour ago",
                         "%(num)s hours ago",
                         num) % {'num': num}
    elif datetime.timedelta(5) > difference:
        num = difference.days
        return ungettext("%(num)s day ago",
                         "%(num)s days ago",
                         num) % {'num': num}
    else:
        return time.strftime("%Y-%m-%d")

def get_supporters():
    from ututi.model import get_supporters
    return get_supporters()

def get_i18n_text(text_id):
    from pylons import tmpl_context as c
    text_obj = LanguageText.get(text_id, c.lang)
    if text_obj is None:
        text_obj = LanguageText.get(text_id, 'en')
    if text_obj is None:
        return ''
    return literal(text_obj.text)
