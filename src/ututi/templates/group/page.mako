<%inherit file="/group/home.mako" />

<%def name="head_tags()">
${parent.head_tags()}
${h.stylesheet_link('/stylesheets/group.css')|n}
</%def>

<%def name="watched_subject(subject)">
  <li>
    <a href="${subject.url()}">${subject.title}</a>
  </li>
</%def>
<br />
<div id="page_header">
  <h1 style="float: left;">${_("Group front page")}</h1>
  <div style="float: left; margin-top: 8px; margin-left: 10px;">
    <a class="btn" href="${url(controller='group', action='edit_page', id=c.group.group_id)}" title="${_('Edit group front page')}">
      <span>${_('Edit')}</span>
    </a>
  </div>
</div>
<br class="clear-left" />
%if c.group.page != '':
${h.html_cleanup(c.group.page)|n,decode.utf8}
%else:
${_("The group's page is empty. Enter your description.")}
%endif
