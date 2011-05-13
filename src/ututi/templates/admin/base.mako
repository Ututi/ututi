<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<%def name="back_link()">
<a href="${url(controller='admin', action='index')}" class="back-link">
  Back to dashboard
</a>
</%def>

<%def name="css()">
  ${parent.css()}
  h2 {
    margin: 10px 0;
  }
</%def>

${self.back_link()}

${next.body()}
