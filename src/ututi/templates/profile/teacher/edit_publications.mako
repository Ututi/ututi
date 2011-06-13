<%inherit file="/profile/teacher/edit_text_base.mako" />

<div class="explanation-post-header">
  <h2>${_('List your publications')}</h2>
  <div class="tip">
    ## TRANSLATORS: please translate it as "profile page" (as in "on your profile page")
    <% link_to_profile_page = h.link_to(_('link_to_profile_page'), c.user.url(action='external_teacher_index')) %>
    ${h.literal(_('Your publications will be displayed on your %(profile_page_url)s.') % \
                dict(profile_page_url=link_to_profile_page))}
  </div>
</div>

${self.template_warning()}

<form id="publications-form" class="text-form" method="post" action="${url(controller='profile', action='update_publications')}">
  ${h.input_area('publications', _('List your publications'), class_='ckeditor')}
  ${h.input_submit(_('Save'))}
</form>
