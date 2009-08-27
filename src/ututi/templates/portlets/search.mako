<%inherit file="/portlets/base.mako"/>



<%def name="search_portlet()">

  <%self:portlet id="search_portlet">
    <%def name="header()">
      ${_('Search')}
    </%def>
    There are searches here!
  </%self:portlet>
</%def>
