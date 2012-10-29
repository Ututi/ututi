<%inherit file="/portlets/base.mako"/>
<%namespace file="/widgets/sms.mako" import="sms_widget"/>
<%namespace file="/elements.mako" import="item_box, tooltip" />

<%def name="portlet_file(file)">
  <li>
    <a href="${file.url()}" title="${file.title}">${h.ellipsis(file.title, 30)}</a>
    <input class="delete_url" type="hidden" value="${file.url(action='delete')}" />
  </li>
</%def>

<%def name="group_info_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>

  <%self:uportlet id="group_info_portlet" portlet_class="MyProfile first">

    <%def name="header()">
      <a ${h.trackEvent(c.group, 'home', 'portlet_header')} href="${group.url()}" title="${group.title}">${_('Group information')}</a>
    </%def>

    <div class="profile">
      <div class="floatleft avatar">
        <img id="group-logo" src="${url(controller='group', action='logo', id=group.group_id, width=70, height=70)}" alt="logo" />
      </div>
      <div class="floatleft personal-data">
        <div><h2 class="grupes-portlete">${group.title}</h2></div>
        %if c.group.forum_is_public:
          <div style="width: 190px">
            <a href="${group.url()}">${group.url(qualified=True)}</a>
          </div>
        %else:
          <div>
            %if group.location:
            <a href="${group.location.url()}">${' | '.join(group.location.title_path)}</a>
            <span class="right_arrow"></span>
            %endif
          </div>
          %if c.user is not None:
            <div>
              %if group.is_member(c.user):
                <a href="${url(controller='mailinglist', action='new_thread', id=c.group.group_id)}" title="${_('Mailing list address')}">${group.group_id}@${c.mailing_list_host}</a>
              %elif group.mailinglist_moderated:
                <a href="${url(controller='mailinglist', action='new_anonymous_post', id=c.group.group_id)}" title="${_('Mailing list address')}">${group.group_id}@${c.mailing_list_host}</a>
              %endif
            </div>
          %endif
        %endif
        <div>${ungettext("%(count)s member", "%(count)s members", len(group.members)) % dict(count=len(group.members))}</div>
      </div>
      ##<div style="float: left; margin-top: 3px">
      ##  <fb:like width="90" show_faces="false" url=${group.url(qualified=True)}></fb:like>
      ##</div>
      <div class="clear"></div>
    </div>
    %if (group.is_member(c.user) or c.security_context and h.check_crowds(['admin', 'moderator'])) and group.has_file_area:
    <div class="profile topLine grey">
      <span class="bold">${_('Remaining private space:')}</span>
      <span>${h.file_size(group.free_size)}</span>
      ${h.image('/images/details/pbar%d.png' % group.free_size_points, alt=h.file_size(group.size), class_='area_size_points')|n}
      <div style="padding-top: 4px; padding-bottom: 7px" class="bottomLine">
        <form>
          ${h.input_submit(_('Get more space'), id='get-space-button')}
        </form>
      </div>

          <div id="get-space-dialog" class="payment-dialog" style="display: none">
              <div class="description">

  ${_("The amount of group's private files is limited to %(limit)s. This is so because Ututi "
  "encourages users to store their files in publicly accessible subjects where they can "
  "be shared with all the users. But if you want to keep more than %(limit)s of files, "
  "you can do this.") % dict(limit=h.file_size(c.group.group_file_limit()))}

              </div>
              <div style="clear: both"></div>

              <div class="left-column">
                  <div class="title">
                      ${_('SMS message')}
                  </div>
                  <%
                     limit_size = h.file_size(int(c.pylons_config.get('paid_group_file_limit')))
                  %>
                  <div>
                    ${_('Send an SMS message to number <span style="font-size: 14px">%(phone)s</span> with the following content:') % dict(phone=c.pylons_config.get('fortumo.group_space.number', '1337')) |n}
                  </div>
                  <div class="sms-content">TXT ${c.pylons_config.get('fortumo.group_space.code')} ${c.group.group_id}</div>
                  <div>
                    ${_('The SMS costs <strong>%(price).2f Lt</strong> and will increase your file limit to <strong>%(limit)s</strong> for another month.') %\
                      dict(price=float(c.pylons_config.get('fortumo.group_space.price', 700))/100, limit=limit_size)|n}
                  </div>
                  %if c.group.private_files_lock_date:
                    <div>${_('Your private file area is limited to %(limit)s until <strong>%(date)s</strong>.') % \
                      dict(date=c.group.private_files_lock_date.date().isoformat(), limit=limit_size) |n}</div>
                  %endif
              </div>

              <div class="right-column">
                <div class="title">
                  ${_('E-banking')}
                </div>

                <div class="description">
                  ${_('There are no possibility to pay for additional group space by bank at the moment.')}
                </div>
              </div>
          </div>

          <script>
            $('#get-space-button').click(function() {
                var dlg = $('#get-space-dialog').dialog({
                    title: '${_('Purchase group private space')}',
                    width: 600
                });
                dlg.dialog("open");
                return false;
            });
          </script>
    </div>
    %endif

    %if group.is_member(c.user) or c.security_context and h.check_crowds(['admin', 'moderator']):
    <div class="click2show">
      <div class="click more_settings">
        <span class="green verysmall">${_("More settings")}</span>
      </div>
      <div class="show" id="group_settings_block">
        %if group.is_subscribed(c.user):
        <div style="display: inline-block; padding-top: 8px">
          ${h.button_to(_("Do not get email"), group.url(action='unsubscribe'), class_='btn inactive')}
        </div>
        %else:
        <div style="display: inline-block; padding-top: 8px">
          ${h.button_to(_("Get email"), group.url(action='subscribe'), class_='btn')}
        </div>
        %endif
        <div style="display: inline-block; padding-top: 8px">
          ${h.button_to(_("Leave group"), group.url(action='leave'), class_='btn warning')}
        </div>
      </div>
    </div>
    %endif

    %if group.is_admin(c.user) or c.security_context and h.check_crowds(['admin', 'moderator']):
      <div class="floatright">
        <a class="right_arrow" href="${url(controller='group', action='edit', id=group.group_id)}" title="${_('Edit group settings')}">${_('Edit')}</a>
      </div>

    %endif
    <br class="clear-right" />
  </%self:uportlet>
</%def>


<%def name="group_invite_member_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>
  <%self:portlet id="invite-friends-portlet">
    <%def name="header()">
      ${_("Invite others to group:")}
    </%def>
    <ul class="icon-list">
      <li class="icon-facebook">
        <a href="${group.url(action='invite_fb')}" id="invite-fb-link" ${h.trackEvent(None, 'click', 'group_invite_facebook', 'portlets')}>${"Facebook"}</a>
      </li>
      <li class="icon-email">
        <a href="#invite-email" id="invite-email-link" ${h.trackEvent(None, 'click', 'group_invite_email', 'portlets')}>${"Email"}</a>
      </li>
    </ul>

    <div id="invite-email-dialog">
      <form action="${url(controller='group', action='invite_members', id=c.group.group_id)}" method="POST" class="new-style-form" id="invite-email-form">
        ${h.input_line('emails', _("Recipients:"),
                       help_text=_("Enter comma separated list of email addresses"))}
        ${h.input_area('message', _("Add personal message (optional):"))}
        ${h.input_submit(_("Send invitation"), id='invite-submit-button', class_='dark')}
      </form>
      <p id="invitation-feedback-message">${_("Your invitations were successfully sent.")}</p>
    </div>

    <div id="invite-fb-dialog">
    </div>

    <script type="text/javascript">
      //<![CDATA[
      $(document).ready(function() {
        $('#invite-email-dialog').dialog({
            title: '${_("Invite friends via email")}',
            width: 330,
            autoOpen: false,
            resizable: false
        });

        $("#invite-email-link").click(function() {
          $('#invite-email-dialog').dialog('open');
          return false;
        });

        $('#invite-submit-button').click(function(){
            $.post("${url(controller='group', action='invite_members_js', id=c.group.group_id)}",
                   $(this).closest('form').serialize(),
                   function(data, status) {
                       if (data.success != true) {
                           // remove older error messages
                           $('.error-message').remove();
                           for (var key in data.errors) {
                               var error = data.errors[key];
                               $('#' + key).parent().after($('<div class="error-message">' + error + '</div>'));
                           }
                       }
                       else {
                           // show feedback to user
                           $('#invite-email-dialog').addClass('email-sent').delay(1000).queue(function() {
                               // close and clean up
                               $(this).dialog('close');
                               $(this).removeClass('email-sent');
                               $('.error-message').remove();
                               $(this).find('#emails').val('');
                               $(this).dequeue();
                           });
                       }
                   },
                   "json");

            return false;
        });

      });
      //]]>
    </script>
  </%self:portlet>
</%def>

<%def name="group_members_portlet(group=None, count=None)">
  <%
     if group is None:
         group = c.group
     if count is None: count = 6
     members = h.group_members(group.id, count)
  %>
  %if members:
  <%self:portlet id='location-members-portlet'>
    <%def name="header()">
      ${_("Group members:")}
    </%def>
    ${item_box(members, with_titles=True)}
  </%self:portlet>
  %endif
</%def>

<%def name="group_settings_portlet(group=None)">
  <% if group is None: group = c.group %>
    <%self:portlet id="group-admin-portlet">
      <%def name="header()">
        ${_("Settings:")}
      </%def>

      %if group.is_admin(c.user) or c.security_context and h.check_crowds(['admin', 'moderator']):
      <div class="group-portlet-setting" style="background-image: url(${url('/img/icons/group_moderation_queue.png')});">
        <a href="${group.url(controller='mailinglist', action='administration')}">${_('Moderation queue')}</a>
      </div>
      %endif

      %if group.is_subscribed(c.user):
      <div class="group-portlet-setting" style="background-image: url(${url('/img/icons/group_unsubscribe.png')})">
        <a href="${group.url(action='unsubscribe')}">${_("Do not get email")}</a>
      </div>
      %else:
      <div class="group-portlet-setting" style="background-image: url(${url('/img/icons/group_subscribe.png')})">
        <a href="${group.url(action='subscribe')}">${_("Get email")}</a>
      </div>
      %endif

      <div class="group-portlet-setting" style="background-image: url(${url('/img/icons/group_leave.png')})">
        <a href="${group.url(action='leave')}">${_("Leave group")}</a>
      </div>

    </%self:portlet>
</%def>

<%def name="group_sms_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>
  <%self:uportlet id="group_sms_portlet" portlet_class="MyProfile">
    <%def name="header()">
      ${_('Send SMS message to group')}
    </%def>

    ${sms_widget(c.user, group)}
    <div class="clear-left"></div>

  </%self:uportlet>
</%def>
