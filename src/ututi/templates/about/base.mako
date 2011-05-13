<%inherit file="/base.mako" />
<%namespace file="/portlets/universal.mako" import="navigation_portlet" />

<%def name="portlets()">
  ${navigation_portlet(c.menu_items, c.current_menu_item, _('Overview:'))}
</%def>

<%def name="pagetitle()">${_('About Ututi')}</%def>

<h1 class="page-title underline">${self.pagetitle()}</h1>

${next.body()}

