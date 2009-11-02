<%inherit file="/profile/base.mako" />
<%namespace file="/portlets/sections.mako" import="*"/>

<%def name="portlets()">
${user_sidebar()}
</%def>


<%def name="head_tags()">
${parent.head_tags()}
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}

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

  $('.ignore_subject_button').click(function (event) {
    var url = $(event.target).parents("li:first").children(".ignore_url").val();
    $.ajax({type: "GET",
            url: url,
            success: function(msg){
                $(event.target).parents("li:first").removeClass("enabled").addClass("disabled");
    }});
    return false;
  });

  $('.unignore_subject_button').click(function (event) {
    var url = $(event.target).parents("li:first").children(".unignore_url").val();
    $.ajax({type: "GET",
            url: url,
            success: function(msg){
                $(event.target).parent().parent().removeClass("disabled").addClass("enabled");
    }});
    return false;
  });

  $('.select_interval_form .each').change(function (event) {
    var url = event.target.form.action;
    $(event.target.form).removeClass('select_interval_form')
                        .removeClass('select_interval_form_done')
                        .addClass('select_interval_form_in_progress');
    $.ajax({type: "GET",
            url: url,
            data: {'each': event.target.value, 'ajax': 'yes'},
            success: function(msg){
            $(event.target.form).removeClass('select_interval_form_in_progress')
                                .addClass('select_interval_form_done');
    }});
  });
});
//]]>
</script>
</%def>

<%def name="header(title, update_url, selected)">
<div class="hdr">
  <span class="larger">${title|n}</span>
  <div style="float:right;" class="small">
    ${_('Receive messages about updates in subjects')}
    <br />
    <form class="select_interval_form" action="${update_url}">
      <span class="btn" style="float: right;">
        <input type="submit" value="${_('Confirm')}" />
      </span>
      <script type="text/javascript">
        //<![CDATA[
         $('.select_interval_form .btn').hide();
        //]]>
      </script>
      <select name="each" class="each" style="float:right; font-size: 1em;">
        %for v, t in [('hour', _('immediatelly')), ('day', _('at the end of the day')), ('never', _('never'))]:
          %if v == selected:
            <option selected="selected" value="${v}">${t}</option>
          %else:
            <option value="${v}">${t}</option>
          %endif
        %endfor
      </select>
      <img class="done_icon" src="${url('/images/details/icon_done.png')}" />
      <img class="in_progress_icon" src="${url('/images/details/icon_progress.gif')}" />
    </form>
  </div>
</div>
</%def>

<div class="tip">${_('This is a list of the subjects You and/or groups You are in are watching.')}</div>

${header(_('Personally watched subjects'), url(controller='profile', action='set_receive_email_each'), c.user.receive_email_each)}

<ul class="personal_watched_subjects">
%if c.subjects:
  %for subject in c.subjects:
    <li class="enabled">
      ${h.link_to(subject.title, subject.url(), 35)}
      <input type="hidden" class="remove_url"
             value="${url(controller='profile', action='js_unwatch_subject', subject_id=subject.id)}" />
      <a href="${url(controller='profile', action='unwatch_subject', subject_id=subject.id)}" class="remove_subject_button">
        ${h.image('/images/details/icon_cross_subjects.png', alt='unwatch')|n}
      </a>
    </li>
  %endfor
%else:
    <li class="empty_note">
      ${_('You are not watching any subjects.')}
    </li>
%endif
</ul>

<div style="padding-top: 5px; padding-bottom: 10px;">
  <a class="forward-link" href="${url(controller='profile', action='watch_subjects')}">${_('Watch more subjects')}</a>
</div>


%for group in c.groups:
${header(_('Subjects watched by %(group_title)s') % dict(group_title=h.link_to(group.title, group.url())),
         group.url(action='set_receive_email_each'), group.is_member(c.user).receive_email_each)}

<ul class="personal_watched_subjects">
%if group.watched_subjects:
  %for subject in group.watched_subjects:
    %if subject in c.user.ignored_subjects:
      <% cls = 'disabled' %>
    %else:
      <% cls = 'enabled' %>
    %endif
    <li class="${cls}">
      ${h.link_to(subject.title, subject.url(), 35)}
      <input type="hidden" class="ignore_url"
             value="${url(controller='profile', action='js_ignore_subject', subject_id=subject.id)}" />
      <input type="hidden" class="unignore_url"
             value="${url(controller='profile', action='js_unignore_subject', subject_id=subject.id)}" />
      <a class="ignore_subject_button"
         href="${url(controller='profile', action='ignore_subject', subject_id=subject.id)}">
        ${h.image('/images/details/eye_open.png', alt='unwatch')|n}
      </a>
      <a class="unignore_subject_button"
         href="${url(controller='profile', action='unignore_subject', subject_id=subject.id)}">
        ${h.image('/images/details/eye_closed.png', alt='unwatch')|n}
      </a>
    </li>
  %endfor
%else:
    <li class="empty_note">
      ${_('This group is not watching any subjects.')}
    </li>
%endif
</ul>
<br />
%endfor
