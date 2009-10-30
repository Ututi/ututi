<%inherit file="/profile/base.mako" />
<%namespace file="/portlets/user.mako" import="*"/>
<%namespace file="/portlets/search.mako" import="*"/>

<%def name="portlets()">
<div id="sidebar">
  ${search_portlet(parts=['text'], target=url(controller='profile', action='search'))}
  ${user_groups_portlet()}
</div>
</%def>


<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
${h.stylesheet_link('/stylesheets/profile.css')|n}

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
    console.log(url);
    $.ajax({type: "GET",
            url: url,
            success: function(msg){
                $(event.target).parents("li:first").removeClass("enabled").addClass("disabled");
    }});
    return false;
  });

  $('.unignore_subject_button').click(function (event) {
    var url = $(event.target).parents("li:first").children(".unignore_url").val();
    console.log(url);
    $.ajax({type: "GET",
            url: url,
            success: function(msg){
                $(event.target).parent().parent().removeClass("disabled").addClass("enabled");
    }});
    return false;
  });
});
//]]>
</script>

${parent.head_tags()}
</%def>

<%def name="header(title, update_url='')">
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
      <select style="float:right; font-size: 1em;">
        <option value="immediatelly">${_('immediatelly')}</option>
        <option value="daily">${_('at the end of the day')}</option>
        <option value="never">${_('never')}</option>
      </select>
    </form>
    <img style="float:right;" src="${url('/images/details/icon_done.png')}" />
    <img style="float:right;" src="${url('/images/details/icon_progress.gif')}" />
  </div>
</div>
</%def>

${header(_('Personally watched subjects'))}

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
    <li>
      ${_('You are not watching any subjects.')}
    </li>
%endif
</ul>

<div style="padding-top: 10px; padding-bottom: 10px;">
<a href="${url(controller='profile', action='watch_subjects')}" class="btn"><span>${_('Watch more subjects')}</span></a>
</div>

%for group in c.groups:
${header(_('Subjects watched by %(group_title)s') % dict(group_title=h.link_to(group.title, group.url())))}

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
    <li>
      ${_('This group is not watching any subjects.')}
    </li>
%endif
</ul>
<br />
%endfor
