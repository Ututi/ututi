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
from ututi.model import User, meta


class NewsController(BaseController):

    def _events(self, user, from_time, to_time):
        events = meta.Session.query(Event)\
            .filter(or_(Event.object_id.in_([s.id
                                             for s in user.watched_subjects]),
                        Event.object_id.in_([m.group.id
                                             for m in user.memberships])))\
            .filter(Event.author_id != user.id)\
            .filter(Event.created < to_time)\
            .filter(Event.created >= from_time)\
            .filter(or_(Event.file_id != None,
                        Event.page_id != None))\
            .order_by(desc(Event.created))\
            .all()


        return events

    def _users_for_hourly_news(self):
        return meta.Session.query(User).filter_by(receive_email_each='hour')

    def _users_for_daily_news(self):
        return meta.Session.query(User).filter_by(receive_email_each='day')

    def range(self, days=0, hours = 0):
        date = request.params.get('date')
        date = parse_date(date)

        hour = request.params.get('hour', '0')
        hour = int(hour)
        dtstart = datetime.datetime.combine(date, datetime.time(hour))
        dt = datetime.timedelta(days=days, hours=hours)
        return (dtstart, dtstart + dt)

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

    def _send_news(self, users, **kwargs):
        dtstart, dtend = self.range(**kwargs)
        for user in users:
            events = self._events(user, dtstart, dtend)
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
            user.send(msg)

    def hourly(self):
        self._send_news(self._users_for_hourly_news(), hours=1)

    def daily(self):
        self._send_news(self._users_for_daily_news(), days=1)
