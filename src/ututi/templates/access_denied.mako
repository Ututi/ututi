<%inherit file="/ubase-width.mako" />

<%def name="head_tags()">
${parent.head_tags()}
</%def>
<div id="access_denied">
  <h1>${_('Permission denied!')}</h1>

  <img src="${url('/images/details/icon_nope.png')}" />

  <div>
  %if c.reason:
    ${c.reason}
  %else:
    ${_('You do not have the rights to see this page, or perform this action. Go back or go to the search page please.')}
  %endif
  </div>

  % if request.referrer.startswith(url("/", qualified=True)):
  <a href="#" onclick="javascript: history.go(-1); return false;">${_('go back')}</a>
  % else:
  <a href="${url(controller='search', action='index')}">${_('go find something else')}</a>
  % endif
</div>
