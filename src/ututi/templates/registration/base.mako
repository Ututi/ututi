<%inherit file="/base.mako" />

<%def name="body_class()">registration</%def>
<%def name="pagetitle()">${_("Registration")}</%def>

<%def name="css()">
  ${parent.css()}
  h1.registration {
    border-bottom: 1px solid #ff9900;
  }
  button.next {
    margin-top: 20px;
  }
</%def>

<h1 class="page-title registration">${self.pagetitle()}</h1>

${next.body()}
