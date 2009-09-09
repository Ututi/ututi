<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('Browse the hierarchy')}</h1>
<%def name="location_tag(tag)">
  <li>
        ${tag.title}
        % if tag.logo is not None:
           <img src="${url(controller='structure', action='logo', id=tag.id)}" />
        % endif
        %if c.user:
            <a href="${url(controller='structure', action='edit', id=tag.id)}">${_('Edit')}</a>
        %endif
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
%endif

%if c.user:
<h2>${_('Create new')}</h2>
<form method="post" action="${url(controller='structure', action='create')}" name="new_structure_form" id="new_structure_form">
      <div>
        <label for="title">${_('Title')}</label>
        <input type="text" id="title" name="title"/>
      </div>
      <div>
        <label for="title_short">${_('Short title')}</label>
        <input type="text" id="title_short" name="title_short"/>
      </div>
      <div>
        <label for="description">${_('Description')}</label>
        <textarea class="ckeditor" name="description" id="description" cols="80" rows="25"></textarea>
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
      <div>
        <input type="submit" value="${_('Save')}"/>
      </div>
</form>
%endif
