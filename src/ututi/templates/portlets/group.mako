<%inherit file="/portlets/base.mako"/>
<%namespace file="/widgets/sms.mako" import="sms_widget"/>

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
                  <div>
                    ${_('Send an SMS message to number <span style="font-size: 14px">%(phone)s</span> with the following content:') % dict(phone=c.pylons_config.get('fortumo.phone_number', '1337')) |n}
                  </div>
                  <div class="sms-content">TXT ${c.pylons_config.get('fortumo.group_space.code')} ${c.group.group_id}</div>
                  <div>
                    ${_('The SMS costs <strong>7 Lt</strong> and will increase your file limit to <strong>5&nbsp;GB</strong> for another month.')|n}
                  </div>
                  %if c.group.private_files_lock_date:
                    <div>${_('Your private file area is limited to 5&nbsp;GB until <strong>%s</strong>.') % c.group.private_files_lock_date.date().isoformat() |n}</div>
                  %endif
              </div>

              <div class="right-column">
                <div class="title">
                  ${_('E-banking')}
                </div>
                <div class="description">
                  ${_('If you pay by bank, a discount applies.')|n}
                </div>

                <table>

                  %for period, amount, form in c.group.filearea_payments():
                    <tr>
                      <td>
                      <form action="${form.action}" method="POST">
                        %for key, val in form.fields:
                          <input type="hidden" name="${key}" value="${val}" />
                        %endfor
                        ${h.input_submit(_('%d Lt') % (int(amount) / 100), class_='btnMedium')}
                      </form>
                      </td>
                      <td>
                        <span class="larger">
                          - ${period}
                        </span>
                      </td>
                    </tr>

                  %endfor

                </table>

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
      <span class="right_arrow">
        <a href="${url(controller='group', action='edit', id=group.group_id)}" title="${_('Edit group settings')}">${_('Edit')}</a>
      </span>
    </div>
    %endif
    <br class="clear-right" />
  </%self:uportlet>
</%def>

<%def name="group_forum_post_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>
  <%self:action_portlet id="forum_post_portlet">
    <%def name="header()">
    <a class="blark" ${h.trackEvent(None, 'click', 'group_forum_post', 'action_portlets')} href="${url(controller='mailinglist', action='new_thread', id=group.group_id)}">${_('email your group')}</a>
    ${h.image('/images/details/icon_question.png',
            alt=_("Write an email to the group's forum - accessible by all your classmates."),
             class_='tooltip', style='margin-top: 4px;')|n}

    </%def>
  </%self:action_portlet>
</%def>

<%def name="group_invite_member_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>
  <%self:action_portlet id="invite_member_portlet">
    <%def name="header()">
    <a class="blark" ${h.trackEvent(None, 'click', 'group_invite_members', 'action_portlets')} href="${group.url(action='members')}">${_('invite classmates')}</a>
    ${h.image('/images/details/icon_question.png',
            alt=_("Invite your classmates to use Ututi with you."),
             class_='tooltip', style='margin-top: 4px;')|n}

    </%def>
  </%self:action_portlet>
</%def>

<%def name="group_members_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>
  <%self:uportlet id="group_info_portlet" portlet_class="MyProfile first">

    <%def name="header()">
      <a ${h.trackEvent(c.group, 'home', 'portlet_header')} href="${group.url(action='members')}" title="${_('''Group's members''')}">${_("Group's members")}</a>
    </%def>
    <div class="members_list">
      %for member in group.members[:8]:
        <div class="user-logo-link">
          <div class="user-logo">
            <a href="${url(controller="user", action="index", id=member.user.id)}" title="${member.user.fullname}">
              %if member.user.logo is not None:
                <img src="${url(controller='user', action='logo', id=member.user.id, width=45, height=45)}" alt="logo" />
              %else:
                ${h.image('/img/avatar-light-small.png', alt='logo')}
              %endif
            </a>
          </div>
          <div>
            <a class="verysmall blark" href="${url(controller="user", action="index", id=member.user.id)}" title="${member.user.fullname}">
              ${h.ellipsis(member.user.fullname, 10)}
            </a>
          </div>
        </div>
      %endfor
        <br class="clear-left" />
    </div>
    %if not group.is_member(c.user):
      ${h.button_to(_('become a member'), url(controller='group', action='request_join', id=group.group_id))}
    %endif
  </%self:uportlet>
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
