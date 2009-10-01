<%inherit file="/base.mako" />
<%namespace file="/portlets/structure.mako" import="*"/>

<%def name="portlets()">
<div id="sidebar">
  ${struct_info_portlet()}
</div>
</%def>

<%def name="title()">
  Ututi: ${c.location.title}
</%def>

<%def name="head_tags()">
${parent.head_tags()}
${h.stylesheet_link('/stylesheets/location.css')|n}
</%def>

<h1>${c.location.title}</h1>
<form method="post" action="${c.location.url(action='update')}" name="edit_structure_form" enctype="multipart/form-data" class="edit-form">
      <div class="form-field">
        <input type="hidden" name="old_path" value=""/>
        <label for="title">${_('Title')}</label>
        <form:error name="title"/>
        <div class="input-line"><div>
            <input type="text" id="title" name="title" value=""/>
        </div></div>
      </div>
      <div class="form-field">
        <label for="title_short">${_('Short title')}</label>
        <form:error name="title_short"/>
        <div class="input-line"><div>
            <input type="text" id="title_short" name="title_short" value=""/>
        </div></div>
      </div>
      <div class="form-field">
        <label for="site_url">${_('Website')}</label>
        <form:error name="site_url"/>
        <div class="input-line"><div>
            <input type="text" id="site_url" name="site_url" value=""/>
        </div></div>
      </div>
      <div class="form-field">
        <label for="logo_upload">${_('Logo')}</label>
        <form:error name="logo_upload"/>
        <input type="file" name="logo_upload" id="logo_upload" class="line"/>
      </div>
      <div class="form-field">
        <input type="checkbox" name="logo_delete" id="logo_delete" value="true"/>
        <label for="logo_delete">${_('Delete current logo')}</label>
      </div>
      <div class="form-field">
        <span class="btn"><input type="submit" name="action" value="${_('Save')}"/></span>
      </div>
</form>
