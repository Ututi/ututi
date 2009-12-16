<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('Ututi users:')}</h1>

<div id="search-results-container">
  <h3 class="underline search-results-title">
    <span class="result-count">(${ungettext("found %(count)s user", "found %(count)s users", c.users.item_count) % dict(count = c.users.item_count)})</span>
  </h3>
  <ul id="user_list">
    %for user in c.users:
     <li><a href="${user.url()}">${user.fullname}</a> joined ${user.accepted_terms} (${len(user.downloads)})
     % if user.logo is not None:
        <img src="${url(controller='user', action='logo', id=user.id, width=45, height=60)}" />
     % endif
     </li>
    %endfor
  </ul>
  <div id="pager">${c.users.pager(format='~3~') }</div>
</div>
