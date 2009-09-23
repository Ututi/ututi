<%inherit file="/portlets/base.mako"/>

<%def name="user_subjects_portlet(user=None)">
  <%
     if user is None:
         user = c.user
  %>
  <%self:portlet id="subject_portlet" portlet_class="inactive">
    <%def name="header()">
      ${_('Watched subjects')}
    </%def>
    %if not user.watched_subjects:
      ${_('You are not watching any subjects.')}
    %else:
    <ul id="user-subjects" class="subjects-list">
      % for subject in user.watched_subjects[:5]:
      <li>
        <a href="${subject.url()}" title="${subject.title}">${h.ellipsis(subject.title, 35)}</a>
      </li>
      % endfor
    </ul>
    %endif

    ${h.link_to(_('More subjects'), url(controller='profile', action='search', obj_type='subject'), class_="more")}
    <span>
      ${h.button_to(_('Watch subjects'), url(controller='profile', action='subjects', id=user.id))}
      <div class="tooltip">
        <span class="content">${_("Add watched subjects to your watched subjects' list and receive notifications about changes in these subjects")}</span>
      </div>
    </span>

  </%self:portlet>
</%def>

<%def name="user_groups_portlet(user=None, title=None, full=True)">
  <%
     if user is None:
         user = c.user

     if title is None:
       title = _('My groups')
  %>
  <%self:portlet id="group_portlet" portlet_class="inactive">
    <%def name="header()">
      ${title}
    </%def>
    % if not user.memberships:
      ${_('You are not a member of any.')}
    %else:
    <ul>
      % for membership in user.memberships:
      <li>
        <div class="group-listing-item">
          %if membership.group.logo is not None:
            <img id="group-logo" src="${url(controller='group', action='logo', id=membership.group.group_id, width=25, height=25)}" alt="logo" />
          %else:
            ${h.image('/images/details/icon_group_25x25.png', alt='logo', id='group-logo')|n}
          %endif
            <a href="${membership.group.url()}">${membership.group.title}</a>
            (${ungettext("%(count)s member", "%(count)s members", len(membership.group.members)) % dict(count = len(membership.group.members))})
            <br class="clear-left"/>
        </div>
      </li>
      % endfor
    </ul>
    %endif
    %if full:
      ${h.button_to(_('Create group'), url(controller='group', action='add'))}
      ${h.link_to(_('More groups'), url(controller='profile', action='search', obj_type='group'), class_="more")}
    %endif
  </%self:portlet>
</%def>

<%def name="user_information_portlet(user=None, full=True, title=None)">
  <%
     if user is None:
         user = c.user

     if title is None:
         title = _('My information')
  %>
  <%self:portlet id="user_information_portlet" portlet_class="inactive">
    <%def name="header()">
      ${title}
    </%def>

    <div>
      <div class="user-logo">

        %if user.logo is not None:
          <img src="${url(controller='user', action='logo', id=user.id, width=45, height=60)}" alt="logo" />
        %else:
          ${h.image('/images/user_logo_45x60.png', alt='logo')|n}
        %endif
      </div>
      <div class="user-information">
        <h3>${user.fullname}</h3>
        %if full:
          <div class="email">
            <a href="mailto:${user.emails[0].email}">${user.emails[0].email}</a>
          </div>
        %endif
        %if user.site_url:
          <div class="user-link">
            <a href="${user.site_url}">${user.site_url}</a>
          </div>
        %endif
      </div>
    </div>
    %if user.description:
      <div class="user-description">
        ${user.description}
      </div>
    %else:
      <br style="clear: left;"/>
    %endif
    %if full:
      <a href="${url(controller='profile', action='edit')}" class="more">${_('Edit profile')}</a>
    %endif
  </%self:portlet>
</%def>

<%def name="user_message_portlet(user=None)">
  <%self:portlet id="subject_portlet" portlet_class="inactive">
    <%def name="header()">
      ${'Naujas Ututi!'}
    </%def>
Kol Tu mėgavaisi vasaros atostogomis, <a
href="http://ututi.lt">ututi.lt</a> komanda parengė atnaujintą,
patobulintą ir Tavo poreikiams geriau pritaikytą portalo <a
href="http://ututi.lt">ututi.lt</a> versiją. Laukiame Jūsų <a
href="http://ututi.uservoice.com">atsiliepimų</a>, <a
href="http://ututi.uservoice.com">pasiūlymų</a> ir <a
href="http://ututi.uservoice.com">pageidavimų</a>!
  </%self:portlet>
</%def>
