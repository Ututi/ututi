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
