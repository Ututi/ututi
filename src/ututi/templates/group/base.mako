<%inherit file="/ubase-sidebar.mako" />

<%namespace file="/portlets/sections.mako" import="*"/>

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="portlets()">
  ${group_sidebar()}
</%def>

<%def name="group_menu(show_title=True)">
%if show_title:
  <h1 class="pageTitle" style="margin-top: 0">
    ${self.title()}
    %if not c.group.is_member(c.user):
      <div style="float: right;">
        ${h.button_to(_('become a member'), url(controller='group', action='request_join', id=c.group.group_id))}
      </div>
    %endif
  </h1>
%endif

%if c.group.is_member(c.user):
<ul class="moduleMenu" id="moduleMenu">
    %for menu_item in c.group_menu_items:
      <li class="${'current' if menu_item['name'] == c.group_menu_current_item else ''}">
        <a href="${menu_item['link']}">${menu_item['title']}
            <span class="edge"></span>
        </a></li>
    %endfor
</ul>
%endif
</%def>

${self.group_menu()}

${next.body()}
