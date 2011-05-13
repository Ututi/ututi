<%inherit file="/base.mako" />

<%def name="head_tags()">
${parent.head_tags()}
</%def>


<h1>${_('Error!')}</h1>
<br/>
<div id="error-container">
  <div id="error-message">
    ${_("Our highly trained monkeys are fixing this problem right now.")}
  </div>
  <form id="error_message_form" class="fullForm" method="post" action="${url(controller='error', action='send_error')}" >
    <div>
      ${h.input_area("error_message", _("If You wish, You can shout at the monkeys:"))}
      <div style="margin-top: 10px;">
        ${h.input_submit(_("Shout!"), name="submit", value="shout", id="shout_btn")}
        <span style="font-size: 1.5em; font-weight: bold;">... ${_('or')} ...</span>
        ${h.input_submit(_("Kick a monkey!"), name="submit", value="kick", id="kick_btn")}
      </div>
    </div>
  </form>
</div>

% if request.referrer is not None and request.referrer.startswith(url("/", qualified=True)):
    <a href="#" onclick="javascript: history.go(-1); return false;">${_('go back')}</a>
% else:
    <a href="${url(controller='search', action='index')}">${_('go find something')}</a>
% endif

<div style="float: right; font-size: 0.8em; color: #888;">
  ${_('Image from flickr: http://www.flickr.com/photos/orinrobertjohn/13069655/sizes/o/in/photostream/')}
</div>
