<%inherit file="/location/base_department.mako" />
<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/search/index.mako" import="search_results"/>
<%namespace name="wall" file="/sections/wall_snippets.mako" import="head_tags"/>

<%def name="head_tags()">
  ${parent.head_tags()}
  ${wall.head_tags()}
</%def>

<div id='wall'>
<div class="tip">
${_('This is a list of all the recent events in the subjects and groups of this university.')}
</div>
%if c.events:
  % for event in c.events:
    ${event.snippet()}
  % endfor
%else:
  ${_('Sorry, nothing new at the moment.')}
%endif
</div>
