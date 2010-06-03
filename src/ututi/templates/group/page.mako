<%inherit file="/group/base.mako" />

<%def name="watched_subject(subject)">
  <li>
    <a href="${subject.url()}">${subject.title}</a>
  </li>
</%def>

<div id='body-container'>
  %if c.group.page != '':
  ${h.html_cleanup(c.group.page)|n,decode.utf8}
  %else:
  ${_("The group's page is empty. Enter your description.")}
  %endif
</div>

<br />
<div>
  <a class="btn" href="${url(controller='group', action='edit_page', id=c.group.group_id)}" title="${_('Edit group front page')}">
    <span>${_('Edit')}</span>
  </a>
</div>
