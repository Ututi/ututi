<%inherit file="/ubase-sidebar.mako" />

<%namespace file="/portlets/sections.mako" import="*"/>

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="portlets()">
  ${group_sidebar()}
</%def>

<%def name="group_menu()">
<h1 class="pageTitle">${self.title()}</h1>
<ul class="moduleMenu" id="moduleMenu">
    %for menu_item in c.group_menu_items:
      <li class="${'current' if menu_item['name'] == c.group_menu_current_item else ''}">
        <a href="${menu_item['link']}">${menu_item['title']}
            <span class="edge"></span>
        </a></li>
    %endfor
</ul>
</%def>

${self.group_menu()}

${next.body()}
