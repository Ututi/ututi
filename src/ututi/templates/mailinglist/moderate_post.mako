<%inherit file="/mailinglist/base.mako" />

<div class="back-link">
  <a class="back-link" href="${c.group.url(controller='mailinglist', action='administration')}">${_('Back to the moderation queue')}</a>
</div>

<%self:rounded_block class_="portletGroupFiles portletMailingListThread smallTopMargin">
<div class="single-title">
  <div class="floatleft bigbutton2">
    <h2 class="portletTitle bold category-title">${c.thread.subject}</h2>
  </div>
  <div style="float: right">
    ${h.button_to(_("Reject"), c.thread.url(action='reject_post'))}
  </div>
  <div style="float: right">
    ${h.button_to(_("Accept"), c.thread.url(action='accept_post'))}
  </div>
  <div class="clear"></div>
</div>

<table id="forum-thread">
%for message in c.messages:
  ${self.render_message(message, post_class='moderated-post', show_actions=False)}
%endfor
</table>
</%self:rounded_block>
