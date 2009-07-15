# -*- coding: utf-8 -*-
<%inherit file="/base.mako" />

<%def name="title()">
  ${c.subject.title}
</%def>

<h1>${c.subject.title}</h1>

<h2>${c.page.title}</h2>

<div>
  ${c.page.content|n}
</div>
