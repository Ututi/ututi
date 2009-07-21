<%inherit file="/base.mako" />

<%def name="title()">

</%def>

<a class="back-link" href="${c.subject.url()}">${_('Go back to %(subject_title)s') % dict(subject_title=c.subject.title)}</a>

<h1 id="page_header">${c.page.title}</h1>
<form method="GET" action="${h.url_for(action='edit')}">
  <span class="btn">
    <input type="submit" value="${_('Edit')}"/>
  </span>
</form>

<div id="page_content">
  ${c.page.content|n}
</div>
