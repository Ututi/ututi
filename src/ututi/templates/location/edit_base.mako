<%inherit file="/base.mako" />
<%namespace file="/portlets/universal.mako" import="navigation_portlet" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
</%def>

<%def name="portlets()">
  ${navigation_portlet(c.menu_items, c.current_menu_item,
    _("Network settings:"))}
</%def>

<%def name="title()">
  ${c.location.title}
</%def>

<%def name="pagetitle()">
  ${_("University settings")}
</%def>

<h1 class="page-title underline" >
  ${self.pagetitle()}
</h1>

${next.body()}
