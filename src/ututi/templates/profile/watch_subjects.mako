<%inherit file="/profile/base.mako" />

<%namespace file="/widgets/tags.mako" import="*"/>
<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/search/index.mako" import="search_results"/>
<%namespace file="/sections/content_snippets.mako" import="item_location"/>
<%namespace file="/sections/content_snippets.mako" import="item_tags"/>


<%def name="pagetitle()">
${_('Add a subject')}
</%def>

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
    }});
    return false;
  });
});
//]]>
</script>

${parent.head_tags()}
</%def>

<%def name="subject_flash_message(subject)">
  ${search_subject(subject, watched=True)}
</%def>

<%def name="watched_subject(subject, new = False)">
  <li class="enabled ${new and 'new' or ''}">
    <a href="${subject.url()}">${subject.title}</a>
    <input type="hidden" class="remove_url"
           value="${url(controller='profile', action='js_unwatch_subject', subject_id=subject.id)}" />
    <a href="${url(controller='profile', action='unwatch_subject', subject_id=subject.id)}" class="remove_subject_button">
      ${h.image('/images/details/icon_cross_subjects.png', alt='unwatch')|n}
    </a>
  </li>
</%def>

<ul id="watched_subjects" class="personal_watched_subjects" style="padding-top: 10px">
%if c.watched_subjects:
  % for subject in c.watched_subjects:
      ${watched_subject(subject)}
  % endfor
%else:
  <li class="empty_note">
    ${_('You are not watching any subjects.')}
  </li>
%endif
</ul>
%if c.watched_subjects:
  <div style="padding: 5px;">
    <a class="forward-link-to" href="${url(controller='profile', action='notification_settings')}"> ${_('Notification settings')}</a>
  </div>
%endif

<br />

${search_form(text=c.text, obj_type='subject', tags=c.tags, parts=['text', 'tags'], target=c.search_target)}

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
  <div class="search-item snippet-subject">
    <a href="${object.url()}" title="${object.title}" class="item-title bold larger">${h.ellipsis(object.title, 60)}</a>
    <div style="float: right;" class="js-alternatives">
      %if not watched:
      <input type="hidden" class="select_url"
             value="${url(controller='profile', action='js_watch_subject', subject_id=object.id)}" />
      <a href="${url(controller='profile', action='watch_subject', subject_id=object.id)}" class="select_subject_button non-js">
        <span>${_('Watch')}</span>
      </a>
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
</%def>


%if c.results:
${search_results(c.results, display=search_subject)}
%endif
