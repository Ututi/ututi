<%inherit file="/base.mako" />

<%namespace file="/profile/base.mako" name="profile" />
<%namespace file="/portlets/group.mako" import="*"/>
<%namespace file="/portlets/sections.mako" import="*"/>
<%namespace name="members" file="/group/members.mako" import="group_members, css"/>
<%namespace name="membersbase" file="/group/base.mako" import="css"/>
<%namespace file="/forum/index.mako" import="forum_thread_list"/>

<%namespace file="/portlets/banners/base.mako" import="*"/>
<%namespace file="/portlets/user.mako" import="*"/>

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="portlets()">
  ${profile.portlets()}
</%def>

<%def name="css()">
   ${parent.css()}
   ${membersbase.css()}
   ${members.css()}
</%def>


<h1 class="page-title">
  ${self.title()}
  %if not c.group.is_member(c.user):
  <div style="float: right;">
    ${h.button_to(_('become a member'), url(controller='group', action='request_join', id=c.group.group_id))}
  </div>
  %endif
</h1>

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

    <div class="break-word">
      %if c.group.location:
      <a href="${c.group.location.url()}">${' | '.join(c.group.location.title_path)}</a>
      %endif
    </div>


    <div class="break-word">
      %if c.group.description:
      ${c.group.description}
      %endif
    </div>

    <div class="break-word">
      %if c.group.is_admin(c.user) or c.security_context and h.check_crowds(['admin', 'moderator']):
      <a href="${url(controller='group', action='edit', id=c.group.group_id)}" title="${_('Edit group settings')}">${_('Edit')}</a>
      %endif
    </div>
  </div>

    <%doc>
    TODO: This needs to be formatted correctly!
    </%doc>
    %if c.group.page_public:
    <div id="group_page">
      ${c.group.page |n}
    </div>
    %endif

%if c.group.forum_is_public:
  %for category in c.group.forum_categories:
    ${forum_thread_list(category, n=10000)}
  %endfor
%endif

${group_members()}

<br style="clear: left;"/>

