<%inherit file="/base.mako" />

<%def name="head_tags()">
${parent.head_tags()}
</%def>


<h1>${_('Error!')}</h1>

<img src="${url('/images/nope.png')}" />

<div>
${_("Oops, an error happened, please don't leave us, go back and try doing something else or look for information.")}
</div>

% if request.referrer.startswith(url("/", qualified=True)):
    <a href="#" onclick="javascript: history.go(-1); return false;">go back</a>
% else:
    <a href="${url(controller='search')}">go find something</a>
% endif
