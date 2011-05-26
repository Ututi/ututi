<%inherit file="/base.mako" />
<%namespace file="/profile/base.mako" name="profile" />
<%namespace file="/portlets/sections.mako" import="*"/>
<%namespace file="/sections/content_snippets.mako" import="item_location_full" />
<%namespace file="/elements.mako" import="tabs" />


<%def name="title()">
  ${c.group.title}
</%def>

<%def name="portlets()">
  ${profile.portlets()}
</%def>

<%def name="portlets_secondary()">
${group_right_sidebar()}
</%def>

<%def name="css()">
   ${parent.css()}

   #group-information {
      margin: 15px 0;
      min-height: 80px;
   }

   #group-information .group-logo {
      float: left;
      margin-right: 20px;
   }

   #group-information .group-title {
      font-size: 13px;
      font-weight: bold;
   }
</%def>

<%def name="group_info_block()">
  <div id="group-information">
    <div class="group-logo">
      <img id="group-logo" src="${url(controller='group', action='logo', id=c.group.group_id, width=70, height=70)}" alt="logo" />
    </div>

    <div class="group-title" class="break-word">
      <a href="${url(controller='group', action='home', id=c.group.group_id)}">${self.title()}</a>
    </div>

    %if c.user is not None:
    <div class="break-word">
      %if c.group.is_member(c.user):
      <a href="${url(controller='mailinglist', action='new_thread', id=c.group.group_id)}" title="${_('Mailing list address')}">${c.group.group_id}@${c.mailing_list_host}</a>
      %elif c.group.mailinglist_moderated:
      <a href="${url(controller='mailinglist', action='new_anonymous_post', id=c.group.group_id)}" title="${_('Mailing list address')}">${c.group.group_id}@${c.mailing_list_host}</a>
      %endif
    </div>
    %endif

    %if c.group.location:
    <div class="location">
      ${item_location_full(c.group)}
    </div>
    %endif

    <div class="break-word">
      %if c.group.description:
      ${c.group.description}
      %endif
      %if c.group.is_admin(c.user) or c.security_context and h.check_crowds(['admin', 'moderator']):
        <a href="${c.group.url(action='edit')}" title="${_('Edit group settings')}">
          <img src="/img/icons.com/edit.png" alt="${_('Edit')}" />
        </a>
      %endif
    </div>
  </div>
</%def>

<%def name="group_menu()">
  <%
  show_tabs = (c.group.is_member(c.user) or \
               c.security_context and h.check_crowds(['admin', 'moderator'])) and \
               getattr(c, 'group_menu_current_item', None) is not None
  show_info = getattr(c, 'show_info', False)
  %>

  <h1 class="page-title ${'underline' if not show_tabs or show_info else ''}">
    ${self.title()}
  </h1>

  %if not c.group.is_member(c.user):
  <div class="clearfix">
    <div style="float: right;">
      ${h.button_to(_('become a member'), url(controller='group', action='request_join', id=c.group.group_id))}
    </div>
  </div>
  %endif

  %if show_info:
    ${group_info_block()}
  %endif

  %if show_tabs:
    %if c.user:
      <div class="above-tabs">
        <a class="settings-link" href="${c.group.url(action='edit')}">${_("Edit Settings")}</a>
      </div>
    %endif
    ${tabs(c.group_menu_items, c.group_menu_current_item)}
  %endif
</%def>

<%def name="various_dialogs()">
  %if request.GET.get('paid_sms'):
    <div id="got-sms-dialog" style="display: none">
        <div style="font-size: 14px; color: #666; font-weight: bold"
            >${_("Congratulations! You have purchased %s personal SMS credits.") % request.GET.get('paid_sms')}</div>

        <div>
          ${_("You can use these credits to send %s messages. For example, if your group has 20 members with registered phone numbers, one message will cost 20 SMS credits.") % request.GET.get('paid_sms')}
        </div>

        <div style="padding-left: 120px">
          ${h.image('/images/happy_cat.png', alt=_('Happy cat'))}
        </div>
    </div>

    <script>
      $(document).ready(function() {
          var dlg = $('#got-sms-dialog').dialog({
              title: '${_('Thanks!')}',
              width: 500
          });
          dlg.dialog("open");
          return false;
      });
    </script>
  %endif

  %if request.GET.get('paid_space'):
    <div id="got-space-dialog" style="display: none">
        <div style="font-size: 14px; color: #666; font-weight: bold"
            >${_("Congratulations! You have increased the group's private file limit.")}</div>

        <div style="padding-top: 1em; padding-bottom: 1em">
          ${_("You can now store up to %(size)s in your group's private area. Time period extension: %(time)s.") % \
              dict(time=request.GET.get('paid_space'), size=h.file_size(int(c.pylons_config.get('paid_group_file_limit')))) |n}
          ${_('Have fun using Ututi groups!')}
        </div>

        <div style="padding-left: 120px">
          ${h.image('/images/happy_cat.png', alt=_('Happy cat'))}
        </div>
    </div>

    <script>
      $(document).ready(function() {
          var dlg = $('#got-space-dialog').dialog({
              title: '${_('Thanks!')}',
              width: 500
          });
          dlg.dialog("open");
          return false;
      });
    </script>
  %endif

  %if request.GET.get('cancelled_space_payment'):
      <div id="cancelled-space-dialog" style="display: none">
        <div style="font-size: 14px; color: #666; font-weight: bold"
          >${_("You have decided not to increase your group's private file limit.")}</div>

        <div style="padding-top: 1em; padding-bottom: 1em">
          ${_('Perhaps you will change your mind later?')}
          ${_('Have fun using Ututi groups!')}
        </div>

        <div style="padding-left: 120px">
          ${h.image('/images/sad_cat.jpg', alt=_('Sad cat'))}
        </div>
    </div>

    <script>
      $(document).ready(function() {
          var dlg = $('#cancelled-space-dialog').dialog({
              title: '${_('Thanks!')}',
              width: 500
          });
          dlg.dialog("open");
          return false;
      });
    </script>
  %endif

  %if request.GET.get('cancelled_sms_payment'):
      <div id="cancelled-sms-dialog" style="display: none">
        <div style="font-size: 14px; color: #666; font-weight: bold"
          >${_("You have decided not to buy extra SMS credits.")}</div>

        <div style="padding-top: 1em; padding-bottom: 1em">
          ${_('Perhaps you will change your mind later?')}
          ${_('Have fun using Ututi groups!')}
        </div>

        <div style="padding-left: 120px">
          ${h.image('/images/sad_cat.jpg', alt=_('Sad cat'))}
        </div>
    </div>

    <script>
      $(document).ready(function() {
          var dlg = $('#cancelled-sms-dialog').dialog({
              title: '${_('Thanks!')}',
              width: 500
          });
          dlg.dialog("open");
          return false;
      });
    </script>
  %endif
</%def>

${self.group_menu()}
${self.various_dialogs()}

${next.body()}
