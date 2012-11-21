<%namespace file="/elements.mako" import="item_box" />

<%doc>
Snippets for rendering various content items, e.g. in search results.
</%doc>

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
  <%
  any_tags = False
  for tag in object.tags:
    if tag.title:
      any_tags = True
  %>
  %if any_tags:
  <span class="item-tags">
    <% length = len(object.tags) %>
    %for n, tag in enumerate(object.tags):
      %if n != length - 1:
        ${tag_link(tag)},
      %else:
        ${tag_link(tag)}
      %endif
    %endfor
  </span>
  %endif
</%def>

<%def name="item_location(object)">
  %if object.location:
  <span class="location-tags short">
  %for tag in object.location.hierarchy(True):
    <a href="${tag.url()}">${tag.title_short}</a> |
  %endfor
  </span>
  %endif
</%def>

<%def name="item_location_full(object)">
  %if object.location:
  <%
    hierarchy_len = len(object.location.hierarchy())
  %>
  <span class="location-tags">
  %for index, tag in enumerate(object.location.hierarchy(True)):
    <a href="${tag.url()}">${tag.title}</a>
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

<%def name="teacher(object)">
  <div class="search-item snippet-teacher clearfix with-logo">
    <div class="logo">
      <img src="${object.url(action='logo', width=45)}" alt="object.fullname" />
    </div>
    <div class="heading">
      <div class="item-title">
        %if c.user is None:
          <a href="${object.url(action='external_teacher_index')}" title="${object.fullname}">${object.fullname}</a>
        %else:
          <a href="${object.url()}" title="${object.fullname}">${object.fullname}</a>
        %endif
      </div>
    </div>
    <ul class="statistics icon-list">
        <li class="icon-file">${h.authorship_count('file', object.id)}</li>
        <li class="icon-note">${h.authorship_count('page', object.id)}</li>
        <li class="icon-subject">${h.teacher_subjects(object.id)}</li>
        <li class="icon-group">${h.teacher_groups(object.id)}</li>
    </ul>
    ${item_location(object)}
  </div>
</%def>

<%def name="group(object, list_members=False)">
  <div class="search-item snippet-group">
    %if c.user is not None:
      <div class="action-button">
        %if object in c.user.groups:
          <div class="notice">Your group</div>
          <a href="${object.url(action='leave')}">Leave group</a>
        %else:
          ${h.button_to(_('Join'), object.url(action='request_join'), class_='dark add')}
        %endif
      </div>
    %endif

    <div class="heading">
      <div class="item-title">
        <a href="${object.url()}" title="${object.title}">${object.title}</a>
      </div>
      ${item_location(object)}
    </div>

    <div class="description">
      ${object.description}
    </div>
    <ul class="statistics icon-list">
        <li class="icon-time">${h.when(object.created_on)}</li>
        <li class="icon-file">${h.item_file_count(object.id)}</li>
        <li class="icon-subject">${h.group_subjects(object.id)}</li>
        <li class="icon-user">${h.group_members_count(object.id)}</li>
    </ul>

    %if list_members:
      ${item_box(h.group_members(object.id, 8), per_row=8)}
    %endif
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
    %if c.user is not None and not c.user.watches(object) \
        and not c.user.is_teacher:
      <div class="action-button">
        ${h.button_to(_('Follow'), object.url(action='watch'), class_='dark add')}
      </div>
    %endif
    <div class="heading">
      <div class="item-title">
        <a href="${object.url()}" title="${object.title}">${object.title}</a>
      </div>
    </div>
    <div class="description">
      ${item_location(object)}
      %if object.teacher_repr:
       ${object.teacher_repr}
      %endif
      %if object.tags:
       ${item_tags(object)}
      %endif
    </div>
    <ul class="statistics icon-list">
        <li class="icon-file">${len(object.files)}</li>
        <li class="icon-note">${len(object.pages)}</li>
        <li class="icon-group">${object.group_count()}</li>
        <li class="icon-user">${object.user_count()}</li>
    </ul>
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

<%def name="book(object)">
  <div class="search-item snippet-book">
    <a href="${object.url()}" title="${object.title}" class="item-title larger bold">${object.title}</a> (${_('Book')})
    <div class="description">
      ${h.ellipsis(object.description, 200)}
    </div>
    <div class="description">
      %if object.city:
          <span class="book-city-label">${_('City')}:</span>
          <span class="book-city-name"> ${object.city.name}</span>
          <br />
      %endif
      <span class="book-price-label">${_('Price')}:</span>
      <span class="book-price">
        ${object.price}
      </span>
    </div>
  </div>
</%def>

<%def name="blog_post(post, show_full=True, type='internal', title_link=False, show_comment_form='True')">
    <%
      link = post.url() if type == 'internal' else post.url(path=post.created.location.url_path, action='external_teacher_blog_post')
      comment_form_link = link + '#comment-form'
      comment_link = link + '#comment' if post.comments else comment_form_link
    %>
    %if title_link:
      <div class="title"><a href="${link}">${post.title}</a></div>
    %else:
      <div class="title">${post.title}</div>
    %endif
    <div class="comment-label">
      <a href="${link}#comments">${ungettext("%(count)s comment", "%(count)s comments", len(post.comments)) % dict(count=len(post.comments))}</a>
    </div>
    <div class="post-date date-label">${h.fmt_normaldate(post.created_on)}</div>
    <div class="blog-post">
      ${h.literal(post.description)}
    </div>
    %if show_full:
      <div class="blog-comments">
        <a name='comments'></a>
        %if post.comments:
          <h2>${_('Comments:')}</h2>
          %for comment in post.comments:
            <div class="comment">
              %if c.user and (c.user.id == post.created.id or c.user.id == comment.created.id):
              <div style="position: absolute; right: 4px; top: 8px;">
                <form action="${url(controller='user', action='teacher_delete_blog_comment', id=post.created.id, post_id=post.id)}" method="POST">
                  <input type="hidden" name="comment_id" value="${comment.id}"/>
                  <input type="image" src="${url('/img/icons.com/close.png')}"/>
                </form>
              </div>
              %endif
              <div class="comment-date date-label">${h.when(comment.created_on)}</div>
              <div class="logo">
                <img src="${url(controller='user', action='logo', id=comment.created.id, width=50)}" />
              </div>
              <div class="comment-author">${h.user_link(comment.created_by)}</div>
              <div class="comment-content">
                ${h.wall_fmt(comment.content)}
              </div>
            </div>
          %endfor
        %endif
        %if show_comment_form:
          %if c.user:
          <a name='comment-form'></a>
          <div class='comment-form'>
            <form  action="${url(controller='user', action='teacher_blog_comment', id=post.created.id, post_id=post.id)}" method="POST">
              ${h.input_area('content', _('Comment'), help_text=_('Write a comment'), cols='160')}
              ${h.input_submit(_('Send'))}
            </form>
          </div>
          %else:
            <a href="${url(controller='home', action='login', came_from=comment_link)}">${_('Login to comment')}</a>
          %endif
        %endif
      </div>
    %else:
      %if c.user:
      <a href="${link}#comment-form">${_('Write a comment')}</a>
      %else:
      <a href="${url(controller='home', action='login', came_from=comment_form_link)}">${_('Login to comment')}</a>
      %endif
    %endif
</%def>
