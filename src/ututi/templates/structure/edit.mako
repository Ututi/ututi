<%inherit file="/admin/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
</%def>

<h1>${c.item.title}</h1>
<form method="post" action="${url(controller='structure', action='update', id=c.item.id)}"
      name="edit_structure_form" enctype="multipart/form-data" class="fullForm">

   <input type="hidden" name="old_path" value="" />
   ${h.input_line('title', _('Title'))}
   ${h.input_line('title_short', _('Short title'))}
   ${h.input_line('site_url', _('Website'))}
   ${h.input_area('description', _('Description'))}

   <div>
     <label for="region">${_('Region')}</label>
     <select id="region" name="region">
       <option value="0">${_('(none)')}</option>
       ## XXX Probably a bug. Region list is not populated if there are errors in edit form
       %for region in getattr(c, 'regions', []):
         <option value="${region.id}">${region.title}</option>
       %endfor
     </select>
   </div>

   <div>
     <label for="parent">${_('Parent')}</label>
     <select id="parent" name="parent">
            <option value="0">${_('Select a parent')}</option>
            %if c.structure:
                %for parent in c.structure:
                     <option value="${parent.id}">${parent.title}</option>
                %endfor
            %endif
     </select>
   </div>

   <label>${_('Logo')}
     <form:error name="logo_upload"/>
     <input type="file" name="logo_upload" id="logo_upload" />
   </label>

   <br />
   <label>
     <input type="checkbox" name="logo_delete" id="logo_delete" value="true"/>
     ${_('Delete current logo')}
   </label>

   <br />
   ${h.input_submit(_('Save'), name='action')}
   ${h.input_submit(_('Delete'), name='action')}
</form>
