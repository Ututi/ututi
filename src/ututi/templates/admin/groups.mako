<%inherit file="/admin/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<style type="text/css">
  table#groups_list th {
    font-weight: bold;
    padding: 5px;
  }
</style>

<h1>${_('Groups')}</h1>

%if c.groups:
    <table class="groups_list">
    %for n, group in enumerate(c.groups):
    %if n % 20 == 0:
      <tr style="text-align: center">
        <th></th>
        <th>Name (members)</th>
        <th>Region</th>
        <th>Emails</th>
        <th>Files</th>
        <th>Subjects</th>
        <th>Invitations</th>
        <th>Creation date</th>
        <th>Logo</th>
      </tr>
    %endif
    <tr style="background: ${n % 2 and '#EEEEEE' or '#FFFFFF'}">
       <td>
         ${c.groups.last_item - n}.
       </td>
       <td>
         <a href="${url(controller='group', action='home', id=group.group_id)}">${group.title} (${len(group.members)})</a>
       </td>
       <td>
         %if group.location:
            %if group.location.region:
               ${group.location.region.title}
            %endif
         %endif
       </td>
       <td>${group.message_count}</td>
       <td>${len(group.files)}</td>
       <td>${len(group.watched_subjects)}</td>
       <td>${len(group.invitations)}</td>
       <td>${h.fmt_dt(group.created_on)}</td>
       % if group.logo is not None:
          <td>
            <img style="padding: 3px;" src="${url(controller='group', action='logo', id=group.group_id, width=72, height=72)}" />
          </td>
       % endif
    </tr>
    %endfor
  </table>
  <div id="pager">${c.groups.pager(format='~3~') }</div>
%endif
