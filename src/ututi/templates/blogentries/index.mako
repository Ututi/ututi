<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/user.mako" import="*"/>

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${parent.head_tags()}
</%def>

<%def name="portlets()">
  ${blog_portlet()}
</%def>

<h1>${_('Blog snippets:')}</h1>

<a href="${url(controller='blog', action='add')}">${_('New entry')}</a>
<hr />

%if c.items:
  <ol id="entry_list">
    %for entry in c.items:
    <li>${entry.content}<a href="${url(controller='blog', action='edit', id=entry.id)}">${_('Edit')}</a></li>
    %endfor
  </ol>
%else:
  No entries yet.
%endif
