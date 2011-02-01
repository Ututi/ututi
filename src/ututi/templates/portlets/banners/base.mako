<%inherit file="/portlets/base.mako"/>

<%def name="ututi_banners_portlet()">
<%
   content = h.render('portlets/banners.mako')
%>
%if content != '':
  <%self:portlet id="banners_portlet" portlet_class="border-less">
  <%def name="header()">
  </%def>
  <h2 class="bunner-heading">${_('Friends of ututi')}</h2>
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
      <img src="${url('/images/bunners/facebook.jpeg')}" alt="facebook" />
    </a>
    <a class="blog-link" href="${_('blog_link')}" title="${_('Read our blog')}">
      <img src="${url('/images/bunners/ublog.jpeg')}" alt="U-blog" />
    </a>

</div>
</%self:portlet>
</%def>

<%def name="ubooks_portlet()">
%if c.tpl_lang == 'lt':
<%self:uportlet id="ubooks-portlet">
<%def name="header()">
  ${_("Ututi recommends")}
</%def>
  <p id="virtual-book-market">
    ${_("Virtual book market")}
    <br />
    <a href="http://books.ututi.lt">books.ututi.lt</a>
  </p>
  <p id="here-you-can-buy">
    ${_("Here you can buy study material cheaply or find a new owner for your good old textbook.")}
  </p>
  <p class="right_arrow" id="ubooks-link">
    <a href="http://books.ututi.lt">books.ututi.lt</a>
  </p>
</%self:uportlet>
%endif
</%def>
