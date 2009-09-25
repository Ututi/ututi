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

<%def name="item_tags(object, all=True)">
  <div class="item-tags">
    %if object.location and all:
      %for tag in object.location.hierarchy(full=True):
        ${tag_link(tag)}
      %endfor
    %endif
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

<%def name="page_extra(object)">
  ##page snippet with last edit and author info
  <div class="search-item snippet-page">
    <a href="${object.url()}" title="${object.title}" class="item-title larger">${object.title}</a>
    <span class="small" style="margin-left: 10px;">${h.fmt_dt(object.last_version.created_on)}</span>
    <a style="font-size: 0.9em;" href="${object.last_version.created.url()}">${object.last_version.created.fullname}</a>
    <div class="description">
      ${h.ellipsis(object.last_version.plain_text, 250)}
    </div>
    ${item_tags(object, all=False)}
  </div>
</%def>
