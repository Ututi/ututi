<%inherit file="/forum/base.mako" />

% if c.group_id is not None:
  <div class="back-link">
    <a class="back-link" href="${url(controller=c.controller, action='categories', id=c.group_id)}">${_('Back to category list')}</a>
  </div>
% endif

<%def name="forum_thread_list(category, n, messages=None, class_='', pager=False)">

  <div class="portlet portletSmall portletGroupFiles ${class_}">
    <div class="ctl"></div>
    <div class="ctr"></div>
    <div class="cbl"></div>
    <div class="cbr"></div>
    <div class="single-title">
      <div class="floatleft bigbutton2">
        <h2 class="portletTitle bold category-title">
          <a href="${category.url()}" class="grey">${category.title}</a>
          %if c.user and c.security_context and h.check_crowds(['admin', 'moderator']):
            ${h.link_to(_('Edit category'), url(controller=c.controller, action='edit_category', id=c.group_id, category_id=category.id), class_='edit-category')}
          %endif
        </h2>
        <p class="grey verysmall">${category.description}</p>
      </div>
      <div style="float: right; padding-top: 4px">
        ${h.button_to(_('New topic'), url(controller=c.controller, action='new_thread', id=c.group_id, category_id=category.id))}
      </div>
      <div class="clear"></div>
    </div>

    <div class="single-messages">

      <% if messages is None:
             messages = category.top_level_messages()
      %>

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
              <a href="${forum_post['author'].url()}">${h.ellipsis(forum_post['author'].fullname, 30)}</a>
            </div>
            <div class="grey verysmall">${post_date}</div>
          </div>
          <br style="clear: left;" />
        </div>
      % endfor

    </div>

    % if len(messages) > n:
      <div class="kiti-failai-100">
        <a href="${category.url()}">
          <span class="green verysmall">${ungettext("Show other %(count)s message", "Show other %(count)s messages", (len(messages)- n)) % dict(count = (len(messages)- n))}</span>
          <span>
            <img src="${url('/img/icons/arrow-very-small-down.png')}" alt="">
          </span>
        </a>
      </div>
    % endif

    <div class="forum_category_footer" style="padding: 10px 0 6px 10px;">
	% if c.user and messages:
        ${h.button_to(_('Mark all as read'), url(controller=c.controller, action='mark_category_as_read', id=c.group_id, category_id=category.id))}
	% elif not messages:
        ${_('There are no forum messages.')}
	% endif
    </div>
  </div>

  % if pager and hasattr(messages, 'pager'):
    <div id="pager">
        ${messages.pager(format='~3~', controller=c.controller, action='index', id=c.group_id, category_id=category.id)}
    </div>
  % endif

</%def>

${forum_thread_list(c.category, messages=c.threads, n=10000, class_=('smallTopMargin' if c.group_id else 'mediumTopMargin'), pager=True)}
<!-- TODO: pagination -->
