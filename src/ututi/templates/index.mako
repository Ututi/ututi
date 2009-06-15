<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>Welcome ${c.user.fullname}!</h1>

<a href="/logout">Log out</a>
