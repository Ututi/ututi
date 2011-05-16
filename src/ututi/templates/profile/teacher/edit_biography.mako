<%inherit file="/profile/edit_base.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
</%def>

<%def name="css()">
  ${parent.css()}
  #cke_description {
    width: 100% !important;
    padding: 0;
  }
  #cke_contents_description {
    height: 500px !important;
  }
  #biography-form .labelText {
    display: none;
  }
  p.warning {
    width: 50%;
  }
</%def>

<%def name="pagetitle()">${_("Your biography")}</%def>

<div class="explanation-post-header">
  <h2>${_('Write down your biography and research interests')}</h2>
  <div class="tip">
    ${h.literal(_('This information will be displayed on your %(profile_page_url)s.') % \
                dict(profile_page_url=h.link_to(_('profile page'), c.user.url())))}
  </div>
</div>

%if getattr(c, 'edit_template', False):
<p class="tip warning">
${_("Below you see a template that you can freely edit. "
    "Note that once your press \"Save\", it will become "
    "publicly available in your profile page.")}
</p>
%endif

<form id="biography-form" method="post" action="${url(controller='profile', action='update_biography')}">
  ${h.input_area('description', _('Edit your biography'), class_='ckeditor')}
  ${h.input_submit(_('Save'))}
</form>
