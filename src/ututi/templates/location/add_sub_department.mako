<%inherit file="/location/edit_base.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
</%def>

<div>
  <div class="explanation-post-header" style="margin-top:0">
    <h2>${_('Add sub-department')}</h2>
  </div>
  <%self:form filler="${c.form}">
  <form method="post" action="${c.location.url(action='add_sub_department')}"
        name="edit_structure_form" class="edit-form">
    ${h.input_line('title', _("Sub department title:"))}
    ${h.input_line('site_url', _("Website link:"))}
    ${h.input_wysiwyg('description', _("Description:"))}
    ${h.input_submit(name='ADD')}
  </form>
  </%self:form>
</div>
