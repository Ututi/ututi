<%inherit file="/ubase-width.mako" />

<%def name="head_tags()">
${parent.head_tags()}
</%def>


<h1>${_('Error!')}</h1>

<img src="${url('/images/details/icon_nope.png')}" />

<div>
  ${_("Oops, an error happened, please don't leave us, go back and try doing something else or look for information.")}<br />
  ${_("Our trained monkeys are fixing this error now. If You wish, You can kick monkeys or shout on them")}
  <form id="error_message_form" class="fullForm" method="post" action="${url(controller='error', action='send_error')}" >
    <div>
      ${h.input_area("error_message", _("Shout message"))}
      <div>
        ${h.input_submit(_("Kick monkeys"), name="submit", value="kick")}
        ${h.input_submit(_("Shout on monkeys"), name="submit", value="shout")}
      </div>
    </div>
  </form>
</div>





% if request.referrer.startswith(url("/", qualified=True)):
    <a href="#" onclick="javascript: history.go(-1); return false;">${_('go back')}</a>
% else:
    <a href="${url(controller='search', action='index')}">${_('go find something')}</a>
% endif
