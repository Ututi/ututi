<%inherit file="/subject/base_two_sidebar.mako" />

<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/sections/content_snippets.mako" import="item_location_full" />
<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="title()">
  ${_('Assign teacher')}
</%def>

<%def name="body()">
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
        <a href="${teacher.location.url()}">${', '.join(teacher.location.hierarchy())}</a>
      </td>
      <td>${teacher.teacher_position}</td>
      <td>
      %if teacher.teaches(c.subject):
        <div style="float: right">${h.button_to(_('Remove'), c.subject.url(action='teacher', command='remove', teacher_id=teacher.id))}</div>
      %else:
        <div style="float: right">${h.button_to(_('Assign'), c.subject.url(action='teacher', command='assign', teacher_id=teacher.id))}</div>
      %endif
      </td>
    </tr>
    %endfor
  </table>
</%def>
