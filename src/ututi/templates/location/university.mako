<%inherit file="/location/base_university.mako" />
<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/search/index.mako" import="search_results"/>
<%namespace file="/portlets/structure.mako" import="*"/>
<%namespace file="/portlets/school.mako" import="*"/>
<%namespace file="/anonymous_index/en.mako" import="*"/>

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



