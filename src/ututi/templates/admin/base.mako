<%inherit file="/ubase.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<%def name="back_link()">
<a href="${url(controller='admin', action='index')}" class="back-link">
  Back to dashboard
</a>
</%def>

${self.back_link()}

${next.body()}
