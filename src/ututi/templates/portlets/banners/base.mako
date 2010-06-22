<%inherit file="/portlets/base.mako"/>

<%def name="ututi_banners_portlet()">
<%
   content = h.render_lang('portlets/banners.mako')
%>
%if content != '':
  <%self:portlet id="banners_portlet" portlet_class="border-less">
  <%def name="header()">
  </%def>
  <h2 class="banner-heading">${_('Friends of ututi')}</h2>
  <div class="structured_info">
    ${content}
  </div>
  </%self:portlet>
%endif
</%def>

<%def name="ututi_links_portlet()">
<%self:portlet id="links_portlet" portlet_class="border-less">
<%def name="header()">
</%def>
<div class="structured_info">
    <a class="facebook-link" href="${_('facebook_link')}" title="${_('Find us on Facebook')}">
      <img src="${url('/images/banners/facebook.jpeg')}" alt="facebook" />
    </a>
    <a class="blog-link" href="${_('blog_link')}" title="${_('Read our blog')}">
      <img src="${url('/images/banners/ublog.jpeg')}" alt="U-blog" />
    </a>

</div>
</%self:portlet>
</%def>

<%def name="ututi_prizes_portlet()">
<%doc>
 %if c.tpl_lang in ['lt']:

 <%
    path = []
    location = None

    if getattr(c, 'object_location', None):
        location = c.object_location
    elif getattr(c, 'location', None):
        location = c.location
    elif getattr(c, 'user', None):
        location = c.user.location

    if location is not None:
        path = location.path

    location_path = path
 %>

 %if 'ktu' in location_path:
 <%self:portlet id="barcamp_portlet" portlet_class="border-less">
 <%def name="header()">
 </%def>
 <div class="structured_info">
   <div class="banner">
     <a href="http://barcamp.lt/2010/02/barcamp-atkeliauja-i-kauna/">
       <img src="${url('/images/banners/barcamp.png')}" alt="" />
     </a>
   </div>
 </div>
 </%self:portlet>
 %endif
 %endif
</%doc>
%if c.tpl_lang in ['lt', 'pl']:
<%self:portlet id="dalintis_portlet" portlet_class="border-less">
<%def name="header()">
</%def>
<div class="structured_info">
  <div class="banner">
    %if c.tpl_lang == 'lt':
    <a href="http://blog.ututi.lt/2009/12/7/ne-kaledines-u-dovanos">
      <img src="${url('/images/banners/UTUTI_dovanos.png')}" alt="" />
    </a>
    %elif c.tpl_lang == 'pl':
    <a href="http://blog.ututi.pl/2010/1/20/najaktywniejsi-w-styczniu">
      <img src="${url('/images/banners/UTUTI_prezenty.png')}" alt="" />
    </a>
    %endif
  </div>
</div>
</%self:portlet>
%endif
</%def>
