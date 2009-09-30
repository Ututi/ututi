<%inherit file="/group/home.mako" />
<%namespace file="/widgets/tags.mako" import="*"/>
<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/search/index.mako" import="search_results"/>
<%namespace file="/sections/content_snippets.mako" import="item_tags, tag_link"/>
<%namespace file="/group/add.mako" import="path_steps"/>
<%namespace file="/portlets/group.mako" import="*"/>


<%def name="portlets()">
<div id="sidebar">
  ${group_info_portlet()}
  ${group_changes_portlet()}
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
                $('#watched-subjects').append(selected_subject);
                $('.remove_subject_button', selected_subject).click(unselectSubject);
    }});
    return false;
  });
});
//]]>
</script>

${parent.head_tags()}
${h.stylesheet_link('/stylesheets/group.css')|n}

</%def>

% if c.step:
  <h1>${_('Group Subjects')}</h1>
  ${path_steps(1)}
% endif

<%def name="subject_flash_message(subject)">
  <div class="selected_subject_flash_message flash-message">
    <span class="close-link" onclick="$(event.target).parent().remove();">${_('Close')}</span>
    <span>
      ${_('Subject %(subj)s was selected.') % dict(subj = h.link_to(subject.title, subject.url()))|n}
    </span>
  </div>
</%def>

<%def name="watched_subject(subject)">
  <li>
    <a href="${subject.url()}">${subject.title}</a>
    <input type="hidden" class="remove_url"
           value="${c.group.url(action='js_unwatch_subject', subject_id=subject.subject_id, subject_location_id=subject.location.id)}" />
    <a href="${c.group.url(action='unwatch_subject', subject_id=subject.subject_id, subject_location_id=subject.location.id)}" class="remove_subject_button">
      ${h.image('/images/details/icon_cross_larger.png', alt='unwatch')|n}
    </a>
  </li>
</%def>

<h2 class="subjects-suggestions">${_('Watched subjects')}</h2>
<ul id="watched-subjects">
% for subject in c.group.watched_subjects:
  ${watched_subject(subject)}
% endfor
</ul>

<h2 class="subjects-suggestions">${_('Recommended subjects')}</h2>

${search_form(text=c.text, obj_type='subject', tags=c.tags, parts=['text', 'tags'], target=c.search_target)}

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
    <a class="tag" title="${tag.title}" href="${url(controller='group', action='subjects', id=c.group.group_id, tags=', '.join(tag.hierarchy()))}">
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
             value="${c.group.url(action='js_watch_subject', subject_id=item.object.subject_id, subject_location_id=item.object.location.id)}" />
      <a href="${c.group.url(action='watch_subject', subject_id=item.object.subject_id, subject_location_id=item.object.location.id)}"
         class="select_subject_button btn"><span>${_('Watch')}</span></a>
    </div>


    <div class="description">
      ${object.lecturer}
    </div>
    ${item_tags(object)}
  </div>
</%def>

##overriding the search results definition
<%def name="search_results(results=None, display=None)">
<%
   if display is None:
       display = search_results_item
%>
<br />
<div id="search-results">
  %for item in results:
  ${display(item)}
  %endfor
</div>

%if len(results):
<div id="pager">${results.pager(format='~3~') }</div>
%endif
</%def>

%if c.results:
${search_results(c.results, display=search_subject)}
%endif

<div class="create_item">
  <span class="notice">${_('Did not find what you were looking for?')}</span>
  ${h.button_to(_('Create a new subject'), c.group.url(action='add_subject_step'))}
</div>

% if c.step:
<br />
<hr />
<a class="btn" href="${url(controller='group', action='invite_members_step', id=c.group.group_id)}" title="${_('Invite group members')}">
  <span>${_('Finish choosing subjects')}</span>
</a>
% endif
