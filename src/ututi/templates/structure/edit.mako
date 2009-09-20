<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${c.item.title}</h1>
<form method="post" action="${url(controller='structure', action='update', id=c.item.id)}" name="edit_structure_form">
      <div>
        <label for="title">${_('Title')}</label>
        <input type="text" id="title" name="title" value="${c.item.title}"/>
      </div>
      <div>
        <label for="title_short">${_('Short title')}</label>
        <input type="text" id="title_short" name="title_short" value="${c.item.title_short}"/>
      </div>
      <div>
        <label for="description">${_('Description')}</label>
        <textarea class="ckeditor" name="description" id="description" cols="80" rows="25">${c.item.description}</textarea>
      </div>
      <div>
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
        <span class="btn"><input type="submit" name="action" value="${_('Save')}"/></span>
        <span class="btn"><input type="submit" name="action" value="${_('Delete')}"/></span>
      </div>
</form>
