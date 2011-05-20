<%inherit file="/profile/teacher/edit_text_base.mako" />

<div class="explanation-post-header">
  <h2>${_('Write down your biography and research interests')}</h2>
  <div class="tip">
    ${h.literal(_('This information will be displayed on your %(profile_page_url)s.') % \
                dict(profile_page_url=h.link_to(_('profile page'), c.user.url())))}
  </div>
</div>

${self.template_warning()}

<form id="biography-form" class="text-form" method="post" action="${url(controller='profile', action='update_biography')}">
  ${h.input_area('description', _('Edit your biography'), class_='ckeditor')}
  ${h.input_submit(_('Save'))}
</form>
