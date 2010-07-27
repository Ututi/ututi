<%inherit file="/portlets/base.mako"/>

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
        %if not c.group.forum_is_public:
        <div>
          <a href="${group.location.url()}">${' | '.join(group.location.title_path)}</a>
          <span class="right_arrow"></span>
        </div>
        %else:
        <div>
          <a href="${group.url()}">${group.url(qualified=True)}</a>
        </div>
        %endif
        %if not c.group.forum_is_public:
        <div>
          %if group.is_member(c.user):
            <a href="${url(controller='mailinglist', action='new_thread', id=c.group.group_id)}" title="${_('Mailing list address')}">${group.group_id}@${c.mailing_list_host}</a>
          %elif c.user is not None:
            <a href="${url(controller='mailinglist', action='new_anonymous_post', id=c.group.group_id)}" title="${_('Mailing list address')}">${group.group_id}@${c.mailing_list_host}</a>
          %endif
        </div>
        %endif
        <div>${ungettext("%(count)s member", "%(count)s members", len(group.members)) % dict(count=len(group.members))}</div>
      </div>
      ##<div style="float: left; margin-top: 3px">
      ##  <fb:like width="90" show_faces="false" url=${group.url(qualified=True)}></fb:like>
      ##</div>
      <div class="clear"></div>
    </div>
    %if group.is_member(c.user) and group.has_file_area and not c.group.forum_is_public:
      <div class="profile topLine">
      ${_('Available space for private group files:')}
      ${h.image('/images/details/pbar%d.png' % group.free_size_points, alt=h.file_size(group.size), class_='area_size_points')|n}
      <span class="verysmall">${h.file_size(group.free_size)}</span>
      <div style="padding-top: 4px; padding-bottom: 7px" class="bottomLine">
        ${h.button_to(_('Get more space'), group.url(action='pay'))}
      </div>
    </div>
    %endif
    <p class="grupes-aprasymas">
      ${group.description}
    </p>

    %if group.is_member(c.user):
    <div class="click2show">
      <div class="remeju-sarasas click">
        <a href="#">${_("More settings")}</a>
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

    %if group.is_admin(c.user):
      <div class="floatright" style="margin-top: 6px">
      <span class="right_arrow">
        <a href="${url(controller='group', action='edit', id=group.group_id)}" title="${_('Edit group settings')}">${_('Edit')}</a>
      </span>
    </div>
    %endif
    <br class="clear-right" />
  </%self:uportlet>
</%def>

<%def name="group_watched_subjects_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>
  <%self:uportlet id="subject_portlet">
    <%def name="header()">
      <a ${h.trackEvent(c.group, 'subjects', 'portlet_header')} href="${group.url(action='subjects')}" title="${_('All watched subjects')}">${_('Watched subjects')}</a>
    </%def>
    %if not group.watched_subjects:
      ${_('Your group is not watching any subjects!')}
    %else:
    <ul id="DalykaiList" class="subjects-list">
      % for subject in group.watched_subjects[:5]:
      <li class="grupes-dalykai">
        <a href="${subject.url()}" title="${subject.title}">${h.ellipsis(subject.title, 35)}</a>
      </li>
      % endfor
    </ul>
    %endif
    <div class="secondModuleLayer">
      <a style="float: right; margin-top: 4px;" class="right_arrow" href="${group.url(action='subjects')}">${_('all subjects')}</a>
      ${h.button_to(_('choose subjects'), group.url(action='subjects'))}
    </div>
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
  <%self:uportlet id="group_sms_portlet">
    <%def name="header()">
      ${_('Send SMS message')}
    </%def>

    <div>
      ${_('Send a message to number 1337 (2 Lt): "TXT&nbsp;%(sms_code)s&nbsp;%(group_id)s&nbsp;Your message"') % dict(sms_code=c.pylons_config.get('fortumo.personal_sms_credits.code', 'U2TISMS'), group_id=c.group.group_id) |n}
    </div>

    %if c.user.sms_messages_remaining:
      ## TODO: ngettext
      ${_('(%d SMS credits remaining)') % c.user.sms_messages_remaining}
      <form method='post' action="${url(controller='group', action='send_sms', id=group.group_id)}">
          <input type="hidden" name="current_url" value="${url.current()}" />
          ${h.input_area('sms_message', _('Send an SMS to the group:'), cols=35)}
          ${h.input_submit(_('Send'))}
          <div>
              ## XXX i18n
              <span id="sms_message_symbols">140</span> characters remaining
              (cost: <span id="sms_message_credits">${len(c.group.recipients_sms(sender=c.user))}</span> SMS credits)
          </div>
      </form>
      <script>
          $(document).ready(function() {
              $('textarea#sms_message').keyup(function() {
                var el = $('#sms_message')[0];
                var s = el.value;
                var ascii = true;
                for (var i = 0; i < s.length; i++) {
                    var c = s.charCodeAt(i);
                    if (c > 127) {
                        ascii = false;
                        break;
                    }
                }
                var n_recipients = ${len(c.group.recipients_sms(sender=c.user))};
                var text_length = s.length;

                // Please keep math in sync with Python controller code.
                // -----
                var msg_length = text_length * (ascii ? 1 : 2);
                if (msg_length <= 140) {
                    msgs = 1;
                } else {
                    msgs = 1 + Math.floor((msg_length - 1) / 134);
                }
                var cost = n_recipients * msgs;
                // -----

                $('#sms_message_credits').text(cost);

                var chars_remaining;
                if (msg_length <= 140) {
                    chars_remaining = (140 - msg_length);
                } else {
                    chars_remaining = 134 - (msg_length % 134)
                }
                if (!ascii)
                    chars_remaining = chars_remaining / 2;
                $('#sms_message_symbols').text(chars_remaining);
              });
          });
      </script>
    %else:
      ${_('You need to buy credits to be able to send SMS messages to the group.')}
      % if not c.user.phone_confirmed:
        ${_('You need to confirm your phone in your <a href="%s">profile</a>.') % url(controller='profile', action='edit')|n}
      % endif
      ${_('Send an SMS to number 1337 with the content "TXT&nbsp;%(sms_code)s" (price: 10 Lt) to buy 100 credits.') % dict(sms_code=c.pylons_config.get('fortumo.personal_sms_credits.code', 'U2TISMS')) |n}
    %endif
  </%self:uportlet>
</%def>
