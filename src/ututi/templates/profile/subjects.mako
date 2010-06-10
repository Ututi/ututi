<%inherit file="/profile/base.mako" />

<%def name="pagetitle()">
${_('Watched subjects notification settings')}
</%def>

<%def name="head_tags()">
${parent.head_tags()}

<script type="text/javascript">
//<![CDATA[

$(document).ready(function(){
  function unselectSubject(event) {
    var url = $(event.target).parent().prev('.remove_url').val();
    $.ajax({type: "GET",
            url: url,
            success: function(msg){
                $(event.target).closest('ul').parent().remove();
    }});
    return false;
  }

  $('.remove_subject_button').click(unselectSubject);

  $('.ignore_subject_button').click(function (event) {
    var url = $(event.target).closest("li").children(".ignore_url").val();
    $.ajax({type: "GET",
            url: url,
            success: function(msg){
                $(event.target).closest("li").removeClass("enabled").addClass("disabled");
    }});
    return false;
  });

  $('.unignore_subject_button').click(function (event) {
    var url = $(event.target).closest("li").children(".unignore_url").val();
    $.ajax({type: "GET",
            url: url,
            success: function(msg){
                $(event.target).closest('li').removeClass("disabled").addClass("enabled");
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

<%def name="subjects_block(title, update_url, selected, subjects, unwatch=False, my_subjects=False)">
<%self:rounded_block class_='portletGroupFiles subject_description'>
  <div class="GroupFiles GroupFilesDalykai">
    <h2 class="portletTitle bold">
      ${title|n}
    </h2>
    <div class="group-but" style="top: 10px;">
      <form class="select_interval_form" action="${update_url}">
        ${h.input_submit(_('Confirm'))}
        <script type="text/javascript">
          //<![CDATA[
            $('.select_interval_form .btn').hide();
          //]]>
        </script>
        <label for="each" class="grey verysmall">${_('email notifications')}
          <select name="each" class="each" style="font-size: 1em;">
            %for v, t in [('hour', _('immediatelly')), ('day', _('at the end of the day')), ('never', _('never'))]:
              %if v == selected:
                <option selected="selected" value="${v}">${t}</option>
              %else:
                <option value="${v}">${t}</option>
              %endif
            %endfor
          </select>
        </label>
        <img class="done_icon" src="${url('/images/details/icon_done.png')}" />
        <img class="in_progress_icon" src="${url('/images/details/icon_progress.gif')}" />
      </form>
    </div>
  </div>
  <div>
    %if subjects:
      ${subject_list(subjects, unwatch)}
    %else:
      <span class="empty_note">
        ${_('No watched subjects were found.')}
      </span>
    %endif
  </div>
  %if my_subjects:
    <div style="padding: 0; margin-left: 20px; margin-top: 5px;">
      ${h.button_to(_('Add a subject'), url(controller='profile', action='watch_subjects'), class_='btnMedium')}
    </div>
  %endif
</%self:rounded_block>
</%def>

<%def name="subject_list(subjects, unwatch=False)">
  <%
     count = len(subjects)
  %>
  %for n, subject in enumerate(subjects):
  <div class="GroupFilesContent-line-dal">
	<ul class="grupes-links-list-dalykai">
      %if not unwatch and subject in c.user.ignored_subjects:
        <% cls = 'disabled' %>
      %elif not unwatch:
        <% cls = 'enabled' %>
      %else:
        <% cls = '' %>
      %endif
      <li class="${cls}">
		<dl>
		  <dt>
            <span>
              <a class="subject_title blark" href="${subject.url()}">${subject.title}</a>
            </span>
            %if unwatch:
            <input type="hidden" class="remove_url"
                   value="${url(controller='profile', action='js_unwatch_subject', subject_id=subject.id)}" />
            <a href="${url(controller='profile', action='unwatch_subject', subject_id=subject.id)}" class="remove_subject_button">
              ${h.image('/images/details/icon_cross_subjects.png', alt='unwatch')|n}
            </a>
            %else:
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
            %endif
          </dt>
		</dl>
	  </li>
	</ul>
    <br class="clear-left" />
  </div>
  %endfor
</%def>

<div id="subject_settings">
${subjects_block(_('Personally watched subjects'), url(controller='profile', action='set_receive_email_each'), c.user.receive_email_each, c.subjects, True, True)}

%for group in c.groups:
  ${subjects_block(_("Group's %(group_title)s subjects") % dict(group_title=h.link_to(group.title, group.url())),
                   group.url(action='set_receive_email_each'), group.is_member(c.user).receive_email_each, group.watched_subjects, False)}
%endfor
</div>
