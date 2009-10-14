<%inherit file="/group/home.mako" />

<%def name="head_tags()">
${parent.head_tags()}
${h.stylesheet_link('/stylesheets/group.css')|n}
</%def>

% if c.step:
  ${path_steps(1)}
% endif

<%def name="watched_subject(subject)">
  <li>
    <a href="${subject.url()}">${subject.title}</a>
  </li>
</%def>

<h2 class="subjects-suggestions">${_('Watched subjects')}</h2>
<ul id="watched-subjects">
% for subject in c.group.watched_subjects:
  ${watched_subject(subject)}
% endfor
</ul>
