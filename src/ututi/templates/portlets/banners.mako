<%inherit file="/portlets/base.mako"/>

<%def name="ututi_banners_portlet()">
  <%self:portlet id="banners_portlet" portlet_class="border-less">
    <%def name="header()">
    </%def>
    <div class="structured_info">
      <a href="http://blog.ututi.lt" title="U-blog">
        <img src="/images/banners/ublog.jpeg" alt="U-blog" />
      </a>
      <a href="http://facebook.com/ututi" title="Facebook">
        <img src="/images/banners/facebook.jpeg" alt="facebook" />
      </a>
      <br/>
      <a href="http://aukok.lt" title="aukok.lt">
        <img src="/images/banners/aukoklogo.png" alt="aukok.lt" />
      </a>
      <a href="http://www.15min.lt/naujienos/ziniosgyvai/studentu-blogas" title="15 min">
        <img src="/images/banners/15minlogo.jpeg" alt="15 min" />
      </a>
    </div>
  </%self:portlet>
</%def>
