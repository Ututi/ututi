from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.sql.expression import or_, and_
from pylons import tmpl_context as c, config, request, url
from pylons.controllers.util import redirect, abort
from pylons.i18n import _

from ututi.model import meta, PrivateMessage, User
from ututi.lib.base import render, BaseController
from ututi.lib.security import ActionProtector
import ututi.lib.helpers as h
import json


class MessagesController(BaseController):
    """Private messages"""

    @ActionProtector("user")
    def index(self):
        c.messages = meta.Session.query(PrivateMessage
                ).filter_by(thread_id=None
                ).filter(or_(and_(PrivateMessage.recipient==c.user,
                                  PrivateMessage.hidden_by_recipient == False),
                             and_(PrivateMessage.sender==c.user,
                                  PrivateMessage.hidden_by_sender == False)),
                ).order_by(PrivateMessage.id.desc()
                ).all()
        return render('/messages/index.mako')

    @ActionProtector("user")
    def thread(self, id):
        c.message = PrivateMessage.get(id)
        if not (c.user == c.message.sender or c.user == c.message.recipient):
            abort(404)
        c.thread = c.message.thread()
        for msg in c.thread:
            if msg.recipient.id == c.user.id:
                msg.is_read = True
        meta.Session.commit()
        return render('/messages/thread.mako')

    @ActionProtector("user")
    def reply(self, id):
        original = PrivateMessage.get(id)
        if not (c.user == original.sender or c.user == original.recipient):
            abort(404)
        recipient = original.sender if original.recipient.id == c.user.id else original.recipient
        original.is_read = True
        thread_id = original.thread_id or original.id
        msg = PrivateMessage(c.user, recipient, original.subject,
                             request.params.get('message'),
                             thread_id=thread_id)
        meta.Session.add(msg)
        # Make sure this thread is unhidden on both sides.
        original.hidden_by_sender = False
        original.hidden_by_recipient = False
        meta.Session.commit()
        if request.params.has_key('js'):
            return _('Message sent.')
        h.flash(_('Message sent.'))
        redirect(url(controller='messages', action='thread', id=thread_id))

    @ActionProtector("user")
    def find_user(self):
        name = request.params.get('term')

        if name:
            users = meta.Session.query(User).filter(User.fullname.like('%' + name + '%')) \
                                            .filter(User.id != c.user.id) \
                                            .filter(User.location_id == c.user.location.id) \
                                            .limit(10)
            list_of_users = []

            for user in users:
                user_info = {}
                user_info['label'] = user.fullname # is showing on the list
                user_info['value'] = user.fullname # is coping in the input
                user_info['id'] = user.id
                list_of_users.append(user_info)

            return json.dumps(list_of_users)

    @ActionProtector("user")
    def delete(self, id):
        message = PrivateMessage.get(id)
        if c.user == message.recipient:
            message.hidden_by_recipient = True
            message.is_read = True
        if c.user == message.sender:
            message.hidden_by_sender = True
        meta.Session.commit()
        redirect(url(controller='messages', action='index'))

    @ActionProtector("user")
    def mark_all_as_read(self):
        for msg in meta.Session.query(PrivateMessage).filter_by(recipient=c.user).all():
            msg.is_read = True
        meta.Session.commit()
        redirect(url(controller='messages', action='index'))

    @ActionProtector("user")
    def new_message(self):
        user_id = request.params.get('user_id')
        message = request.params.get('message')
        title = request.params.get('title')

        if request.params.get('uid'):
            user_id = request.params.get('uid')

        try:
            c.recipient = meta.Session.query(User).filter_by(id=user_id).one()
        except NoResultFound:
            pass

        if user_id and message and title:
            msg = PrivateMessage(c.user, c.recipient,
                                 request.params.get('title'),
                                 request.params.get('message'))
            meta.Session.add(msg)
            meta.Session.commit()
            h.flash(_('Message sent.'))
            redirect(url(controller='user', action='index', id=c.recipient.id))
        else:
            h.flash(_('All fields must be filled!'))
        return render('/messages/message_new.mako')
