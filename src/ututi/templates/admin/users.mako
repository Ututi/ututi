<%inherit file="/admin/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<style type="text/css">
  table#user_list th {
    font-weight: bold;
    padding: 5px;
  }
</style>

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
  <table id="user_list">
    %for n, (user, downloads, u_downloads, downloads_size, uploads, messages, pages) in enumerate(c.users):
    % if n % 20 == 0:
      <tr style="text-align: center">
        <th></th>
        <th>Name</th>
        <th></th>
        <th>Downloads</th>
        <th>Uploads</th>
        <th>Pages</th>
        <th>Messages</th>
        <th>Accepted terms</th>
        <th>Logo</th>
      </tr>
    % endif
    <tr style="background: ${n % 2 and '#EEEEEE' or '#FFFFFF'}">
       <td>
         ${c.users.first_item + n}.
       </td>
        <td style="white-space: nowrap">
         <a href="${user.url()}">${user.fullname}</a>
         % for medal in user.all_medals():
          ${medal.img_tag()}
         % endfor
       </td>

       <td style="font-weight: bold; white-space: nowrap; color: #5a0; padding-right: 10px">
         % if user.phone_confirmed:
           P
         % endif
         % if user.openid:
           G
         % endif
         % if user.facebook_id:
           F
         % endif
       </td>

        <td>
          ${downloads} (${h.file_size(int(downloads_size))})
          <br />
          ${u_downloads} unique
        </td>
        <td style="text-align: center">
          ${uploads}
        </td>
        <td style="text-align: center">
          ${pages}
        </td>
        <td style="text-align: center">
          ${messages}
        </td>
        <td style="text-align: center; white-space: nowrap">
          ${h.fmt_dt(user.accepted_terms)}
        </td>
        % if user.logo is not None:
           <td>
              <img style="padding: 3px;" src="${url(controller='user', action='logo', id=user.id, width=72, height=72)}" />
           </td>
        % endif
    </tr>
    %endfor
  </table>
  <div id="pager">${c.users.pager(format='~3~') }</div>
</div>
