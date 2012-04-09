<%inherit file="/admin/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
</%def>

<h1>${_('Browse the hierarchy')}</h1>
<a href="${url(controller='structure', action='regions')}">Edit regions</a>
<%def name="location_tag(tag)">
  <li>
    <a href="${tag.url()}" class="tag_link">${tag.title}</a>
        % if tag.logo is not None:
           <img src="${url(controller='structure', action='logo', id=tag.id, width=60, height=60)}" />
        % endif
          <a class="edit" href="${url(controller='structure', action='edit', id=tag.id)}">${_('[Edit]')}</a>
  </li>
  %if tag.children:
    <ul>
      %for child in tag.children:
        ${location_tag(child)}
      %endfor
    </ul>
  %endif
</%def>

%if c.structure:
  <ul id="location_structure">
    %for tag in c.structure:
      ${location_tag(tag)}
    %endfor
  </ul>
%endif

<br />

<h2>${_('Create new')}</h2>
<form method="post" action="${url(controller='structure', action='create')}"
      name="new_structure_form" id="new_structure_form" class="fullForm"
      enctype="multipart/form-data">

   ${h.input_line('title', _('Title'))}
   ${h.input_line('title_short', _('Short title'))}
   ${h.input_area('description', _('Description'))}

   <div>
     <label for="region">${_('Region')}</label>
     <select id="region" name="region">
       <option value="0">${_('(none)')}</option>
       %for region in c.regions:
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
   ${h.input_submit(_('Create'))}
</form>
