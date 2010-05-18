<%inherit file="/group/home.mako" />
<%namespace file="/widgets/tags.mako" import="*"/>
<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/search/index.mako" import="search_results"/>
<%namespace file="/sections/content_snippets.mako" import="item_tags, tag_link"/>

<%def name="head_tags()">
<script type="text/javascript">
//<![CDATA[
$(document).ready(function(){
  function unselectSubject(event) {
    var url = $(event.target).parent().prev('.remove_url').val();
    $.ajax({type: "GET",
            url: url,
            success: function(msg){
                $(event.target).parent().parent().remove();
                if ($('#watched-subjects').children().size() == 1) {
                  $('#empty_subjects_msg').toggleClass('hidden');
                }

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
                if (($('#watched-subjects').children().size() > 1) && (! $('#empty_subjects_msg').hasClass('hidden'))) {
                  $('#empty_subjects_msg').toggleClass('hidden');
                }
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
    <span class="close-link" onclick="$(event.target).parent().remove();">${_('Close')}</span>
    <span>
      ${_('Subject %(subj)s was selected.') % dict(subj = h.link_to(subject.title, subject.url()))|n}
    </span>
  </div>
</%def>

<%def name="watched_subject(subject, new=False)">
  <li class="${new and 'new' or ''}">
    <a href="${subject.url()}">${subject.title}</a>
    <input type="hidden" class="remove_url"
           value="${c.group.url(action='js_unwatch_subject', subject_id=subject.subject_id, subject_location_id=subject.location.id)}" />
    <a href="${c.group.url(action='unwatch_subject', subject_id=subject.subject_id, subject_location_id=subject.location.id)}" class="remove_subject_button">
      ${h.image('/images/details/icon_cross_subjects.png', alt='unwatch')|n}
    </a>
  </li>
</%def>

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

<div class="comment">${_('This is the list of subjects watched by this group. By selecting to watch subjects, the group will always be notified of any changes in them.')}</div>
<ul id="watched-subjects">
%if c.group.watched_subjects:
% for subject in c.group.watched_subjects:
  ${watched_subject(subject)}
% endfor
%endif

<%
   if len(c.group.watched_subjects) == 0:
     cls = ''
   else:
     cls = 'hidden'
%>

<li id="empty_subjects_msg" class="empty_msg ${cls}">
${_('Your group is not watching any subjects. Add them by searching.')}
</li>
</ul>

<%
   cls = ''
   if not c.searched and not c.list_open:
       cls = 'click2show'
%>
<div class="${cls}">
  <div class="click" id="expand-search">
    ${_('recommended subjects')}
  </div>
  <div class="show">

    <div style="margin: 10px 0; overflow: auto;">
      <h2 class="subjects-suggestions" style="float: left;">
        ${_('Recommended subjects')}
      </h2>

      %if c.results:
        <a style="float: left; margin-left: 30px;" class="btn" href="${c.group.url(action='add_subject')}"><span>${_('Create a new subject')}</span></a>
      %endif
    </div>

    %if not c.results:
    <div class="create_item">
      <a class="btn-large" href="${c.group.url(action='add_subject')}"><span>${_('Create a new subject')}</span></a>
    </div>
    %endif

    ${search_form(text=c.text, obj_type='subject', tags=c.tags, parts=['text', 'tags'], target=c.search_target)}

    %if c.results:
    ${search_results(c.results, display=search_subject)}
    % else:
    <div class="create_item">
      <a class="btn-large" href="${c.group.url(action='add_subject')}"><span>${_('Create a new subject')}</span></a>
    </div>
    %endif
</div>
