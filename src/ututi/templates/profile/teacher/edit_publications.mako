<%inherit file="/profile/teacher/edit_text_base.mako" />

<div class="explanation-post-header">
  <h2>${_('List your publications')}</h2>
  <div class="tip">
    ${h.literal(_('Your publications will be displayed on your %(profile_page_url)s.') % \
                dict(profile_page_url=h.link_to(_('profile page'), c.user.url(action='external_teacher_index'))))}
  </div>
</div>

${self.template_warning()}

<form id="publications-form" class="text-form" method="post" action="${url(controller='profile', action='update_publications')}">
  ${h.input_area('publications', _('List your publications'), class_='ckeditor')}
  ${h.input_submit(_('Save'))}
</form>
