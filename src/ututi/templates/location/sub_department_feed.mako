<%inherit file="/location/base.mako" />
<%namespace name="wall" file="/sections/wall_entries.mako" />
<%namespace name="discussion" file="/sections/discussion.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${wall.head_tags()}
  ${h.javascript_link('/javascript/dashboard.js')}
</%def>
<%def name="body_class()">wall location-wall</%def>

<%def name="pagetitle()">
  ${c.subdepartment.title}
</%def>

%if getattr(c, 'show_discussion_form', False):
  ${discussion.discussion_form('create_location_wall_post', 'location_id', c.location.id)}
  ${discussion.discussion_javascript()}
%endif

<div class="tip">
${_('This is a list of all recent events in this sub-department.')}
</div>
${wall.wall_entries(c.events)}
%if not c.events:
<p>${_('Sorry, nothing new at the moment.')}</p>
%endif
