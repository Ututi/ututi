<%inherit file="/page/base.mako" />

<%def name="title()">
   ${h.ellipsis(c.page.title, 30)} - ${h.ellipsis(c.subject.title, 30)}
</%def>

<a class="back-link" href="${c.page.url()}">${_('Go back to page')}</a>

<div id="page_header">
  <h1 style="float: left;">${c.page.title}</h1>
</div>

<div class="clear-left"></div>

<div class="notes-header">
  <h2 class="page-title">${c.page.title}</h2>
</div>
  <table id="wiki_history">
  % for version in c.page.versions:
     <%
        class_ = 'wiki-tekstas' if version is not c.page.versions[-1] else 'wiki-tekstas-last'
     %>
        <tr class="${class_}">
          <td>
            <a href="${version.created.url()}">${version.created.fullname}</a><span class="grey verysmall">, ${h.fmt_dt(version.created_on)}</span>
          </td>
          <td>
            <div style="float: right;">
              ${h.button_to(_('Show'), version.url(), method='POST')}
            </div>
            % if version is not c.page.versions[-1]:
              <div style="float: right;">
                ${h.button_to(_('Compare with previous'),  version.url(action='diff_with_previous'), method='POST')}
              </div>
            % endif

          </td>
        </tr>
  % endfor
  </table>
