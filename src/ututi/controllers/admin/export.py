import csv

from cStringIO import StringIO

from pylons import response

from ututi.lib.security import ActionProtector
from ututi.lib.image import prepare_image

from ututi.model import (meta, User, LocationTag, Group, Subject)

FMT_DATE = '%Y-%m-%d'
FMT_TIMESTAMP = '%Y-%m-%d %H:%M:%S.%f'

class Export(object):
    """A helper context manager for exporting zipped csv data."""

    class CSVEntry(object):

        def __init__(self, zipfile, filename):
            self.zipfile = zipfile
            self.filename = filename

        def open(self):
            self.csv = StringIO()
            self.writer = csv.writer(self.csv, delimiter=',')

        def writerow(self, row):
            self.writer.writerow([(item or '').encode('utf-8')
                                 for item in row])

        def close(self):
            self.zipfile.writestr(self.filename, self.csv.getvalue())

    def __init__(self, zipfile, *args):
        self.entries = [Export.CSVEntry(zipfile, arg) for arg in args]

    def __enter__(self):
        for entry in self.entries:
            entry.open()
        return self.entries if len(self.entries) > 1 else self.entries[0]

    def __exit__(self, type, value, traceback):
        # humble implementation
        for entry in self.entries:
            entry.close()


class UniversityExportMixin(object):

    def _format_file_row(self, file):
        return [file.created.email.email,
                file.created_on.strftime(FMT_TIMESTAMP),
                file.folder,
                file.title,
                file.mimetype,
                file.md5]

    def _export_subjects(self, zf, university):
        with Export(zf, 'subjects.csv', 'subject_files.csv') as (subjects, subject_files):
            for subject in meta.Session.query(Subject)\
                    .filter(Subject.location_id.in_([loc.id for loc in university.flatten]))\
                    .filter_by(deleted_by=None):
                subjects.writerow(['/'.join(subject.location.path[1:]),
                                   subject.created.email.email,
                                   subject.subject_id,
                                   subject.title,
                                   subject.lecturer,
                                   subject.description])
                for file in subject.files:
                    if not file.isNullFile() and not file.isDeleted():
                        subject_files.writerow(['/'.join(subject.location.path[1:]),
                                                subject.subject_id] + self._format_file_row(file))

    def _export_groups(self, zf, university):
        with Export(zf, 'groups.csv', 'group_members.csv', 'group_files.csv', 'group_subjects.csv') \
                as (groups, group_members, group_files, group_subjects):
            for group in meta.Session.query(Group)\
                    .filter(Group.location_id.in_([loc.id for loc in university.flatten]))\
                    .filter_by(deleted_by=None):
                groups.writerow(['/'.join(group.location.path[1:]),
                                 group.created.email.email,
                                 group.group_id,
                                 group.year.strftime('%Y'),
                                 group.title,
                                 group.page,
                                 str(group.moderators),
                                 str(group.wants_to_watch_subjects),
                                 str(group.admins_approve_members),
                                 group.private_files_lock_date.strftime(FMT_DATE) if group.private_files_lock_date else '',
                                 str(group.mailinglist_moderated)])
                for membership in group.members:
                    group_members.writerow(['/'.join(group.location.path[1:]),
                                            group.group_id,
                                            membership.user.email.email])
                for file in group.files:
                    if not file.isNullFile() and not file.isDeleted():
                        group_files.writerow(['/'.join(group.location.path[1:]),
                                              group.group_id] + self._format_file_row(file))
                for subject in group.watched_subjects:
                    if not subject.isDeleted(): # skip deleted subjects
                        group_subjects.writerow(['/'.join(subject.location.path[1:]),
                                                 subject.subject_id,
                                                 '/'.join(group.location.path[1:]),
                                                 group.group_id])
                if group.logo:
                    zf.writestr('group_logos/%s.png' % group.group_id,
                                prepare_image(group.logo))

    def _export_users(self, zf, university):
        users = set()
        for group in meta.Session.query(Group)\
                .filter(Group.location_id.in_([loc.id for loc in university.flatten]))\
                .filter_by(deleted_by=None):
            for member in group.members:
                users.add(member.user)
        users.update(meta.Session.query(User).filter_by(location=university))
        with Export(zf, 'users.csv') as users_csv:
            for user in users:
                users_csv.writerow([user.email.email,
                                    str(user.email.confirmed),
                                    user.fullname,
                                    user.password,
                                    user.site_url,
                                    user.description,
                                    user.receive_email_each,
                                    user.phone_number if user.phone_number else '',
                                    user.openid if user.openid else '',
                                    str(user.facebook_id) if user.facebook_id else '',
                                    str(user.profile_is_public),
                                    user.hidden_blocks,
                                    user.ignored_events,
                                    user.type,
                                    getattr(user, "teacher_position", None),
                                    str(getattr(user, "teacher_verified", None)),
                                    ])
                if user.logo:
                    zf.writestr('user_logos/%s.png' % user.email.email, prepare_image(user.logo))
        #accepted_terms timestamp default null,
        #last_seen_feed timestamp not null default (now() at time zone 'UTC'),
        #location_country varchar(5) default null,
        #location_city varchar(30) default null,

    @ActionProtector("root")
    def export_university(self, university_id):
        try:
            university_id = int(university_id)
        except ValueError:
            pass
        university = LocationTag.get(university_id)
        result = StringIO()
        from zipfile import ZipFile, ZIP_DEFLATED
        zf = ZipFile(result, "a", ZIP_DEFLATED, False)
        if university.logo:
            zf.writestr('logo.png', prepare_image(university.logo))

        self._export_subjects(zf, university)
        self._export_groups(zf, university)
        self._export_users(zf, university)
        zf.close()

        response.headers['Content-Length'] = len(result.getvalue())
        response.headers['Content-Disposition'] = 'attachment; filename="%s.zip"' %\
                university.title_short.encode('transliterate').encode('ascii', 'ignore')
        response.headers['Content-Type'] = 'application/zip'
        result.seek(0)
        return result
