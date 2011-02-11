<%inherit file="/base.mako" />

<%def name="body_class()">registration</%def>
<%def name="pagetitle()">${_("Registration")}</%def>

<h1 class="page-title">${self.pagetitle()}</h1>

${next.body()}
