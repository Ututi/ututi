<%inherit file="/page/base.mako" />

<%def name="title()">
   ${h.ellipsis(c.page.title, 30)} - ${h.ellipsis(c.subject.title, 30)}
</%def>

<a class="back-link" href="${h.url_for(action='history')}">${_('Go back to history')}</a>

<div id="page_header">
  <h1 style="float: left;">${c.version.title}</h1>
</div>

<div id="old-version-note" class="clear-left small">
  % if c.version is not c.page.versions[0]:
      ${h.literal(
         _('You are viewing an old version of this page created'
          ' by %(link_to_user)s on %(date)s') % dict(
                link_to_user=h.link_to(c.version.created.fullname,
                                       c.version.created.url()),
                date=h.fmt_dt(c.version.created_on)))}
  % endif
</div>
<br />

<div id="page_content">
  ${h.latex_to_html(h.html_cleanup(c.version.content))|n}
</div>
