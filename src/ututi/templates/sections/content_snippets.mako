<%def name="tag_link(tag)">
  %if c.user:
    <a class="tag" title="${tag.title}" href="${url(controller='profile', action='search', tags=', '.join(tag.hierarchy()))}">
      ${tag.title}
    </a>
  %else:
    <a class="tag" title="${tag.title}" href="${url(controller='search', action='index', tags=', '.join(tag.hierarchy()))}">
      ${tag.title}
    </a>
  %endif
</%def>

<%def name="item_tags(item)">
  <div class="item-tags">
    %for tag in object.location.hierarchy(full=True):
      ${tag_link(tag)}
    %endfor
    %for tag in object.tags:
      ${tag_link(tag)}
    %endfor
  </div>
</%def>

<%def name="generic(object)">
  <div class="search-item snippet-generic">
    <a href="${object.url()}" title="${object.title}" class="item-title larger">${object.title}</a>
    ${item_tags(object)}
  </div>
</%def>

<%def name="group(object)">
  <div class="search-item snippet-group">
    <a href="${object.url()}" title="${object.title}" class="item-title larger">${object.title}</a>
    <div class="description">
      ${object.description}
    </div>
    ${item_tags(object)}
  </div>
</%def>

<%def name="subject(object)">
  <div class="search-item snippet-subject">
    <a href="${object.url()}" title="${object.title}" class="item-title larger">${object.title}</a>
    <div class="description">
      ${object.lecturer}
    </div>
    ${item_tags(object)}
  </div>
</%def>

<%def name="page(object)">
  <div class="search-item snippet-page">
    <a href="${object.url()}" title="${object.title}" class="item-title larger">${object.title}</a>
    <div class="description">
      ${h.ellipsis(object.last_version.plain_text, 250)}
    </div>
    ${item_tags(object)}
  </div>
</%def>
