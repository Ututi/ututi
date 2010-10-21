<%inherit file="/profile/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${parent.head_tags()}
</%def>

<%def name="pagetitle()">
  ${_("What's new?")}
</%def>

<div class="tip">
${_('This is a list of all the recent events in the subjects you are watching and the groups you belong to.')}
</div>

% for event in c.events:
  ${event.snippet()}
% endfor
