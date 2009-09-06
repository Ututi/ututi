<%inherit file="/profile/base.mako" />
<%namespace file="/portlets/user.mako" import="*"/>
<%namespace file="/portlets/search.mako" import="*"/>

<%namespace file="/widgets/tags.mako" import="*"/>
<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/search/index.mako" import="search_results"/>

<%def name="portlets()">
<div id="sidebar">
  ${search_portlet(parts=['text'], target=url(controller='profile', action='search'))}

  ${user_groups_portlet()}

</div>
</%def>


<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
${h.stylesheet_link('/stylesheets/subject_selection.css')|n}
<script type="text/javascript">
//<![CDATA[
$(document).ready(function(){
  function unselectSubject(event) {
    var url = $(event.target).parent().prev('.remove_url').val();
    $.ajax({type: "GET",
            url: url,
            success: function(msg){
                $(event.target).parent().parent().remove();
    }});
    return false;
  }

  $('.remove_subject_button').click(unselectSubject);

  $('.select_subject_button').click(function (event) {
    var url = $(event.target).parent().prev('.select_url').val();
    $.ajax({type: "GET",
            url: url,
            success: function(msg){
                $(event.target).parent().parent().parent().after($(msg)[0]).remove();
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
  <div class="selected_subject_flash_message flash-message">
    <span class="close-link" onclick="$(event.target).parent().remove();">close</span>
    <span>
      Subject
      <a href="${subject.url()}" title="${subject.title}">
        ${subject.title}
      </a>
      was selected.
    </span>
  </div>
</%def>

<%def name="watched_subject(subject)">
  <li>
    <a href="${subject.url()}">${subject.title}</a>
    <input type="hidden" class="remove_url"
           value="${url(controller='profile', action='js_unwatch_subject', subject_id=subject.subject_id, subject_location_id=subject.location.id)}" />
    <a href="${url(controller='profile', action='unwatch_subject', subject_id=subject.subject_id, subject_location_id=subject.location.id)}" class="remove_subject_button">
      ${h.image('/images/details/icon_cross_larger.png', alt='unwatch')|n}
    </a>
  </li>
</%def>

<h2>${_('Watched subjects')}</h2>

<ul id="watched_subjects">
% for subject in c.watched_subjects:
    ${watched_subject(subject)}
% endfor
</ul>

<h2 class="subjects-suggestions">${_('Recommended subjects')}</h2>

${search_form(text=c.text, obj_type='subject', tags=c.tags, parts=['text', 'tags'], target=c.subjects)}

##overriding tag link definition
<%def name="item_tags(object)">
  <div class="item-tags">
    %for tag in object.location.hierarchy(full=True):
      ${tag_link(tag)}
    %endfor
    %for tag in object.tags:
      ${tag_link(tag)}
    %endfor
  </div>
</%def>

<%def name="tag_link(tag)">
    <a class="tag" title="${tag.title}" href="${url(controller='profile', action='subjects', tags=', '.join(tag.hierarchy()))}">
      ${tag.title}
    </a>
</%def>

## overriding the search result item definition
<%def name="search_subject(item)">
  <%
     object = item.object
  %>
  <div class="search-item snippet-subject">
    <div class="title">
      <a href="${object.url()}" title="${object.title}" class="item-title larger">${object.title}</a>
      <input type="hidden" class="select_url"
             value="${url(controller='profile', action='js_watch_subject', subject_id=item.object.subject_id, subject_location_id=item.object.location.id)}" />
      <a href="${url(controller='profile', action='watch_subject', subject_id=item.object.subject_id, subject_location_id=item.object.location.id)}" class="select_subject_button btn">
        <span>${_('Watch')}</span>
      </a>
    </div>

    <div class="description">
      ${object.lecturer}
    </div>
    ${item_tags(object)}
  </div>
</%def>

%if c.results:
${search_results(c.results, display=search_subject)}
%endif
