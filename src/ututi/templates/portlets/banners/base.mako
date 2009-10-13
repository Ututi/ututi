<%inherit file="/portlets/base.mako"/>
<%def name="ututi_banners_portlet()">
<%self:portlet id="banners_portlet" portlet_class="border-less">
<%def name="header()">
</%def>
<div class="structured_info">
  <iframe src="${url('/bunners', qualified=True)}" frameborder="0" style="height: 160px; border: none; overflow: visible;">
  </iframe>
</div>
</%self:portlet>
</%def>

<%def name="mif_banner_portlet(location=None)">
  <%
     if location is None:
       location = c.location
     location = '/'.join(location.path)
  %>
  %if location == 'vu/mif' and c.lang == 'lt':
  <%self:portlet id="mif_banner_portlet" portlet_class="border-less">
  <%def name="header()">
  </%def>
  <div class="structured_info" style="text-align: center;">
    <a target="_main"
       href="http://blog.ututi.lt/2009/10/11/mif-nulines-2009-tarantino-klube"
       title="MIF nulinės">
      <img src="${url('/images/bunners/mif.gif')}" alt="MIF nulinės" />
    </a>
  </div>
  </%self:portlet>
  %endif
</%def>
