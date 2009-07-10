<%inherit file="/base.mako" />

<%def name="title()">

</%def>

<div id="page_content">
${c.page.content}
</div>
<form method="GET" action="${h.url_for(controller='page', action='edit', id=c.page.id)}">
<span class="btn">
<input type="submit" value="${_('Edit')}"/>
</span>
</form>
