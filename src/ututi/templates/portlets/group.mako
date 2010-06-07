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

  <%self:uportlet id="group_info_portlet" portlet_class="MyProfile">

    <%def name="header()">
      <a ${h.trackEvent(c.group, 'home', 'portlet_header')} href="${group.url()}" title="${group.title}">${_('Group information')}</a>
    </%def>

    <div class="profile">
      <div class="floatleft avatar">
        <img id="group-logo" src="${url(controller='group', action='logo', id=group.group_id, width=70, height=70)}" alt="logo" />
      </div>
      <div class="floatleft personal-data">
        <div><h2 class="grupes-portlete">${group.title}</h2></div>
        <div>
          <a href="${group.location.url()}">${' | '.join(group.location.title_path)}</a>
          <span class="right_arrow"></span>
        </div>
        <div>
          ## TODO: fix forums, fix mailing list public status
          %if group.is_member(c.user):
            <a href="${url(controller='mailinglist', action='new_thread', id=c.group.group_id)}" title="${_('Mailing list address')}">${group.group_id}@${c.mailing_list_host}</a>
          %elif c.user is not None:
            <a href="${url(controller='mailinglist', action='new_anonymous_post', id=c.group.group_id)}" title="${_('Mailing list address')}">${group.group_id}@${c.mailing_list_host}</a>
          %endif
        </div>
        <div>${ungettext("%(count)s member", "%(count)s members", len(group.members)) % dict(count=len(group.members))}</div>
      </div>
      <div class="clear"></div>

      <p class="grupes-aprasymas">
        ${group.description}
      </p>

      %if group.is_member(c.user):
        <div class="click2show">
          <div class="remeju-sarasas click">
            <a href="#">${_("More settings")}</a>
          </div>
          <div class="show" id="group_settings_block">
            <div style="float: left">
            %if group.is_subscribed(c.user):
              ${h.button_to(_("Do not get email"), group.url(action='unsubscribe'), class_='btn inactive')}
            %else:
              ${h.button_to(_("Get email"), group.url(action='subscribe'), class_='btn')}
            %endif
            </div>
            <div style="float: left">
            ${h.button_to(_("Leave group"), group.url(action='leave'), class_='btn warning')}
            </div>
          </div>
        </div>
      %endif

      %if group.is_admin(c.user):
      <div>
        <a href="${url(controller='group', action='edit', id=group.group_id)}" title="${_('Edit group settings')}">${_('Edit')}</a>
        <span class="right_arrow"></span>
      </div>
      %endif

    </div>

    ## TODO: not implemented
    ##<div class="profile">Grupės privatiems failams liko:
    ##  <img src="/img/icons/indicator.png" alt="" class="indicator">
    ##  <span class="verysmall">150Mb</span>

    ##  <form action="">
    ##    <fieldset>
    ##      <legend class="a11y">pridėti</legend>
    ##      <label><span><button value="submit" class="btn"><span>gauti daugiau vietos</span></button></span></label>
    ##    </fieldset>
    ##  </form>
    ##</div>

  </%self:uportlet>
</%def>

<%def name="group_watched_subjects_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>
  <%self:portlet id="subject_portlet" portlet_class="inactive">
    <%def name="header()">
      <a ${h.trackEvent(c.group, 'subjects', 'portlet_header')} href="${group.url(action='subjects')}" title="${_('All watched subjects')}">${_('Watched subjects')}</a>
    </%def>
    %if not group.watched_subjects:
      ${_('Your group is not watching any subjects!')}
    %else:
    <ul id="group-subjects" class="subjects-list">
      % for subject in group.watched_subjects[:5]:
      <li>
        <a href="${subject.url()}" title="${subject.title}">${h.ellipsis(subject.title, 35)}</a>
      </li>
      % endfor
    </ul>
    %endif
    <div class="footer">
      <span>
        ${h.button_to(_('choose subjects'), group.url(action='subjects'))}
        ${h.image('/images/details/icon_question.png', alt=_('Watching subjects means your group will be informed of all the changes that happen in these subjects: new files, new pages etc.'), class_='tooltip')|n}
      </span>
    </div>
  </%self:portlet>
</%def>

<%def name="group_forum_post_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>
  <%self:action_portlet id="forum_post_portlet">
    <%def name="header()">
    <a ${h.trackEvent(None, 'click', 'group_forum_post', 'action_portlets')} href="${url(controller='mailinglist', action='new_thread', id=group.group_id)}">${_('email your group')}</a>
    ${h.image('/images/details/icon_question.png',
            alt=_("Write an email to the group's forum - accessible by all your groupmates."),
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
    <a ${h.trackEvent(None, 'click', 'group_invite_members', 'action_portlets')} href="${group.url(action='members')}">${_('invite groupmates')}</a>
    ${h.image('/images/details/icon_question.png',
            alt=_("Invite your groupmates to use Ututi with you."),
             class_='tooltip', style='margin-top: 4px;')|n}

    </%def>
  </%self:action_portlet>
</%def>
