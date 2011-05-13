<%inherit file="/user/teacher_base.mako" />
<%namespace name="wall" file="/sections/wall_entries.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${wall.head_tags()}
</%def>

<div class="section events">
  <div class="title">${_("Teacher's activity:")}</div>
  %if c.events:
    <div class="wall">
      ${wall.wall_entries(c.events)}
    </div>
  %else:
    ${_("No activity yet.")}
  %endif
</div>
