<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/structure.mako" import="*"/>

<%def name="portlets()">
<div id="sidebar">
  ${struct_info_portlet()}
</div>
</%def>

<%def name="title()">
  Ututi: ${c.location.title}
</%def>

<h1>${c.location.title}</h1>
<form method="post" action="${c.location.url(action='update')}" name="edit_structure_form" enctype="multipart/form-data" class="edit-form fullForm">
      <div style="display: none;">
        <input type="hidden" name="old_path" value=""/>
      </div>
      ${h.input_line('title', _('Title'))}
      ${h.input_line('title_short', _('Short title'))}
      ${h.input_line('site_url', _('Website'))}
      <div class="form-field">
        <label for="logo_upload">${_('Logo')}</label>
        <form:error name="logo_upload"/>
        <input type="file" name="logo_upload" id="logo_upload" class="line"/>
      </div>
      <div class="form-field">
        <label for="logo_delete">
          <input type="checkbox" name="logo_delete" id="logo_delete" value="true"/>
          ${_('Delete current logo')}
        </label>
      </div>
      ${h.input_submit(_('Save'))}
</form>
