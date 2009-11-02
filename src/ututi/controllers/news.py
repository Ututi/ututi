import datetime

from sqlalchemy.sql.expression import desc
from sqlalchemy.sql.expression import or_
from paste.util.datetimeutil import parse_date

from pylons import request
from pylons.i18n import ungettext, _

from ututi.lib.messaging import Message
from ututi.lib.base import BaseController, render
from ututi.model.events import FileUploadedEvent
from ututi.model.events import PageCreatedEvent
from ututi.model.events import PageModifiedEvent
from ututi.model.events import Event
from ututi.model import Subject
from ututi.model import Group
from ututi.model import GroupMember
from ututi.model import UserSubjectMonitoring
from ututi.model import User, meta


class NewsController(BaseController):

    def _all_events(self, from_time, to_time):
        events = meta.Session.query(Event)\
            .filter(Event.created < to_time)\
            .filter(Event.created >= from_time)\
            .filter(or_(Event.file_id != None,
                        Event.page_id != None))\
            .order_by(desc(Event.created))\
            .all()
        return events

    def _group_recipients(self, group, period):
        recipients = meta.Session.query(GroupMember).\
            filter_by(group=group, receive_email_each=period).all()
        return [recipient.user for recipient in recipients]

    def _subject_recipients(self, subject, period):
        all_recipients = []
        groups =  meta.Session.query(Group).filter(Group.watched_subjects.contains(subject)).all()
        for group in groups:
            all_recipients.extend(self._group_recipients(group, period))

        usms = meta.Session.query(UserSubjectMonitoring).\
            filter(UserSubjectMonitoring.subject==subject).\
            filter(User.receive_email_each==period).all()
        recipients = [usm.user for usm in usms]
        all_recipients.extend(recipients)
        return list(set(all_recipients))

    def _recipients(self, event, period):
        if isinstance(event.context, Subject):
            return self._subject_recipients(event.context, period)
        if isinstance(event.context, Group):
            return self._group_recipients(event.context, period)

    def range(self, days=0, hours=0):
        date = request.params.get('date')
        date = parse_date(date)

        hour = request.params.get('hour', '0')
        hour = int(hour)
        dtend = datetime.datetime.combine(date, datetime.time(hour))
        dt = datetime.timedelta(days=days, hours=hours)
        return (dtend - dt, dtend)

    def _subject(self, sections):
        pages = files = 0
        for section in sections:
            for event in section['events']:
                if event['type'] == 'page':
                    pages += 1
                elif event['type'] == 'file':
                    files += 1

        subject = _('Ututi news: %(changes)s')
        file_changes = ungettext('%(file_count)d new file',
                                 '%(file_count)d new files', files) % {
            'file_count': files}
        page_changes = ungettext('%(page_count)d new page',
                                 '%(page_count)d new pages', pages) % {
            'page_count': pages}
        if pages and files:
            subject = _('Ututi news: %(file_changes)s and %(page_changes)s')
            subject = subject % {'file_changes': file_changes,
                                 'page_changes': page_changes}
        elif files:
            subject = subject % {'changes': file_changes}
        elif pages:
            subject = subject % {'changes': page_changes}

        return   subject

    def _format_event(self, event):
        return {'text_item': event.text_news(),
                'html_item': event.html_news(),
                'type': ((isinstance(event, (PageModifiedEvent, PageCreatedEvent)) and 'page') or
                         (isinstance(event, FileUploadedEvent) and 'file'))}

    def _get_sections(self, events):
        sections = {}
        for event in events:
            section = sections.setdefault(event.context.id, {})
            section['title'] = event.context.title
            section_events = section.setdefault('events', [])
            formatted_event = self._format_event(event)
            if formatted_event not in section_events:
                section_events.append(formatted_event)
        sections = sorted(sections.items())
        return [section for (id, section) in sections]

    def _send_news(self, period, **kwargs):
        dtstart, dtend = self.range(**kwargs)

        recipient_to_events = {}
        for event in self._all_events(dtstart, dtend):
            recipients = self._recipients(event, period)
            for recipient in recipients:
                events = recipient_to_events.setdefault(recipient.id, [])
                events.append(event)
        for uid, events in recipient_to_events.items():
            events = [ev for ev in events
                      if ev.user.id != uid]

            if not events:
                continue
            sections = self._get_sections(events)
            subject = self._subject(sections)
            extra_vars = {'sections': sections,
                          'subject': subject}
            text = render('/emails/news_text.mako',
                          extra_vars=extra_vars)
            html = render('/emails/news_html.mako',
                          extra_vars=extra_vars)
            msg = Message(subject, text, html)
            user = User.get_byid(uid).send(msg)

    def hourly(self):
        self._send_news('hour', hours=1)

    def daily(self):
        self._send_news('day', days=1)
