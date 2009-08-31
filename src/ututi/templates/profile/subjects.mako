<%inherit file="/profile/base.mako" />
<%namespace file="/widgets/tags.mako" import="*"/>
<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/search/index.mako" import="search_results"/>

<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
<script type="text/javascript">
//<![CDATA[
$(document).ready(function(){
  function unselectSubject(event) {
    var url = $(event.target).prev('.remove_url').val();
    $.ajax({type: "GET",
            url: url,
            success: function(msg){
                $(event.target).parent().remove();
    }});
    return false;
  }

  $('.remove_subject_button').click(unselectSubject);

  $('.select_subject_button').click(function (event) {
    var url = $(event.target).prev('.select_url').val();
    $.ajax({type: "GET",
            url: url,
            success: function(msg){
                $(event.target).parent().after($(msg)[0]).remove();
                var selected_subject = $(msg)[2];
                $('#watched_subjects').append(selected_subject);
                $('.remove_subject_button', selected_subject).click(unselectSubject);
    }});
    return false;
  });
});
//]]>
</script>

${parent.head_tags()}
</%def>

<%def name="subject_flash_message(subject)">
  <div class="selected_subject_flash_message">
    Subject
      <a href="${subject.url()}" title="${subject.title}">
        ${subject.title}
      </a>
    was selected.
    <span class="close_button" onclick="$(event.target).parent().remove();">close</span>
  </div>
</%def>

<%def name="watched_subject(subject)">
  <li>
    <a href="${subject.url()}">${subject.title}</a>
    <input type="hidden" class="remove_url"
           value="${url(controller='profile', action='js_unwatch_subject', subject_id=subject.subject_id, subject_location_id=subject.location.id)}" />
    <a href="${url(controller='profile', action='unwatch_subject', subject_id=subject.subject_id, subject_location_id=subject.location.id)}" class="remove_subject_button">${_('X')}</a>
  </li>
</%def>

<h2>${_('Watched subjects')}</h2>

<ul id="watched_subjects">
% for subject in c.watched_subjects:
    ${watched_subject(subject)}
% endfor
</ul>

<hr/>

<h2>${_('Search results')}</h2>

${search_form(obj_type='subject', tags=c.tags, parts=['text'], target=c.subjects)}

## overriding the search result item definition
<%def name="search_subject(item)">
  <div class="search-item">
    <a href="${item.object.url()}" title="${item.object.title}" class="item-title larger">${item.object.title}</a>
    <input type="hidden" class="select_url"
           value="${url(controller='profile', action='js_watch_subject', subject_id=item.object.subject_id, subject_location_id=item.object.location.id)}" />
    <a href="${url(controller='profile', action='watch_subject', subject_id=item.object.subject_id, subject_location_id=item.object.location.id)}" class="select_subject_button">${_('Pick')}</a>
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

%if c.results:
${search_results(c.results, display=search_subject)}
%endif
