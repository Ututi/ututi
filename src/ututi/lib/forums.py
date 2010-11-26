from mimetools import choose_boundary

from pylons import url, config
from pylons.i18n import _

from ututi.model import meta, SubscribedThread, ForumPost
from ututi.lib.mailer import send_email
from ututi.lib.base import render
from ututi.model import Group


def _generateMessageId():
    host = config.get('mailing_list_host', '')
    return "%s@%s" % (choose_boundary(), host)


def _send_emails(user, post, group_id=None, category_id=None, controller=''):
    if group_id:
        forum_title = Group.get(group_id).title
    else:
        forum_title = _('Community') if category_id == 1 else _('Bugs')

    thread = ForumPost.get(post.thread_id)
    new_thread = thread.is_thread()
    extra_vars = dict(message=post.message, person_title=user.fullname, forum_title=forum_title,
        thread_url=url(controller=controller, action='thread',
                       id=group_id, category_id=category_id,
                       thread_id=post.thread_id, qualified=True))
    email_message = render('/emails/forum_message.mako',
                           extra_vars=extra_vars)

    recipients = set()
    for subscription in thread.subscriptions:
        if subscription.active and subscription.user.id != user.id:
            for email in subscription.user.emails:
                if email.confirmed:
                    recipients.add(email.email)
                    break
        else:
            # Explicit unsubscription.
            for email in subscription.user.emails:
                try:
                    recipients.remove(email.email)
                except KeyError:
                    pass

    ml_id = group_id
    if not ml_id:
        ml_id = {1: _('ututi-community'), 2: _('ututi-bugs')}[int(category_id)]
    if recipients:
        re = 'Re: ' if not new_thread else ''
        send_email(config['ututi_email_from'],
                   config['ututi_email_from'],
                   '[%s] %s%s' % (ml_id, re, post.title),
                   email_message,
                   message_id=_generateMessageId(),
                   send_to=list(recipients))


def make_forum_post(user, title, message, group_id, category_id, thread_id=None, controller=None):
    new_thread = thread_id is None

    post = ForumPost(title, message, category_id=category_id,
                     thread_id=thread_id)
    meta.Session.add(post)
    meta.Session.commit()
    meta.Session.refresh(post)

    # Subscribe logged in user to the thread
    subscription = SubscribedThread.get_or_create(post.thread_id, user,
                                                  activate=True)

    # If this is a new thread; automatically subscribe all
    # interested members.
    if group_id and new_thread:
        group = Group.get(group_id)
        for member in group.members:
            if member.subscribed_to_forum:
                SubscribedThread.get_or_create(post.thread_id, member.user,
                                               activate=True)

    _send_emails(user, post, group_id, category_id, controller=controller)
    return post
