<%inherit file="/group/home.mako" />
<%namespace file="/widgets/tags.mako" import="*"/>

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
</%def>

<h1>${_('Group Subjects')}</h1>

<h2 class="subjects-suggestions">Pasirinkti dalykai</h2>
<hr>
<ul id="watched-subjects">
% for subject in c.group.watched_subjects:
  <li>
    <div>
      <a href="${subject.url()}">
        <img src="${url('/images/bullet_small.png')}">
      </a>
      <h4>
        <a href="${subject.url()}">${subject.title}</a>
      </h4>
      % if subject.lecturer:
      <p class="smaller"><a href="#">${subject.lecturer}</a></p>
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

<h2 class="subjects-suggestions">Stebėti dalykus</h2>
<hr>

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

<ul id="search-results">
% for subject in c.recomended_subjects:
  <li>
    <div>
      <a href="${subject.url()}">
        <img src="${url('/images/bullet_small.png')}">
      </a>
      <h4>
        <a href="${subject.url()}">${subject.title}</a>
        <a href="${c.group.url(action='watch_subject', subject_id=subject.id, subject_location_id=subject.location.id)}" class="select_subject_button">${_('Pick')}</a>
      </h4>
      % if subject.lecturer:
      <p class="smaller"><a href="#">${subject.lecturer}</a></p>
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
