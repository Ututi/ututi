<%inherit file="/mailinglist/base.mako" />

  <%self:rounded_block class_="portletGroupFiles portletGroupMailingList">
    <div class="single-title">
      <div class="floatleft bigbutton2">
        <h2 class="portletTitle bold category-title">${_('Group mail')}</h2>
      </div>
      % if h.check_crowds(['member', 'admin']):
      <div style="float: right">
        ${h.button_to(_("New topic"), url(controller='mailinglist', action='new_thread', id=c.group.group_id), method='get')}
      </div>
      % endif
      % if h.check_crowds(['admin']):
      <div style="float: right">
        ${h.button_to(_("Administration"), c.group.url(controller='mailinglist', action='administration'), method='get')}
      </div>
      % endif
      <div class="clear"></div>
    </div>

    %if not c.messages:
      <div class="single-messages" id="single-messages">
        <div class="no-messages">${_('No messages yet.')}</div>
      </div>
    %else:
      <div class="single-messages" id="single-messages">
        ${self.listThreads()}
      </div>
    %endif
 </%self:rounded_block>
