
from pylons.controllers.util import redirect
from pylons.i18n import _
from pylons.templating import render_mako_def
from pylons import request
from pylons import url
from pylons import tmpl_context as c

from webhelpers import paginate

from ututi.model import Subject, meta
from ututi.lib.validators import validate
from ututi.lib.search import search_query_count
from ututi.lib.search import search_query
from ututi.lib.search import _filter_watched_subjects
from ututi.lib.security import ActionProtector
from ututi.lib.base import render
from ututi.controllers.search import SearchSubmit
import ututi.lib.helpers as h

class WatchedSubjectsMixin(object):
    @ActionProtector("user")
    def js_all_subjects(self):
        subjects = c.user.all_watched_subjects
        subjects = sorted(subjects, key=lambda subject: subject.title)

        return render_mako_def('/profile/home.mako', 'subjects_block', subjects=subjects)

    @ActionProtector("user")
    def js_my_subjects(self):
        subjects = c.user.watched_subjects
        subjects = sorted(subjects, key=lambda subject: subject.title)

        return render_mako_def('/profile/home.mako','subjects_block', subjects=subjects)

    @validate(schema=SearchSubmit, form='watch_subjects', post_only=False, on_get=True)
    @ActionProtector("user")
    def watch_subjects(self):
        c.breadcrumbs.append(self._actions('subjects'))
        c.search_target = url(controller='profile', action='watch_subjects')

        #retrieve search parameters
        c.text = self.form_result.get('text', '')

        tags = []

        if 'tagsitem' in self.form_result:
            tags = self.form_result.get('tagsitem', None)
        elif 'tags' in self.form_result:
            tags = self.form_result.get('tags', [])
            if isinstance(tags, basestring):
                tags = tags.split(', ')

        c.tags = ', '.join(filter(bool, tags))

        sids = [s.id for s in c.user.watched_subjects]

        search_params = {}
        if c.text:
            search_params['text'] = c.text
        if c.tags:
            search_params['tags'] = c.tags
        search_params['obj_type'] = 'subject'

        query = search_query(extra=_filter_watched_subjects(sids), **search_params)
        if search_params != {}:
            c.results = paginate.Page(
                query,
                page=int(request.params.get('page', 1)),
                items_per_page = 10,
                item_count = search_query_count(query),
                **search_params)

        c.watched_subjects = c.user.watched_subjects

        return render('profile/watch_subjects.mako')

    def _getSubject(self):
        subject_id = request.GET['subject_id']
        return Subject.get_by_id(int(subject_id))

    def _watch_subject(self):
        c.user.watchSubject(self._getSubject())
        meta.Session.commit()

    def _unwatch_subject(self):
        c.user.unwatchSubject(self._getSubject())
        meta.Session.commit()

    def _unteach_subject(self):
        c.user.unteach_subject(self._getSubject())
        meta.Session.commit()

    @ActionProtector("user")
    def watch_subject(self):
        self._watch_subject()
        redirect(request.referrer)

    @ActionProtector("user")
    def js_watch_subject(self):
        self._watch_subject()
        return render_mako_def('profile/watch_subjects.mako',
                               'subject_flash_message',
                               subject=self._getSubject()) +\
            render_mako_def('profile/watch_subjects.mako',
                            'watched_subject',
                            subject=self._getSubject(),
                            new = True)

    @ActionProtector("user")
    def unwatch_subject(self):
        # XXX this will need to be refactored.
        self._unwatch_subject()
        if request.params.has_key('js'):
            return 'OK'
        else:
            h.flash(_("The subject has been removed from your watched subjects list."))
            redirect(request.referrer)

    @ActionProtector("user")
    def js_unwatch_subject(self):
        self._unwatch_subject()
        return "OK"

    @ActionProtector("teacher")
    def unteach_subject(self):
        self._unteach_subject()
        if request.params.has_key('js'):
            return 'OK'
        else:
            h.flash(_("The course has been removed from your taught courses list."))
            redirect(request.referrer)

    def _ignore_subject(self):
        c.user.ignoreSubject(self._getSubject())
        meta.Session.commit()

    def _unignore_subject(self):
        c.user.unignoreSubject(self._getSubject())
        meta.Session.commit()

    @ActionProtector("user")
    def ignore_subject(self):
        self._ignore_subject()
        redirect(request.referrer)

    @ActionProtector("user")
    def js_ignore_subject(self):
        self._ignore_subject()
        return "OK"

    @ActionProtector("user")
    def unignore_subject(self):
        self._unignore_subject()
        redirect(request.referrer)

    @ActionProtector("user")
    def js_unignore_subject(self):
        self._unignore_subject()
        return "OK"
