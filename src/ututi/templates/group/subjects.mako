<%inherit file="/group/base.mako" />
<%namespace file="/widgets/tags.mako" import="*"/>
<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/search/index.mako" import="search_results"/>
<%namespace file="/sections/content_snippets.mako" import="item_tags, tag_link, item_location"/>

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
                if ($('#watched_subjects').children().size() == 1) {
                  $('#empty_subjects_msg').toggleClass('hidden');
                }

    }});
    return false;
  }

  $('.remove_subject_button').click(unselectSubject);

  $('.select_subject_button').click(function (event) {
    var url = $(event.target).closest('div').find('.select_url').val();
    $.ajax({type: "GET",
            url: url,
            success: function(msg){
                $(event.target).closest('.snippet-subject').after($(msg)[0]).remove();
                var selected_subject = $(msg)[2];
                $('#watched_subjects').append(selected_subject);
                $('.remove_subject_button', selected_subject).click(unselectSubject);

                if (($('#watched_subjects').children().size() > 1) && (! $('#empty_subjects_msg').hasClass('hidden'))) {
                  $('#empty_subjects_msg').toggleClass('hidden');
                }
     }});
    return false;
  });
});
//]]>
</script>

${parent.head_tags()}

</%def>

<%def name="css()">

.single-title {
   height: 22px;
   margin-top: 20px;
   margin-bottom: 20px;
}

.single-title h2 {
   font-weight: bold;
   float: left;
}

.single-title .action-button {
   float: right;
}

${parent.css()}
</%def>


<%def name="subject_flash_message(subject)">
  ${search_subject(subject, watched=True)}
</%def>

<%def name="watched_subject(subject, new = False)">
  <li class="enabled ${new and 'new' or ''}">
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
<%def name="search_subject(subject, watched=False)">
  %if not watched:
  <%
     object = subject.object
  %>
  %else:
  <%
     object = subject
  %>
  %endif
<div class="search-results-container">
  <div class="search-item snippet-subject">
    <a href="${object.url()}" title="${object.title}" class="item-title bold larger">${h.ellipsis(object.title, 60)}</a>
    <div style="float: right;" class="js-alternatives">
      %if not watched:
      <input type="hidden" class="select_url"
             value="${c.group.url(action='js_watch_subject', subject_id=object.subject_id, subject_location_id=object.location.id)}" />
      <a href="${c.group.url(action='watch_subject', subject_id=object.subject_id, subject_location_id=object.location.id)}"
         class="select_subject_button btn non-js"><span>${_('Watch')}</span></a>
      <button class="btn js select_subject_button"><span>${_('Watch')}</span></button>

      %else:
      ${h.image('/img/icons/tick_big.png', 'ok')|n}
      %endif
    </div>

    <div class="description">
      ${item_location(object)}
      % if object.teacher_repr:
       | ${object.teacher_repr}
      % endif
      %if object.tags:
       | ${item_tags(object)}
      %endif
    </div>
    <dl class="stats">
       <%
           file_cnt = len(object.files)
           page_cnt = len(object.pages)
           group_cnt = object.group_count()
           user_cnt = object.user_count()
        %>

        <dd class="files">${ungettext('%(count)s <span class="a11y">file</span>', '%(count)s <span class="a11y">files</span>', file_cnt) % dict(count = file_cnt)|n}</dd>
        <dd class="pages">${ungettext('%(count)s <span class="a11y">wiki page</span>', '%(count)s <span class="a11y">wiki pages</span>', page_cnt) % dict(count = page_cnt)|n}</dd>
        <dd class="watchedBy"><span class="a11y">${_('Watched by:')}</span>
          ${ungettext("%(count)s group", "%(count)s groups", group_cnt) % dict(count = group_cnt)|n}
          ${_('and')}
          ${ungettext("%(count)s member", "%(count)s members", user_cnt) % dict(count = user_cnt)|n}
        </dd>
    </dl>
  </div>
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

<div style="padding-top: 5px; padding-bottom: 10px;">
  <a class="back-link" href="${c.group.url(action='subjects')}">${_('Back to subject list')}</a>
</div>

<ul id="watched_subjects"  class="personal_watched_subjects">
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

<div class="single-title">
  <h2 class="subjects-suggestions">
    ${_('Choose subjects from list')}
  </h2>

  %if c.results:
  <div style="float: right;">
    ${h.button_to(_('Create a new subject'), c.group.url(action='add_subject'), method='get')}
  </div>
  %endif
</div>

${search_form(text=c.text, obj_type='subject', tags=c.tags, parts=['text', 'tags'], target=c.search_target)}

%if c.results:
${search_results(c.results, display=search_subject)}
%else:
<br />
${h.button_to(_('Create a new subject'), c.group.url(action='add_subject'), method='get')}
%endif
