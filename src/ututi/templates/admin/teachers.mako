<%inherit file="/admin/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

%if c.found_users:
<h1>Found users:</h1>
<table id="teacher_list" style="width: 100%;">
  <tr>
    <th>${_('Fullname')}</th>
    <th>${_('Email')}</th>
    <th>${_('University')}</th>
    <th></th>
  </tr>

  %for teacher in c.found_users:
  <tr>
    <td class="name"><a href="${teacher.url()}" class="author-link">${teacher.fullname}</a></td>
    <td>${teacher.email.email}</td>
    <td>
      %if teacher.location is not None:
      <a href="${teacher.location.url()}">${', '.join(teacher.location.hierarchy())}</a>
      %else:
      -
      %endif
    </td>
    <td>
      <div style="float: left">${h.button_to(_('Make a teacher'), url(controller='admin', action='teacher_convert', command='deny', id=teacher.id))}</div>
    </td>
  </tr>
  %endfor
</table>

%else:
  <h1>${_('Unverified teachers')}</h1>

  %if c.teachers:
  <div id="search-results-container">
    <h3 class="underline search-results-title">
      <span class="result-count">(${ungettext("%(count)s teacher", "%(count)s teachers", len(c.teachers)) % dict(count = len(c.teachers))})</span>
    </h3>

    <table id="teacher_list" style="width: 100%;">
      <tr>
        <th>${_('Fullname')}</th>
        <th>${_('Email')}</th>
        <th>${_('University')}</th>
        <th>${_('Position')}</th>
        <th></th>
      </tr>

      %for teacher in c.teachers:
      <tr>
        <td class="name"><a href="${teacher.url()}" class="author-link">${teacher.fullname}</a></td>
        <td>${teacher.email.email}</td>
        <td>
          %if teacher.location is not None:
          <a href="${teacher.location.url()}">${', '.join(teacher.location.hierarchy())}</a>
          %else:
          -
          %endif
        </td>
        <td>${teacher.teacher_position}</td>
        <td>
          <div style="float: left">${h.button_to(_('Confirm'), url(controller='admin', action='teacher_status', command='confirm', id=teacher.id))}</div>
          <div style="float: left">${h.button_to(_('Deny'), url(controller='admin', action='teacher_status', command='deny', id=teacher.id))}</div>
        </td>
      </tr>
      %endfor
    </table>
  </div>
  %endif

%endif
<br/>
<h2>${_('Make any user a teacher:')}</h2>
<form method="post" action="${url(controller='admin', action='teachers')}" class="fullForm" id="user_search">
  <div>
    ${h.input_line('user_id', _('User ID'))}
    <strong>${_('or')}</strong>
    ${h.input_line('user_name', _('User name or email fragment'))}
    ${h.input_submit(_('Find'))}
  </div>
</form>
