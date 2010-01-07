<%inherit file="/admin/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('Ututi users:')}</h1>

<div>
  <span>Sort by:</span>
  %for title, order in [(_('Downloads'), 'downloads'), \
                        (_('Downloads (Mb)'), 'downloads_size'), \
                        (_('Uploads'), 'uploads'), \
                        (_('Pages'), 'pages'), \
                        (_('Messages'), 'messages'), \
                        (_('User Id'), 'id')]:
  ${h.link_to(title, url(controller='admin', action='users', order_by=order, from_time=c.from_time_str, to_time=c.to_time_str))}
  %endfor

  <form action="${url(controller='admin', action='users')}">
    <input type="hidden" name="order_by" value="${request.params.get('order_by', 'id')}" />
    ${h.input_line('from_time', "From", value=c.from_time_str)}
    ${h.input_line('to_time', "To", value=c.to_time_str)}
    ${h.input_submit('Filter')}
  </form>
</div>

<div id="search-results-container">
  <h3 class="underline search-results-title">
    <span class="result-count">(${ungettext("found %(count)s user", "found %(count)s users", c.users.item_count) % dict(count = c.users.item_count)})</span>
  </h3>
  <ul id="user_list">
    %for n, (user, downloads, downloads_size, uploads, messages, pages) in enumerate(c.users):
     <li style="background: ${n % 2 and '#EEEEEE' or '#FFFFFF'}"><a href="${user.url()}">${user.fullname}</a>
     % if user.logo is not None:
        <img style="float:right; padding: 3px;" src="${url(controller='user', action='logo', id=user.id, width=72, height=72)}" />
     % endif
        <div>
          Downloads: ${downloads} (${h.file_size(int(downloads_size))})
        </div>
        <div>
          Uploads: ${uploads}
        </div>
        <div>
          Pages: ${pages}
        </div>
        <div>
          Messages: ${messages}
        </div>
        <div>
          Joined: ${user.accepted_terms}
        </div>
     </li>
    %endfor
  </ul>
  <div id="pager">${c.users.pager(format='~3~') }</div>
</div>
