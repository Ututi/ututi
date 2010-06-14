<%inherit file="/forum/base.mako" />

% if c.group_id is not None:
  <a class="back-link" href="${url(controller=c.controller, action='categories', id=c.group_id)}">${_('Back to category list')}</a>
% endif

<h1>${c.category.title}</h1>

<%def name="forum_thread_list(category, n)">

  <div class="portlet portletSmall portletGroupFiles">
    <div class="ctl"></div>
    <div class="ctr"></div>
    <div class="cbl"></div>
    <div class="cbr"></div>
    <div class="single-title">
      <div class="floatleft bigbutton2">
        <h2 class="portletTitle bold category-title"><a href="${category.url()}" class="blark">${category.title}</a></h2>
        <p class="grey verysmall">${category.description}</p>
      </div>
      <div style="float: right">
        ${h.button_to(_('New topic'), url(controller=c.controller, action='new_thread', id=c.group_id, category_id=category.id))}
      </div>
      <div class="clear"></div>
    </div>

    <div class="single-messages">

      <% messages = category.top_level_messages() %>

      % for forum_post in messages[:n]:
        <%
            new_post = forum_post['post'].first_unseen_thread_post(c.user)
            post_url = url(controller=c.controller, action='thread', id=c.group_id, category_id=category.id, thread_id=forum_post['thread_id'])
            post_title = forum_post['title']
            post_text = forum_post['post'].message
            post_date = h.fmt_dt(forum_post['created'])
        %>
        <div class="${'message-list-on1' if new_post else 'message-list-off1'}">
          <div class="floatleft m-on">
            <div class="orange ${'bold' if new_post else ''}">
              <a href="${post_url}" class="post-title">${post_title}</a>
              <span class="reply-count">
              (${ungettext("%(count)s reply", "%(count)s replies", forum_post['reply_count']) % dict(count = forum_post['reply_count'])})
              </span>
            </div>
            <div class="grey verysmall">${h.ellipsis(post_text, 50)}</div>
          </div>
          <div class="floatleft user">
            <div class="orange bold verysmall">
              <a href="${forum_post['author'].url()}">${forum_post['author'].fullname}</a>
            </div>
            <div class="grey verysmall">${post_date}</div>
          </div>
        </div>
      % endfor

    </div>

    % if len(messages) > n:
      <div class="kiti-failai-100">
        <a href="${category.url()}">
          <span class="green verysmall">parodyti kitus <span class="bold green verysmall">(${len(messages) - n})</span> failus</span>
          <span>
            <img src="/img/icons/arrow-very-small-down.png" alt="">
          </span>
        </a>
      </div>
    % endif

      <div style="margin: 5px 0 0 10px;">
	% if c.user and messages:
	${h.button_to(_('Mark all as read'), url(controller=c.controller, action='mark_category_as_read', id=c.group_id, category_id=category.id))}
	% elif not messages:
        ${_('There are no forum messages.')}
	% endif
      </div>
  </div>
</%def>

${forum_thread_list(c.category, n=10000)}
<!-- TODO: pagination -->
