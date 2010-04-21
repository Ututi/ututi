<%inherit file="/page/base.mako" />

<%def name="title()">
   ${h.ellipsis(c.page.title,30)} - ${h.ellipsis(c.subject.title, 30)}
</%def>

<a class="back-link" href="${h.url_for(action='history')}">${_('Go back to history')}</a>

<div id="page_header">
  <h1 style="float: left;">${c.page.title}</h1>
  % if c.version is not c.page.versions[0]:
    <div style="float: left; margin-top: 8px; margin-left: 10px;">
      <a class="btn" href="XXX"><span>${_('Restore')}</span></a>
    </div>
  % endif
</div>

<div class="clear-left">
</div>

<div id="page_content">
    ${c.diff}
</div>
