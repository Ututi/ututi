<%inherit file="/portlets/base.mako"/>

<%def name="ututi_banners_portlet()">
<%self:portlet id="banners_portlet" portlet_class="border-less">
<%def name="header()">
</%def>
<div class="structured_info">
  <iframe src="${url('/bunners', qualified=True)}" frameborder="0" style="height: 200px; border: none; overflow: visible;">
  </iframe>
</div>
</%self:portlet>
</%def>

<%def name="ututi_links_portlet()">
<%self:portlet id="links_portlet" portlet_class="border-less">
<%def name="header()">
</%def>
<div class="structured_info">
    <a class="facebook-link" href="http://facebook.com/ututi" title="${_('Find us on Facebook')}">
      <img src="${url('/images/bunners/facebook.jpeg')}" alt="facebook" />
    </a>
    <a class="blog-link" href="http://blog.ututi.lt" title="${_('Read our blog')}">
      <img src="${url('/images/bunners/ublog.jpeg')}" alt="U-blog" />
    </a>

</div>
</%self:portlet>
</%def>
