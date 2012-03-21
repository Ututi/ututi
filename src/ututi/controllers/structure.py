import formencode
import logging

from formencode import Schema, validators, Invalid, variabledecode, htmlfill
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.sql import expression, func
from sqlalchemy import or_

from pylons.controllers.util import abort
from pylons import request, tmpl_context as c, url
from pylons.controllers.util import redirect
from pylons.decorators import jsonify
from pylons.i18n import _

from ututi.lib.security import ActionProtector
from ututi.lib.image import serve_logo
from ututi.lib.base import BaseController, render
from ututi.lib.validators import InURLValidator, FileUploadTypeValidator, validate
from ututi.model import meta, LocationTag, SimpleTag, Tag, Region

log = logging.getLogger(__name__)


class StructureIdValidator(validators.FancyValidator):

    messages = {
        'not_exist': _(u"The element does not exist.")
        }

    def _to_python(self, value, state):
        return int(value.strip())

    def validate_python(self, value, state):
        if value != 0:
            try:
                meta.Session.query(LocationTag).filter_by(id=value).one()
            except:
                raise Invalid(self.message('not_exist', state), value, state)


class NewStructureForm(Schema):
    allow_extra_fields = True
    title = validators.UnicodeString(not_empty=True, strip=True, max=250)
    title_short = validators.UnicodeString(not_empty=True, strip=True, max=50)
    region = validators.Int()
    logo_upload = FileUploadTypeValidator(allowed_types=('.jpg', '.png', '.bmp', '.tiff', '.jpeg', '.gif'))
    description = validators.UnicodeString(strip=True)
    parent = StructureIdValidator()


class NewUniversityForm(Schema):
    title = validators.UnicodeString(not_empty=True, max=250)
    title_short = validators.UnicodeString(not_empty=True, max=50)
    url = validators.UnicodeString(not_empty=True, max=250)

class JSStructureForm(Schema):
    allow_extra_fields = True
    pre_validators = [variabledecode.NestedVariables()]


class EditStructureForm(NewStructureForm):
    logo_delete = validators.StringBoolean(if_missing=False)
    site_url = validators.URL()


class AutoCompletionForm(Schema):
    allow_extra_fields = True
    pre_validators = [variabledecode.NestedVariables()]

def structure_action(method):
    def _structure_action(self, id):
        try:
            item = meta.Session.query(LocationTag).filter_by(id=id).one()
        except NoResultFound:
            abort(404)

        c.item = item
        c.theme = item.get_theme()
        return method(self, item)
    return _structure_action


class StructureController(BaseController):

    @ActionProtector("root")
    def index(self):
        c.structure = meta.Session.query(LocationTag).filter_by(parent=None).order_by(LocationTag.id).all()
        c.regions = meta.Session.query(Region).order_by(Region.id).all()
        return render('structure/index.mako')

    @validate(schema=NewStructureForm, form='index')
    @ActionProtector("root")
    def create(self):
        values = self.form_result

        structure = LocationTag(title=values['title'],
                                title_short=values['title_short'],
                                description=values['description'],
                                member_policy='PUBLIC')
        structure.region_id = int(values['region']) or None

        if values.get('logo_upload', None) is not None:
            logo = values['logo_upload']
            structure.logo = logo.file.read()

        meta.Session.add(structure)

        # XXX why zero?
        if int(values['parent']) != 0:
            parent = meta.Session.query(LocationTag).filter_by(id=values['parent']).one()
            parent.children.append(structure)
        meta.Session.commit()
        redirect(url(controller='structure', action='index'))

    def js_create_university(self):
        schema = NewUniversityForm()

        try:
            form_result = schema.to_python(dict(request.params))
        except formencode.Invalid, error:
            return unicode(error)
        else:
            university = LocationTag(title=form_result['title'],
                                     title_short=form_result['title_short'],
                                     url=form_result['url'],
                                     logo=None)

    def create_university(self):
        schema = NewUniversityForm()

        try:
            form_result = schema.to_python(dict(request.params))
        except formencode.Invalid, error:
            return unicode(error)
        else:
            university = LocationTag(title=form_result['title'],
                                     title_short=form_result['title_short'],
                                     url=form_result['url'],
                                     logo=None)

    @ActionProtector("root")
    def regions(self):
        if request.params.get('action'):
            for tag in meta.Session.query(LocationTag).order_by(LocationTag.parent_id.desc()).all():
                region = request.params.get('tag-%s-region' % tag.id)
                if region:
                    region = int(region) if region != '0' else None
                    if region is None and tag.parent:
                        region = tag.parent.region_id
                    tag.region_id = region
            meta.Session.commit()
            redirect(url(controller='structure', action='index'))
        c.structure = meta.Session.query(LocationTag).filter_by(parent=None).order_by(LocationTag.id).all()
        c.regions = meta.Session.query(Region).order_by(Region.id).all()
        return render('structure/regions.mako')

    def _edit_form(self):
        return render('structure/edit.mako')

    @structure_action
    @ActionProtector("root")
    def edit(self, item):
        defaults = {
            'title' : c.item.title,
            'title_short': c.item.title_short,
            'description': c.item.description,
            'parent': c.item.parent,
            'region': c.item.region_id or 0,
            }
        c.structure = meta.Session.query(LocationTag).filter_by(parent=None).filter(LocationTag.id != item.id).all()
        c.regions = meta.Session.query(Region).all()
        return htmlfill.render(self._edit_form(), defaults=defaults)

    @structure_action
    @validate(schema=EditStructureForm, form='_edit_form')
    @ActionProtector("root")
    def update(self, item):
        values = self.form_result
        if values.get('action', None) == _('Delete'):
            meta.Session.delete(c.item)
        else:
            c.item.title = values['title']
            c.item.title_short = values['title_short']
            c.item.description = values['description']
            c.item.site_url = values['site_url']
            c.item.region_id = int(values['region']) or None

            if values['logo_delete']:
                c.item.logo = None

            if values.get('logo_upload', None) is not None:
                logo = values['logo_upload']
                c.item.logo = logo.file.read()

            if values.get('parent') is not None and int(values.get('parent', '0')) != 0:
                parent = meta.Session.query(LocationTag).filter_by(id=values['parent']).one()
                parent.children.append(c.item)

        meta.Session.commit()
        redirect(url(controller='structure', action='index'))

    def logo(self, id, width=None, height=None):
        return serve_logo('locationtag', int(id), width=width, height=height,
                         cache=False)

    @validate(schema=AutoCompletionForm, post_only=False, on_get=True)
    @jsonify
    def completions(self):
        query = meta.Session.query(LocationTag)
        depth = 0
        widget_id = 0
        if hasattr(self, 'form_result'):
            widget_id = self.form_result.get('widget_id', 0)
            text = self.form_result.get('q', None)
            parent = self.form_result.get('parent', '')
            if text is not None:
                query = query.filter(or_(LocationTag.title_short.op('ILIKE')('%s%%' % text),
                                         LocationTag.title.op('ILIKE')('%s%%' % text)))
            depth = len(parent)
            parent = LocationTag.get_by_title(parent)
            query = query.filter(LocationTag.parent==parent)
        else:
            query = query.filter(LocationTag.parent==None)

        results = []

        for tag in query.order_by(LocationTag.title.asc()).all():
            has_children = meta.Session.query(LocationTag).filter(LocationTag.parent==tag).all() != []
            results.append({'id': tag.title_short, 'title': tag.title, 'path': '/'.join(tag.path), 'has_children': has_children})

        return {'values': results, 'depth': depth, 'id': '#%s .location-%i' % (widget_id, depth)}

    def autocomplete_all_tags(self, all=False):
        return self.autocomplete_tags(True)

    @jsonify
    def autocomplete_tags(self, all=False):
        text = request.GET.get('val', None)

        # filter warnings
        import warnings
        warnings.filterwarnings('ignore', module='pylons.decorators')

        if text:
            if all:
                query = meta.Session.query(expression.distinct(expression.func.lower(Tag.title)))
            else:
                query = meta.Session.query(expression.distinct(expression.func.lower(SimpleTag.title)))

            query = query.filter(or_(Tag.title_short.op('ILIKE')('%s%%' % text),
                                     Tag.title.op('ILIKE')('%s%%' % text)))

            results = [title for title in query.all()]
            return dict(values = results)

        return None

    @validate(schema=AutoCompletionForm, post_only=False, on_get=True)
    @jsonify
    def js_add_tag(self):
        if hasattr(self, 'form_result'):
            json = {'success': '', 'error': ''}
            parent = None
            created = None
            location = self.form_result['location']
            newlocation = self.form_result['newlocation']
            for index, item in enumerate(newlocation):
                if item['title'] == '' and location[index] != '':
                    try:
                        parent = meta.Session.query(LocationTag
                                ).filter(LocationTag.title == location[index]
                                ).filter(LocationTag.parent == parent
                                ).one()
                    except: # XXX bare except
                        break
                else:
                    try:
                        InURLValidator.to_python(item['title_short'])

                        existing = meta.Session.query(LocationTag).filter(or_(func.lower(LocationTag.title_short) == item['title_short'].lower(),
                                                                              func.lower(LocationTag.title) == item['title'].lower()))\
                            .filter(LocationTag.parent == parent).first()
                        if existing is not None:
                            if existing.title.lower() == item['title'].lower():
                                json['error'] = _('The entry already exists')
                                break
                            else:
                                json['error'] = _('Choose a different short title')
                                break
                    except: # XXX bare except
                        json['error'] = _('The short title must contain no spaces')
                        break

                    created = LocationTag(item['title'], item['title_short'], u'', parent, confirmed=False)

                    meta.Session.add(created)
                    meta.Session.commit()
                    break
            if created is not None:
                json['success'] = created.title
            return json
