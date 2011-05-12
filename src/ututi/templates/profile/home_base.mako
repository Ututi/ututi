<%inherit file="/ubase-two-sidebars.mako" />
<%namespace file="/profile/base.mako" name="profile" />
<%namespace file="/portlets/user.mako" import="invite_friends_portlet,
                                               todo_portlet"/>
<%namespace file="/portlets/universal.mako" import="users_online_portlet,
                                                    about_portlet"/>

<%def name="portlets()">
  ${profile.portlets()}
</%def>

<%def name="portlets_right()">
  ${about_portlet()}
  ${todo_portlet()}
  ${invite_friends_portlet()}
  ${users_online_portlet()}
</%def>

%if hasattr(self, 'pagetitle'):
  <h1 class="page-title underline">${self.pagetitle()}</h1>
%endif

${next.body()}
