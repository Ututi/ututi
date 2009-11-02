<%inherit file="/base.mako" />
<%namespace file="/portlets/user.mako" import="*"/>

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${h.stylesheet_link('/stylesheets/profile.css')|n}
  ${parent.head_tags()}
</%def>

<%def name="portlets()">
<div id="sidebar">
  ${blog_portlet()}
</div>
</%def>

<h1>${_('Blog snippets:')}</h1>

<a href="${url(controller='blog', action='add')}">${_('New entry')}</a>
<hr />

%if c.items:
  <ol id="entry_list">
    %for entry in c.items:
    <li><a href="${url(controller='blog', action='edit', id=entry.id)}">${entry.title}</a></li>
    %endfor
  </ol>
%else:
  No entries yet.
%endif
