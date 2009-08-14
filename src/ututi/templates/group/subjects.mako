<%inherit file="/group/home.mako" />
<%namespace file="/widgets/tags.mako" import="*"/>
<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/search/index.mako" import="search_results"/>
<%namespace file="/group/add.mako" import="path_steps"/>

## overriding the search result item definition
<%def name="search_subject(item)">
  <div class="search-item">
    <a href="${item.object.url()}" title="${item.object.title}" class="item-title larger">${item.object.title}</a>
    <a href="${c.group.url(action='watch_subject', subject_id=item.object.subject_id, subject_location_id=item.object.location.id)}" class="select_subject_button">${_('Pick')}</a>
    <div>
    % if item.object.lecturer:
      <span class="small">${item.object.lecturer}</span>
    % endif
    </div>
    <div class="item-tags">
      %for tag in item.object.tags:
      <span class="tag">${tag.title}</span>
      %endfor
    </div>
  </div>
</%def>


<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
<script type="text/javascript">
//<![CDATA[
$(document).ready(function(){
  $('.select_subject_button').click(function (event) {
    return false;
  });
});
//]]>
</script>

${parent.head_tags()}
${h.stylesheet_link('/stylesheets/group.css')|n}

</%def>

<h1>${_('Group Subjects')}</h1>
% if c.step:
  ${path_steps(1)}
% endif
<h2 class="subjects-suggestions">${_('Chosen subjects')}</h2>
<hr/>
<ul id="watched-subjects">
% for subject in c.group.watched_subjects:
  <li>
    <div>
      <a href="${subject.url()}">
        <img src="${url('/images/bullet_small.png')}">
      </a>
      <h4>
        <a href="${subject.url()}">${subject.title}</a>
        <a href="${c.group.url(action='unwatch_subject', subject_id=subject.subject_id, subject_location_id=subject.location.id)}" class="remove_subject_button">${_('Remove')}</a>
      </h4>
      % if subject.lecturer:
      <p class="smaller">${subject.lecturer}</a></p>
      % endif
      <div>
      % for title in subject.location.hierarchy():
        <span class="tag">${title}</span>
      % endfor
      </div>
    </div>
  </li>
% endfor
</ul>

<h2 class="subjects-suggestions">${_('Watch subjects')}</h2>
<hr/>

${search_form(obj_type='subject', tags=c.tags, parts=['text', 'tags'], target="")}
<!--
<div id="frontpage-search">
  <form id="frontpage-search-form" method="post" action="">
    <div class="form-field">
      <label for="search-text" style="display: none;">${_('Search text')}</label>
      <input class="line large" type="text" name="search-text" id="search-text"/>
      <input class="submit" type="image" src="/images/search.png" name="search" value="Search"/>
    </div>
    <div class="form-field">
      ${tags_widget(c.group.location and ', '.join(c.group.location.hierarchy()))}
    </div>
  </form>
</div>
-->
%if c.results:
${search_results(c.results, display=search_subject)}
%endif

% if c.step:
<br/>
<hr/>
<a class="btn" href="${url(controller='group', action='invite_members_step', id=c.group_id)}" title="${_('Invite group members')}">
  <span>${_('Finish choosing subjects')}</span>
</a>
% endif
