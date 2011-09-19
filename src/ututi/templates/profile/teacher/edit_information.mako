<%inherit file="/profile/teacher/edit_text_base.mako" />

<%def name="css()">
  ${parent.css()}
  ul#language-links {
    text-align: right;
    margin-top: -20px;
    margin-bottom: 10px;
  }
  ul#language-links li {
    display: inline;
    margin-left: 10px;
    font-size: 11px;
  }
</%def>

<div class="explanation-post-header">
  <h2>${_('Write down your information and research interests')}</h2>
  <div class="tip">
    ## TRANSLATORS: please translate it as "profile page" (as in "on your profile page")
    <% link_to_profile_page = h.link_to(_('link_to_profile_page'), c.user.url(action='external_teacher_index')) %>
    ${h.literal(_('This information will be displayed on your %(profile_page_url)s.') % \
                dict(profile_page_url=link_to_profile_page))}
  </div>
</div>

${self.template_warning()}

<ul id="language-links">
  %for language in c.edit_languages:
    %if language is c.edit_language:
      <li class="cont-lang ${language.id}" ><span >&nbsp;</span>${language.title}</li>
    %else:
      <li class="cont-lang ${language.id}">
            <a href="${url(controller='profile', action='edit_information', lang=language.id)}">
              <span>&nbsp;</span>
              ${language.title}
            </a>
      </li>
    %endif
  %endfor
</ul>

<form id="information-form" class="text-form" method="post" action="${url(controller='profile', action='update_information')}">
  ${h.input_hidden('language')}
  ${h.input_area('general_info_text', _('Edit your information'), class_='ckeditor')}
  ${h.input_submit(_('Save'))}
</form>
