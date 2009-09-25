<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${c.item.title}</h1>
<form method="post" action="${url(controller='structure', action='update', id=c.item.id)}" name="edit_structure_form" enctype="multipart/form-data">
      <div>
        <label for="title">${_('Title')}</label>
        <div class="input-line"><div>
            <input type="text" id="title" name="title" value="${c.item.title}"/>
        </div></div>
      </div>
      <div>
        <label for="title_short">${_('Short title')}</label>
        <div class="input-line"><div>
            <input type="text" id="title_short" name="title_short" value="${c.item.title_short}"/>
        </div></div>
      </div>
      <div>
        <label for="description">${_('Description')}</label>
        <textarea class="ckeditor" name="description" id="description" cols="80" rows="25">${c.item.description}</textarea>
      </div>
      <div
        <label for="parent">${_('Parent')}</label>
        <select id="parent" name="parent">
               <option value="0">${_('Select a parent')}</option>
               %if c.structure:
                   %for parent in c.structure:
                        <option value="${parent.id}"
                        %if c.item.parent == parent.id:
                        selected="selected"
                        %endif
                        >${parent.title}</option>
                   %endfor
               %endif
        </select>
      </div>
      <div>
        <label for="logo_upload">${_('Logo')}</label>
        <input type="file" name="logo_upload" id="logo_upload" class="line"/>
      </div>
      <div>
        <input type="checkbox" name="logo_delete" id="logo_delete" value="true"/>
        <label for="logo_delete">${_('Delete current logo')}</label>
      </div>
      <div>
        <span class="btn"><input type="submit" name="action" value="${_('Save')}"/></span>
        <span class="btn"><input type="submit" name="action" value="${_('Delete')}"/></span>
      </div>
</form>
