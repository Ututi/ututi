<%inherit file="/base.mako" />

<%def name="head_tags()">
${parent.head_tags()}
</%def>


<h1>${_('Error!')}</h1>

<img src="${url('/images/details/icon_nope.png')}" />

<div>
${_("Oops, an error happened, please don't leave us, go back and try doing something else or look for information.")}
</div>

% if request.referrer.startswith(url("/", qualified=True)):
    <a href="#" onclick="javascript: history.go(-1); return false;">${_('go back')}</a>
% else:
    <a href="${url(controller='search')}">${_('go find something')}</a>
% endif
