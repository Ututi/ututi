import datetime
import logging

from sqlalchemy.sql.expression import desc, asc
from sqlalchemy.sql.expression import or_
from paste.util.datetimeutil import parse_date

from pylons import request, config
from pylons.i18n import ungettext, _

from ututi.lib.messaging import EmailMessage
from ututi.lib.base import BaseController, render
from ututi.lib.security import bot_protect
from ututi.model.events import ModeratedPostCreated
from ututi.model.events import FileUploadedEvent
from ututi.model.events import PageCreatedEvent
from ututi.model.events import PageModifiedEvent
from ututi.model.events import Event
from ututi.model import Subject
from ututi.model import Group
from ututi.model import GroupMember
from ututi.model import UserSubjectMonitoring
from ututi.model import User, meta

log = logging.getLogger(__name__)


class NewsController(BaseController):

    def _all_events(self, from_time, to_time):
        events = meta.Session.query(Event)\
            .filter(Event.created < to_time)\
            .filter(Event.created >= from_time)\
            .filter(or_(Event.file_id != None,
                        Event.page_id != None,
                        Event.event_type == 'moderated_post_created'))\
            .order_by(desc(Event.created), desc(Event.id))\
            .all()
        return events

    def _group_recipients(self, group, period):
        return group.recipients(period)

    def _subject_recipients(self, subject, period):
        return subject.recipients(period)

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

    def _subject(self, sections, events):
        pages = files = 0
        for section in sections:
            for event in section['events']:
                if event['type'] == 'page':
                    pages += 1
                elif event['type'] == 'file':
                    files += 1

        subject = _('VUtuti news: %(changes)s')
        file_changes = ungettext('%(file_count)d new file',
                                 '%(file_count)d new files', files) % {
            'file_count': files}
        page_changes = ungettext('%(page_count)d new page',
                                 '%(page_count)d new pages', pages) % {
            'page_count': pages}

        if pages and files:
            subject = _('VUtuti news: %(file_changes)s and %(page_changes)s')
            subject = subject % {'file_changes': file_changes,
                                 'page_changes': page_changes}
        elif files:
            subject = subject % {'changes': file_changes}
        elif pages:
            subject = subject % {'changes': page_changes}
        else:
            messages = len([event for event in events if event.category == 'moderation'])
            moderation_changes = ungettext('%(message_count)d new message awaiting moderation',
                                           '%(message_count)d new messages awaiting moderation', messages) % {
                'message_count': messages}
            subject = subject % {'changes': moderation_changes}

        return   subject

    def _format_event(self, event):
        return {'text_item': event.text_news(),
                'html_item': event.html_news(),
                'type': event.category}

    def _get_sections(self, events):
        sections = {}
        for event in events:
            section = sections.setdefault(event.context.id, {})
            section['title'] = event.context.title
            section['url'] = event.context.url(qualified=True)
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
            user = User.get_byid(uid)
            events = [ev for ev in events
                      if (ev.user is None or
                          (ev.user.id != uid and
                           ev.context not in user.ignored_subjects
                           and not ev.isEmptyFile()))]

            # process moderation events
            events = [ev for ev in events
                      if not isinstance(ev, ModeratedPostCreated) or ev.context.is_admin(user)]

            if not events:
                continue

            sections = self._get_sections(events)
            subject = self._subject(sections, events)
            extra_vars = {'sections': sections,
                          'subject': subject}
            text = render('/emails/news_text.mako',
                          extra_vars=extra_vars)
            html = render('/emails/news_html.mako',
                          extra_vars=extra_vars)
            msg = EmailMessage(subject, text, html)
            log.info("Sent to <%s> to %s" % (subject,  user.fullname))
            user = user.send(msg)

    def _send_ending_period_reminder(self, group):
        subject = _('The private space subscription for "%s" is about to expire') % group.title
        extra_vars = dict(group=group)
        text = render('/emails/group_space_ending.mako', extra_vars=extra_vars)
        msg = EmailMessage(subject, text)
        group.send(msg)
        group.ending_period_notification_sent = True

    def _send_out_of_space_notification(self, group):
        """Send a notification to a group that it has run out of private space."""
        subject = _('The VUtuti group "%s" has run out of private file space') % group.title
        extra_vars = dict(group=group, size_limit=int(config.get('paid_group_file_limit')))
        text = render('/emails/group_space_full.mako', extra_vars=extra_vars)
        msg = EmailMessage(subject, text)
        group.send(msg)
        group.out_of_space_notification_sent = True

    def _send_group_space_reminders(self):
        date = parse_date(request.params.get('date'))
        max_expiry_date = date + datetime.timedelta(days=3)
        for group in meta.Session.query(Group).all():
            # Group space purchase period is about to end?
            if (group.private_files_lock_date
                and group.private_files_lock_date.date() <= max_expiry_date
                and not group.ending_period_notification_sent):
                self._send_ending_period_reminder(group)
                meta.Session.commit()
            # Group space has run out?
            if group.free_size == 0 and not group.out_of_space_notification_sent:
                self._send_out_of_space_notification(group)
                meta.Session.commit()

    @bot_protect
    def hourly(self):
        self._send_news('hour', hours=1)

    @bot_protect
    def daily(self):
        self._send_news('day', days=1)
        self._send_group_space_reminders()
