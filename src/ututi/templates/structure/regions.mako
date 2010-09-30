<%inherit file="/admin/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
</%def>

<a href="${url(controller='structure', action='index')}">Back to index</a>

<h1>${_('Regions for locations')}</h1>
<%def name="location_tag(tag)">
  <li>
    ${tag.title}
    %if c.user:
      <select name="tag-${tag.id}-region" style="position: absolute; left: 500px">
        <option value="0">${_('(none)')}</option>
        %for region in c.regions:
          <option value="${region.id}"
            ${'selected="selected"' if region.id == tag.region_id else ''}
            >${region.title}</option>
        %endfor
      </select>
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

<form method="post" action="${url(controller='structure', action='regions')}"
      class="fullForm">
  <ul id="location_structure">
    %for tag in c.structure:
      ${location_tag(tag)}
    %endfor
  </ul>
 ${h.input_submit(_('Save'), name='action')}
</form>
