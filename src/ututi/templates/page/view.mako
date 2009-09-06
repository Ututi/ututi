<%inherit file="/base.mako" />
<%namespace file="/portlets/subject.mako" import="*"/>

<%def name="portlets()">
<div id="sidebar">
  ${subject_info_portlet(c.subject)}
</div>
</%def>


<%def name="title()">
  ${c.subject.title} : ${c.page.title}
</%def>

<a class="back-link" href="${c.subject.url()}">${_('Go back to %(subject_title)s') % dict(subject_title=c.subject.title)}</a>

<div id="page_header">
  <h1 style="float: left;">${c.page.title}</h1>
  <div style="float: left; margin-top: 8px; margin-left: 10px;"><a class="btn" href="${h.url_for(action='edit')}"><span>${_('Edit')}</span></a></div>
</div>
<div class="clear-left small">
  ${_('Last edit:')}
  %if c.page.last_version:
    ${h.fmt_dt(c.page.last_version.created_on)}
    <a href="${c.page.last_version.created.url()}">${c.page.last_version.created.fullname}</a>
  %endif
</div>
<br/>
<div id="page_content">
  ${c.page.content|n}
</div>
