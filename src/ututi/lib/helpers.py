"""Helper functions

Consists of functions to typically be used within templates, but also
available to Controllers. This module is available to templates as 'h'.
"""

import os

from datetime import timedelta, datetime

from pylons.templating import render_mako_def
from hashlib import md5
import re
import cgi
import lxml

# Import helpers as desired, or define your own, ie:
#from webhelpers.html.tags import checkbox, password
from webhelpers.html.tags import stylesheet_link as orig_stylesheet_link
from webhelpers.html.tags import javascript_link as orig_javascript_link
from webhelpers.html.tags import image, select, radio
from webhelpers.html.tags import link_to as orig_link_to
from webhelpers.html.builder import literal

from webhelpers.html import HTML
from webhelpers.html.tags import convert_boolean_attrs

from ututi.lib.base import u_cache
from ututi.lib.latex import replace_latex_to_html as latex_to_html

from ututi.model.i18n import LanguageText, Language

from pylons.i18n import _

import pytz

from webhelpers.pylonslib import Flash as _Flash
flash = _Flash()

from addhrefs import addhrefs

def javascript_link(*urls, **attrs):
    from pylons import url
    return orig_javascript_link(*map(url, urls), **attrs)

def stylesheet_link(*urls, **attrs):
    from pylons import url
    return orig_stylesheet_link(*map(url, urls), **attrs)

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
    urls = re.findall("http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+~]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+", text)
    return urls

def wall_fmt(text):
    text = '\n<br/>\n'.join(cgi.escape(text).split("\n"))
    text = addhrefs(text)
    return literal(text)

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

def fmt_normaldate(dt):
    """Format date and time for output."""
    from babel import dates
    fmt = "yyyy-MM-dd"
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

def html_strip(html_text):
    doc = lxml.html.fragment_fromstring(html_text, create_parent=True)
    texts = doc.xpath('//text()')
    return ' '.join([text.strip() for text in texts])

def single_line(text):
    if isinstance(text, basestring):
        return text.replace('\n', '').replace('\r', '').strip()

def file_name(string):
    resultstring = '';
    MaxLength = 35; 
    if len(string) > MaxLength:
        resultstring = string[:MaxLength]+"...";
    else:
        resultstring = string
        
    return resultstring

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
    kwargs.setdefault('type', 'text')
    return HTML.div(class_='formField',
                    id='%s-field' % kwargs['id'],
                    c=[HTML.label(for_=name, c=[
                    HTML.span(class_='labelText', c=[title]),
                    HTML.span(class_='textField', c=[
                            HTML.input(value=value, name_=name, **kwargs),
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

def input_psw(name, title, value='', help_text=None, right_next=None, **kwargs):
    kwargs['type'] = 'password'
    return input_line(name, title, value, help_text, right_next, **kwargs)

def input_area(name, title, value='', cols='50', rows='5', help_text=None, disabled=False, **kwargs):
    expl = None
    if help_text is not None:
        expl = HTML.span(class_='helpText', c=help_text)
    if disabled:
        kwargs['disabled'] = 'disabled'
    kwargs.setdefault('id', name)

    return HTML.div(class_='formField',
                    id='%s-field' % kwargs['id'],
                    c=[HTML.label(for_=name, c=[
                    HTML.span(class_='labelText', c=[title]),
                    HTML.span(class_='textField', c=[
                        HTML.textarea(name_=name, cols=cols, rows=rows, c=[value], **kwargs),
                        ])]),
                    HTML.literal('<form:error name="%s" />' % name),
                    expl])

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

    if 'class_' in kwargs:
        kwargs['class_'] += ' submit'
    else:
        kwargs['class_'] = 'submit'
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

def checkbox(label, name, checked=False, **kwargs):
    kwargs['type'] = 'checkbox'
    kwargs['name'] = name
    if checked:
        kwargs['checked'] = 'checked'
    kwargs.setdefault('id', name)
    return HTML.div(class_='formField checkbox',
                    id='%s-field' % kwargs['id'],
                    c=[HTML.label(for_=name, c=[
                    HTML.input(**kwargs),
                    HTML.span(class_='labelText', c=[label])
                    ]),
                    HTML.literal('<form:error name="%s" />' % name)])

def member_policy_select(label, name='member_policy'):
    from ututi.model import LocationTag
    label_texts = {
        'RESTRICT_EMAIL':
         _("Only people with confirmed university email can register"),
        'ALLOW_INVITES':
         _("People with confirmed university email can register and other can be invited"),
        'PUBLIC':
         _("Everyone can register to this university"),
    }
    radios = [(policy, label_texts.get(policy, policy)) \
               for policy in LocationTag.member_policies]
    # the idea is that available member_policies 
    # are defined in LocationTag and here only labels are added.
    return select_radio(name, label, radios)

def country_select(label, name='country', empty_name=None):
    from ututi.model.i18n import Country
    options = [(country.id, country.name) for country in Country.all()]
    if empty_name:
        options.insert(0, ('', empty_name))
    return select_line(name, label, options)

def link_to(label, url='', max_length=None, **attrs):
    if max_length is not None:
        attrs['title'] = label
        label = ellipsis(label, max_length)

    return orig_link_to(label, url, **attrs)

def mail_to(email, **attrs):
    return link_to (email, 'mailto:' + email, **attrs)

def url_for(*args, **kwargs):
    from pylons import url
    return url.current(*args, **kwargs)

@u_cache(expire=300, query_args=True, invalidate_on_startup=True)
def users_online(limit=12):
    from ututi.model import User, meta
    five_mins = timedelta(0, 300)
    users = meta.Session.query(User)\
            .filter(User.last_seen > datetime.utcnow() - five_mins)\
            .limit(limit).all()
    return [{'id': user.id,
             'title': user.fullname,
             'url': user.url(),
             'logo_url': user.url(action='logo', width=45),
             'logo_small_url': user.url(action='logo', width=30)}
            for user in users]

@u_cache(expire=3600, query_args=True, invalidate_on_startup=True)
def location_members(location_id, limit=6):
    from ututi.model import Tag, User, meta
    location = Tag.get(int(location_id))
    ids = [t.id for t in location.flatten]
    members = meta.Session.query(User).filter(User.location_id.in_(ids)).order_by(User.last_seen.desc()).limit(limit).all()
    return [{'id': member.id,
             'title': member.fullname,
             'url': member.url(),
             'logo_url': member.url(action='logo', width=45),
             'logo_small_url': member.url(action='logo', width=30)}
            for member in members]

@u_cache(expire=3600, query_args=True, invalidate_on_startup=True)
def location_teachers(location_id):
    from ututi.model import LocationTag, Teacher, meta
    location = LocationTag.get(int(location_id))
    ids = [t.id for t in location.flatten]
    teachers = meta.Session.query(Teacher)\
            .filter(Teacher.location_id.in_(ids))\
            .order_by(Teacher.fullname).all()
    return [{'name': teacher.fullname,
             'url': teacher.url()} for teacher in teachers]

@u_cache(expire=3600, query_args=True, invalidate_on_startup=True)
def subject_followers(subject_id, limit=6):
    from ututi.model import UserSubjectMonitoring, meta
    watches = meta.Session.query(UserSubjectMonitoring).filter_by(subject_id=subject_id, ignored=False)
    return [{'id': watch.user.id,
             'title': watch.user.fullname,
             'url': watch.user.url(),
             'logo_url': watch.user.url(action='logo', width=45),
             'logo_small_url': watch.user.url(action='logo', width=30)}
            for watch in watches]

@u_cache(expire=3600, query_args=True, invalidate_on_startup=True)
def location_latest_groups(location_id, limit=6):
    from ututi.model import Tag, Group, meta
    location = Tag.get(int(location_id))
    ids = [t.id for t in location.flatten]
    groups =  meta.Session.query(Group).filter(Group.location_id.in_(ids)).order_by(Group.created_on.desc()).limit(limit).all()
    return [{'id': group.group_id,
             'title': group.title,
             'url': group.url(),
             'logo_url': group.url(action='logo', width=45),
             'logo_small_url': group.url(action='logo', width=30)}
            for group in groups]


@u_cache(expire=3600, query_args=True, invalidate_on_startup=True)
def location_count(location_id, object_type=None):
    from ututi.model import Tag
    location = Tag.get(int(location_id))
    return location.count(object_type)

@u_cache(expire=3600, query_args=True, invalidate_on_startup=True)
def group_members(group_id, limit=6):
    from ututi.model import Group
    group = Group.get(int(group_id))
    members = group.members[:limit]

    return [{'id': member.user_id,
             'title': member.user.fullname,
             'url': member.user.url(),
             'logo_url': member.user.url(action='logo', width=45),
             'logo_small_url': member.user.url(action='logo', width=30)}
            for member in members]

@u_cache(expire=3600, invalidate_on_startup=True)
def group_members_count(group_id):
    from ututi.model import meta, GroupMember
    return meta.Session.query(GroupMember).filter_by(group_id=group_id).count()

@u_cache(expire=3600, invalidate_on_startup=True)
def group_subjects(group_id):
    from ututi.model import meta, GroupSubjectMonitoring
    return meta.Session.query(GroupSubjectMonitoring).filter_by(group_id=group_id).count()

@u_cache(expire=3600, invalidate_on_startup=True)
def item_file_count(item_id):
    from ututi.model import meta, File
    return meta.Session.query(File).filter_by(parent_id=item_id).count()

@u_cache(expire=3600, invalidate_on_startup=True)
def subject_page_count(subject_id):
    from ututi.model import Subject
    return len(Subject.get_by_id(subject_id).pages)

@u_cache(expire=3600, invalidate_on_startup=True)
def authorship_count(obj, user_id):
    from ututi.model import meta, File, Page
    obj_types = {
        'file' : File,
        'page' : Page,
        }
    obj = obj_types[obj.lower()]
    return meta.Session.query(obj).filter(obj.created_by == user_id).count()

@u_cache(expire=3600, invalidate_on_startup=True)
def teacher_subjects(teacher_id):
    from ututi.model import Teacher
    return len(Teacher.get_global(teacher_id).taught_subjects)

@u_cache(expire=3600, invalidate_on_startup=True)
def teacher_groups(teacher_id):
    from ututi.model import meta, TeacherGroup
    return meta.Session.query(TeacherGroup).filter(TeacherGroup.teacher_id == teacher_id).count()

@u_cache(expire=24*3600, query_args=True, invalidate_on_startup=True)
def related_users(user_id, location_id, limit=6):
    from ututi.model import User
    users = {}
    counts = {}
    user = User.get(user_id, location_id)
    # group mates
    for group in user.groups:
        for member in group.members:
            id = member.user.id
            counts.setdefault(id, 0)
            counts[id] += 1
            users[id] = member.user
    # subject followers
    for subject in user.watched_subjects:
        for monitor in subject.watching_users:
            id = monitor.user.id
            counts.setdefault(id, 0)
            counts[id] += 1
            users[id] = monitor.user
    # remove self
    if user.id in counts: del counts[user.id]
    if user.id in users: del users[user.id]
    # sort by counts
    pairs = [(counts[id], users[id]) for id in users.keys()]
    pairs.sort()
    pairs.reverse()
    pairs = pairs[:limit]

    return [{'id': user.id,
             'title': user.fullname,
             'url': user.url(),
             'logo_url': user.url(action='logo', width=45),
             'logo_small_url': user.url(action='logo', width=30)}
            for count, user in pairs]

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

@u_cache(expire=3600, query_args=True, invalidate_on_startup=True)
def get_languages():
    from ututi.model import meta
    langs = meta.Session.query(Language).order_by(Language.title).all()
    return [(lang.id, lang.title) for lang in langs]

def user_done_items(user):
    """Returns which actions user has done."""
    from ututi.model import UserRegistration, meta
    items = []
    if meta.Session.query(UserRegistration)\
       .filter_by(inviter=user).count() > 0:
        items.append('invitation')
    if len(user.groups) > 0:
        items.append('group')
    if len(user.watched_subjects) > 0:
        items.append('subject')
    if user.description or user.site_url or user.phone_number:
        items.append('profile')
    return items

def teacher_done_items(user):
    """Returns which actions teacher has done."""
    items = []
    if user.teacher_position or user.site_url \
       or user.phone_number or user.work_address:
        items.append('profile')
    if user.description:
        items.append('information')
    if user.publications:
        items.append('publications')
    if len(user.student_groups) > 0:
        items.append('group')
    if len(user.taught_subjects) > 0:
        items.append('subject')
    return items

def user_todo_items(user):
    from pylons import url
    todo_items = []
    done = user_done_items(user)
    todo_items.append({
        'title': _("Invite others to join"),
        'link': url(controller='profile', action='invite_friends_fb'),
        'done': 'invitation' in done })
    todo_items.append({
        'title': _("Join / create a group"),
        'link': url(controller='group', action='create'),
        'done': 'group' in done })
    todo_items.append({
        'title': _("Find / create your subjects"),
        'link': url(controller='profile', action='watch_subjects'),
        'done': 'subject' in done })
    todo_items.append({
        'title': _("Fill profile information"),
        'link': url(controller='profile', action='edit'),
        'done': 'profile' in done })

    return todo_items

def teacher_todo_items(user):
    from pylons import url
    todo_items = []
    done = teacher_done_items(user)
    todo_items.append({
        'title': _("Fill profile information"),
        'link': url(controller='profile', action='edit'),
        'done': 'profile' in done })
    todo_items.append({
        'title': _("Find / create your subjects"),
        'link': url(controller='subject', action='add'),
        'done': 'subject' in done })
    todo_items.append({
        'title': _("Add your information"),
        'link': url(controller='profile', action='edit_information'),
        'done': 'information' in done })
    todo_items.append({
        'title': _("List your publications"),
        'link': url(controller='profile', action='edit_publications'),
        'done': 'publications' in done })
    todo_items.append({
        'title': _("Add your student groups"),
        'link': url(controller='profile', action='add_student_group'),
        'done': 'group' in done })

    return todo_items

@u_cache(expire=3600, invalidate_on_startup=True)
def content_link(content_id):
    from ututi.model import ContentItem, Subject, Group, Page, File, PrivateMessage, ForumPost
    from ututi.model.mailing import GroupMailingListMessage
    from pylons import url
    item = ContentItem.get(content_id)
    if type(item) == ForumPost:
        # we don't want to link to forum posts anymore
        return item.title
    if type(item) in [Subject, Group, Page]:
        if item.deleted_on is None:
            return link_to(item.title, url(controller='content', action='get_content', id=content_id))
        else:
            return item.title
    elif type(item) == File:
        return link_to(item.filename, url(controller='content', action='get_content', id=content_id))
    elif type(item) in [PrivateMessage, GroupMailingListMessage]:
        return link_to(item.subject, url(controller='content', action='get_content', id=content_id))

@u_cache(expire=3600, invalidate_on_startup=True)
def location_link(location_id):
    from ututi.model import LocationTag

    location = LocationTag.get_by_id(location_id)
    return link_to(location.title, location.url())

@u_cache(expire=3600, invalidate_on_startup=True)
def user_link(user_id):
    from ututi.model.users import AnonymousUser
    if type(user_id) in (int, long):
        from ututi.model.users import Author
        from pylons import url
        user = Author.get_byid(user_id)
        return link_to(user.fullname, url(controller='content', action='get_user', id=user_id))
    elif type(user_id) == AnonymousUser:
        return link_to(user_id.fullname, 'mailto:%s' % user_id.email)

def thread_reply_dict(obj):
    """Create a universal thread reply dict from an event."""
    if type(obj) == dict:
        return dict(
            id = obj['comment_id'],
            author_id = obj['author_id'],
            message= obj['message'],
            created_on = obj['created_on'])

    if obj.event_type == 'mailinglist_post_created':
        return dict(
            id = obj.id,
            author_id = obj.author_id,
            message = obj.ml_message,
            created_on = obj.created,
            attachments = obj.attachments if hasattr(obj, 'attachments') else []
            )
    elif obj.event_type == 'forum_post_created':
        return dict(
            id = obj.id,
            author_id = obj.author_id,
            message = obj.fp_message,
            created_on = obj.created)

def simple_declension(word, case='gen', lang='en'):
    """Extremely naive declension for university names.
    """
    if lang == 'lt' and case == 'gen':
        if word.endswith('as'):
            return u"%so" % word[:-2]
        return u"%sos" % word[:-1]
    return word

def get_university_stats(location):
        """Sets statistic about selected university"""
        from ututi.model import Subject, Group, Teacher

        return {'total_teachers': location.count(Teacher),
                'total_subjects': location.count(Subject),
                'total_groups': location.count(Group)}
