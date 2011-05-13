<%inherit file="/base.mako" />

<%def name="head_tags()">
${parent.head_tags()}
</%def>

<h1>${_('Permission denied!')}</h1>

  <div id="permission-denied-message">
  %if c.reason:
    ${c.reason}
  %else:
    ${_('You do not have the rights to see this page, or perform this action. Go back or go to the search page please.')}
  %endif
  </div>

% if request.referrer is not None and request.referrer.startswith(url("/", qualified=True)):
    <a href="#" onclick="javascript: history.go(-1); return false;">${_('go back')}</a>
% else:
    <a href="${url(controller='search', action='index')}">${_('go find something else')}</a>
% endif
