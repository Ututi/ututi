import email
import mimetools
from StringIO import StringIO
from nous.mailpost.MailBoxerTools import parseaddr

from collections import defaultdict

from pylons import url
from pylons import tmpl_context as c

from sqlalchemy.sql.expression import or_
from sqlalchemy.sql import select

from ututi.model.users import AnonymousUser
from ututi.model.mailing import decode_and_join_header
from ututi.model.mailing import UtutiEmail

from ututi.model import Group
from ututi.model import File
from ututi.model import meta
from ututi.lib.base import render_def


def generic_events_query():
    t_ci = meta.metadata.tables['content_items']
    t_pages = meta.metadata.tables['page_versions']
    t_files = meta.metadata.tables['files']
    t_mlmsg = meta.metadata.tables['group_mailing_list_messages']
    t_fpmsg = meta.metadata.tables['forum_posts']
    t_sms = meta.metadata.tables['outgoing_group_sms_messages']
    t_wall_posts = meta.metadata.tables['wall_posts']

    #generic query for events
    t_context = t_ci.alias('context_ci')
    file_ci = t_ci.alias('file_ci')

    #page
    page_ci = t_ci.alias('page_ci')
    latest_page = select([t_pages.c.page_id, t_pages.c.title, page_ci.c.deleted_on],
                         from_obj=[t_pages.join(page_ci,
                                                page_ci.c.id == t_pages.c.id)])\
                         .order_by(t_pages.c.id.desc())\
                         .limit(1)\
                         .alias('latest_page')
    t_evt = meta.metadata.tables['events']
    evts_generic = select([t_evt.c.id, t_evt.c.author_id, t_evt.c.created,
                           t_evt.c.event_type, t_evt.c.data, t_evt.c.page_id,
                           t_evt.c.object_id,
                           t_evt.c.parent_id,
                           t_evt.c.subject_id,
                           t_evt.c.post_id,
                           t_evt.c.file_id,
                           t_evt.c.message_id,
                           t_context.c.content_type.label('context_type'),
                           t_context.c.deleted_on.label('ci_deleted_on'),
                           t_context.c.location_id.label('ci_location_id'),
                           #wiki page
                           latest_page.c.deleted_on.label('page_deleted_on'),
                           latest_page.c.title.label('page_title'),
                           #files
                           t_files.c.folder,
                           t_files.c.md5,
                           t_files.c.filename,
                           file_ci.c.deleted_on.label('file_deleted_on'),
                           #mailing list messages
                           t_mlmsg.c.subject.label('ml_subject'),
                           t_mlmsg.c.original.label('ml_original'),
                           t_mlmsg.c.group_id.label('ml_group_id'),
                           t_mlmsg.c.thread_message_machine_id.label('ml_thread_id'),
                           #forum posts
                           t_fpmsg.c.message.label('fp_message'),
                           t_fpmsg.c.title.label('fp_subject'),
                           t_fpmsg.c.category_id.label('fp_category_id'),
                           t_fpmsg.c.thread_id.label('fp_thread_id'),
                           #sms
                           t_sms.c.message_text.label('sms_message'),
                           #wall posts
                           t_wall_posts.c.content.label('wp_content'),
                           t_wall_posts.c.subject_id.label('wp_subject_id'),
                           t_wall_posts.c.target_location_id.label('wp_location_id'),
                           ],
                          from_obj=[t_evt.outerjoin(latest_page, latest_page.c.page_id==t_evt.c.page_id)\
                                        .outerjoin(t_context, t_context.c.id==t_evt.c.object_id)\
                                        .outerjoin(t_files, t_files.c.id==t_evt.c.file_id)\
                                        .outerjoin(t_mlmsg, t_mlmsg.c.id==t_evt.c.message_id)\
                                        .outerjoin(t_fpmsg, t_fpmsg.c.id==t_evt.c.post_id)\
                                        .outerjoin(file_ci, file_ci.c.id==t_files.c.id)\
                                        .outerjoin(t_sms, t_sms.c.id==t_evt.c.sms_id)\
                                        .outerjoin(t_wall_posts, t_wall_posts.c.id==t_evt.c.object_id)
                                    ]).where(t_context.c.deleted_on==None)
    return evts_generic


class ObjectWrapper(dict):
    """
    A generic object wrapper. If we have the time this should be turned into a simple dict, that has all the attributes needed to render the wall.
    """
    def __init__(self, internal):
        self.internal = internal

    def __getattr__(self, attr):
        if self.has_key(attr):
            return self[attr]
        elif hasattr(self.internal, attr):
            return getattr(self.internal, attr)
        else:
            raise AttributeError('Object does not have attribute \'%s\'.' % attr)

    def wall_entry(self):
        return render_def('/sections/wall_entries.mako', self.internal.event_type, event=self)


class WallMixin(object):

    def _wall_events_query(self):
        """Should be implemented by subclasses."""
        raise NotImplementedError()

    def _wall_events(self, limit=250):
        """Returns threaded events, defined by _wall_events_query()"""
        t_evt = meta.metadata.tables['events']
        evts = self._wall_events_query()

        evts = evts\
            .where(t_evt.c.parent_id==None)\
            .order_by(t_evt.c.created.desc())\
            .limit(limit)

        return [ObjectWrapper(evt) for evt in meta.Session.execute(evts)]

    def _get_event_comments(self, event_ids):
        t_comm = meta.metadata.tables['event_comments']
        t_ci = meta.metadata.tables['content_items']

        event_id_in_list = t_comm.c.event_id.in_(event_ids) if event_ids else False
        comm = select([t_comm.c.id.label('comment_id'),
                       t_comm.c.content.label('message'),
                       t_ci.c.created_by.label('author_id'),
                       t_comm.c.event_id,
                       t_ci.c.created_on],
                       from_obj=[t_comm.join(t_ci, t_comm.c.id==t_ci.c.id)])\
                      .where(event_id_in_list)\
                      .where(t_ci.c.deleted_by==None)\
                      .order_by(t_ci.c.created_on.asc())
        comments = meta.Session.execute(comm).fetchall()

        comments_collection = defaultdict(list)
        for comm in comments:
            comments_collection[comm.event_id].append(dict(comm))
        return comments_collection

    def _get_event_children(self, event_ids):
        t_evt = meta.metadata.tables['events']
        evts_generic = generic_events_query()
        parent_id_in_list = t_evt.c.parent_id.in_(event_ids) if event_ids else False
        children = meta.Session.execute(evts_generic\
                                            .where(parent_id_in_list)\
                                            .order_by(t_evt.c.created.asc())).fetchall()

        ids = [ch.id for ch in children]
        return (ids, [ObjectWrapper(child) for child in children])

    def _group_event_children(self, children):
        children_collection = defaultdict(list)
        for child in children:
            self._ml_event_data(child)
            children_collection[child.parent_id].append(child)
        return children_collection

    def _get_sms_event_groups(self, events):
        groups = []
        ids = [e.object_id for e in events if e.event_type == 'sms_message_sent']
        if ids:
            groups = meta.Session.query(Group).filter(Group.id.in_(ids)).all()

        groups_collection = dict()
        for group in groups:
            groups_collection[group.id] = group
        return groups_collection

    def _get_ml_attachments(self, event_ids):
        t_evt = meta.metadata.tables['events']
        att = []
        if event_ids:
            att = meta.Session.query(File).join((t_evt, t_evt.c.message_id==File.parent_id))\
                .filter(t_evt.c.id.in_(event_ids))\
                .order_by(File.filename.desc())\
                .all()

        attachment_collection = defaultdict(list)
        for attachment in att:
            attachment_collection[attachment.parent_id].append(attachment)
        return attachment_collection

    def _set_wall_variables(self, events_hidable=False, limit=60):
        """This is just a shorthand method for setting common
        wall variables."""
        events = self._wall_events(limit)
        c.events_hidable = events_hidable

        ids = [e.id for e in events]

        (children_ids, children) = self._get_event_children(ids)
        ids.extend(children_ids)

        comments_collection = self._get_event_comments(ids)
        groups_collection = self._get_sms_event_groups(events)
        attachment_collection = self._get_ml_attachments(ids)
        c.events = [ObjectWrapper(evt) for evt in events]

        for child in children:
            if comments_collection.has_key(child.id):
                child['conversation'] = comments_collection[child.id]
            if attachment_collection.has_key(child.message_id):
                child['attachments'] = attachment_collection[child.message_id]

        children_collection = self._group_event_children(children)

        for evt in c.events:
            #TODO: set mailing list message
            self._ml_event_data(evt)

            if children_collection.has_key(evt.id):
                evt['children'] = children_collection[evt.id]
            if comments_collection.has_key(evt.id):
                evt['conversation'] = comments_collection[evt.id]
            if evt.event_type == 'sms_message_sent':
                evt['sms_group'] = groups_collection[evt.object_id]
            if attachment_collection.has_key(evt.message_id):
                evt['attachments'] = attachment_collection[evt.message_id]


    def _ml_event_data(self, evt):
        if evt.event_type in ['mailinglist_post_created', 'moderated_post_created']:
            evt['ml_message'] = email.message_from_string(evt.ml_original, UtutiEmail).getBody()
            if evt.author_id is not None:
                evt['ml_author'] = evt.author_id
                evt['ml_author_logo_link'] = url(controller='user', action='logo', width=50, id=evt.author_id)
            else:
                mimemsg = mimetools.Message(StringIO(evt.ml_original))
                u_name, u_email = parseaddr(decode_and_join_header(mimemsg['From']))
                evt['ml_author'] = AnonymousUser(u_name, u_email)
                evt['ml_author_logo_link'] = evt.ml_author.url(action='logo', width=50)
