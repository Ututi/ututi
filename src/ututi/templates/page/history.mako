<%inherit file="/page/base.mako" />

<%def name="title()">
   ${h.ellipsis(c.page.title, 30)} - ${h.ellipsis(c.subject.title, 30)}
</%def>

<a class="back-link" href="${c.page.url()}">${_('Go back to page')}</a>

<div id="page_header">
  <h1 style="float: left;">${c.page.title}</h1>
</div>

<div class="clear-left"></div>

<table>
  % for version in c.page.versions:
    <tr>
      <td><a href="${version.created.url()}">${version.created.fullname}</a></td>
      <td>${h.fmt_dt(version.created_on)}</td>
      <td>
          ${h.button_to(_('Show'), version.url(), method='POST')}
      </td>
      <td>
        % if version is not c.page.versions[-1]:
          ${h.button_to(_('Compare with previous'),  version.url(action='diff_with_previous'), method='POST')}
        % endif
      </td>
    </tr>
  % endfor
</table>
