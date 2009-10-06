<%inherit file="/portlets/base.mako"/>
<%def name="ututi_banners_portlet()">
<%self:portlet id="banners_portlet" portlet_class="border-less">
<%def name="header()">
</%def>
<div class="structured_info">
  <iframe src="${url('/bunners', qualified=True)}" style="height: 160px; border: 0; overflow: hidden;">
  </iframe>
</div>
</%self:portlet>
</%def>
