<%inherit file="/group/base.mako" />

<%def name="watched_subject(subject)">
  <li>
    <a href="${subject.url()}">${subject.title}</a>
  </li>
</%def>

<div id="page_content">
  %if c.group.page != '':
    <div class="wiki-page">
    ${h.html_cleanup(c.group.page)}
    </div>
  %else:
    <%self:rounded_block id="page-placeholder-frame">
      <div id="page-placeholder" class="content">

        <h2>${_('What is a group notes and who sees it?')}</h2>
        <p>
          ${_('The group notes is the face of the group. It may be public or visible only to group members, depending on configuration.')}
          ${_('You can change visibility settings in the <a href="%s">group settings</a> screen.') % c.group.url(action='edit') |n}
        </p>

        <h2>${_('What are the uses of a group notes?')}</h2>

        <ul>
          <li>
            ${_('Calendaring. Read this <a href="http://blog.ututi.lt/2009/05/28/naudotoju-isradingumas/">blog post</a> for more information.') |n}
          </li>
          <li>
            ${_('A news board for timetables and posters.')}
          </li>
          <li>
            ${_('Description of the group for users who are not members of the group yet.')}
          </li>
        </ul>

        <h2 style="padding-bottom: 0">${_('Edit your group note now!')}</h2>
      </div>
    </%self:rounded_block>
  %endif
</div>

<div style="padding-left: 10px">
  ${h.button_to(_('Edit note'), url(controller='group', action='edit_page', id=c.group.group_id))}
</div>
