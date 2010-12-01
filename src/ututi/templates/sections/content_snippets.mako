<%def name="location_tag_link(tag)">
  <a class="tag" title="${tag.title}" href="${tag.url()}">
    ${tag.title}
  </a>
</%def>

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
  <span class="item-tags">
    <%
       length = len(object.tags)
    %>
    %for n, tag in enumerate(object.tags):
      %if n != length -1:
        ${tag_link(tag)},
      %else:
        ${tag_link(tag)}
      %endif
    %endfor
  </span>
</%def>

<%def name="item_location(object)">
  %if object.location:
 <span class="green">
 <%
    hierarchy_len = len(object.location.hierarchy())
 %>

 %for index, tag in enumerate(object.location.hierarchy(True)):
   <a class="green" href="${tag.url()}">${tag.title_short}</a>
   %if index != hierarchy_len - 1:
        |
   %endif
 %endfor
 </span>
  %endif
</%def>

<%def name="generic(object)">
  <div class="search-item snippet-generic">
    <a href="${object.url()}" title="${object.title}" class="item-title larger bold">${object.title}</a>
    ${item_tags(object)}
  </div>
</%def>

<%def name="group(object)">
  <div class="search-item snippet-group">
    <a href="${object.url()}" title="${object.title}" class="item-title larger bold">${object.title}</a>
    <div class="description">
      ${object.description}
    </div>
    <div class="description">
      ${item_location(object)}
      %if object.tags:
       | ${item_tags(object)}
      %endif
    </div>
  </div>
</%def>

<%def name="file(object)">
  <div class="search-item snippet-file">
    <a href="${object.url()}" title="${object.title}" class="item-title larger bold">${object.title}</a>
    <div class="description">
      ${object.description}
    </div>
    <div class="description">
      ${item_location(object)}
      | <a class="verysmall" href="${object.parent.url()}">${object.parent.title}</a>
      %if object.parent.tags:
       | ${item_tags(object.parent)}
      %endif
    </div>
  </div>
</%def>

<%def name="subject(object)">
  <div class="search-item snippet-subject">
    <a href="${object.url()}" title="${object.title}" class="item-title bold larger">${object.title}</a>
    <span class="verysmall">(${_('Subject rating:')} </span><span>${h.image('/images/details/stars%d.png' % object.rating(), alt='', class_='subject_rating')|n})</span>
    <div class="description">
      ${item_location(object)}
      % if object.lecturer:
       | ${object.lecturer}
      % endif
      %if object.tags:
       | ${item_tags(object)}
      %endif
    </div>
    <dl class="stats">
       <%
           file_cnt = len(object.files)
           page_cnt = len(object.pages)
           group_cnt = object.group_count()
           user_cnt = object.user_count()
        %>

        <dd class="files">${ungettext('%(count)s <span class="a11y">file</span>', '%(count)s <span class="a11y">files</span>', file_cnt) % dict(count = file_cnt)|n}</dd>
        <dd class="pages">${ungettext('%(count)s <span class="a11y">wiki page</span>', '%(count)s <span class="a11y">wiki pages</span>', page_cnt) % dict(count = page_cnt)|n}</dd>
        <dd class="watchedBy"><span class="a11y">${_('Watched by:')}</span> 
          ${ungettext("%(count)s group", "%(count)s groups", group_cnt) % dict(count = group_cnt)|n}
          ${_('and')}
          ${ungettext("%(count)s member", "%(count)s members", user_cnt) % dict(count = user_cnt)|n}
        </dd>
    </dl>
  </div>
</%def>

<%def name="page(object)">
  <div class="search-item snippet-page">
    <a href="${object.url()}" title="${object.title}" class="item-title larger bold">${object.title}</a>
    <div class="description">
      ${h.ellipsis(object.last_version.plain_text, 250)}
    </div>
    <div class="description">
      ${item_location(object)}
      | <a class="verysmall" href="${object.subject[0].url()}">${object.subject[0].title}</a>
      %if object.tags:
       | ${item_tags(object)}
      %endif
    </div>
  </div>
</%def>

<%def name="page_extra(object)">
  ##page snippet with last edit and author info
  <div class="search-item snippet-page">
    % if object.deleted_on is not None:
      <span style="color: red; font-weight: bold">${_('[DELETED]')}</span>
    % endif
    <a href="${object.url()}" title="${object.title}" class="item-title larger bold">${object.title}</a>
    <span class="small" style="margin-left: 10px;">${h.fmt_dt(object.last_version.created_on)}</span>
    <a style="font-size: 0.9em;" href="${object.last_version.created.url()}">${object.last_version.created.fullname}</a>
    <div class="description">
      ${h.ellipsis(object.last_version.plain_text, 250)}
    </div>
    ${item_tags(object, all=False)}
  </div>
</%def>

<%def name="forum_post(object)">
  <div class="search-item snippet-forum_post">
    <a href="${object.url()}" title="${object.title}" class="item-title larger bold">${object.title}</a>
    <div class="description">
      ${h.ellipsis(object.message, 150)}
    </div>
    <div class="description">
      %if object.category.group:
        ${h.link_to(object.category.group.title, object.category.group.url())}
        | ${item_location(object.category.group)}
        %if object.tags:
         | ${item_tags(object.category.group)}
        %endif
      %else:
        ${h.link_to(object.category.title, object.category.url())}
      %endif
    </div>
  </div>
</%def>

<%def name="tooltip(text, style=None)">
  ${h.literal(h.image('/images/details/icon_question.png', 
              alt=text,
              class_='tooltip',
              style=style))}
</%def>

<%def name="tabs()">
<ul class="moduleMenu tabs" id="moduleMenu">
    %for tab in c.tabs:
      <li class="${'current' if tab['name'] == c.current_tab else ''}">
        <a href="${tab['link']}">${tab['title']}
            <span class="edge"></span>
        </a></li>
    %endfor
</ul>
</%def>
