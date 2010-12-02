<%inherit file="/profile/edit.mako" />

<%def name="pagetitle()">
${_('Watched subjects notification settings')}
</%def>

<%def name="head_tags()">
${parent.head_tags()}

<script type="text/javascript">
//<![CDATA[

$(document).ready(function(){
  $('.ignore_subject_button').click(function (event) {
    var url = $('input.ignore_url', $(event.target).closest("li")).val();
    $.ajax({type: "GET",
            url: url,
            success: function(msg){
                $(event.target).closest("li").removeClass("enabled").addClass("disabled");
    }});
    return false;
  });

  $('.unignore_subject_button').click(function (event) {
    var url = $('input.unignore_url', $(event.target).closest("li")).val();
    $.ajax({type: "GET",
            url: url,
            success: function(msg){
                $(event.target).closest('li').removeClass("disabled").addClass("enabled");
    }});
    return false;
  });

  $('.subscribe_group_button').click(function (event) {
    var url = $('input.subscribe_url', $(event.target).closest("li")).val() + '?js=1';
    $.ajax({type: "GET",
            url: url,
            success: function(msg){
                $(event.target).closest("li").removeClass("disabled").addClass("enabled");
    }});
    return false;
  });

  $('.unsubscribe_group_button').click(function (event) {
    var url = $('input.unsubscribe_url', $(event.target).closest("li")).val() + '?js=1';
    $.ajax({type: "GET",
            url: url,
            success: function(msg){
                $(event.target).closest('li').removeClass("enabled").addClass("disabled");
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

<%def name="subjects_block(title, update_url, selected, subjects, group=None)">
<%self:rounded_block class_='portletGroupFiles subject_description'>
  <div class="GroupFiles GroupFilesGroups ${not group and 'GroupFilesDalykai' or ''}">
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
            %for v, t in [('hour', _('immediately')), ('day', _('at the end of the day')), ('never', _('never'))]:
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

  %if group is not None:
    ${subscription_option(group)}
  %endif

  <div>
    %if subjects:
      ${subject_list(subjects, group)}
    %elif group is None:
      <span class="empty_note">
        ${_('No watched subjects were found.')}
      </span>
    %endif
  </div>
</%self:rounded_block>
</%def>

<%def name="subscription_option(group)">
<div class="GroupFilesContent-line-dal mailing-option">
  <ul class="grupes-links-list-dalykai">
    %if group.is_subscribed(c.user):
      <% cls = 'enabled' %>
    %else:
      <% cls = 'disabled' %>
    %endif
    <li class="${cls}">
      <dl>
        <dt>
          <span> 
            %if group.mailinglist_enabled:
            <a class="blark" href="${group.url(action='mailinglist')}">
              ${_("Group's mailing list")}
            </a>
            %else:
            <a class="blark" href="${group.url(action='forum')}">
              ${_("Group's forum")}
            </a>
            %endif
          </span>
          <input type="hidden" class="subscribe_url"
                 value="${group.url(action='subscribe')}" />
          <input type="hidden" class="unsubscribe_url"
                 value="${group.url(action='unsubscribe')}" />
          <a class="unsubscribe_group_button"
             href="${group.url(action='unsubscribe')}">
            ${h.image('/images/details/eye_open.png', alt='unsubscribe')|n}
          </a>
          <a class="subscribe_group_button"
             href="${group.url(action='subscribe')}">
            ${h.image('/images/details/eye_closed.png', alt='subscribe')|n}
          </a>
        </dt>
      </dl>
    </li>
  </ul>
  <br class="clear-left" />
</div>
</%def>

<%def name="subject_list(subjects, group=None)">
  <%
     count = len(subjects)
  %>
%for n, subject in enumerate(subjects, 1):
<div class="GroupFilesContent-line-dal${n == count and '-last' or ''}">
  <ul class="grupes-links-list-dalykai">
    %if group is not None and subject in c.user.ignored_subjects:
      <% cls = 'disabled' %>
    %elif group is not None:
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
          %if group is not None:
          <input type="hidden" class="ignore_url"
                 value="${url(controller='profile', action='js_ignore_subject', subject_id=subject.id)}" />
          <input type="hidden" class="unignore_url"
                 value="${url(controller='profile', action='js_unignore_subject', subject_id=subject.id)}" />
          <a class="ignore_subject_button"
             href="${url(controller='profile', action='ignore_subject', subject_id=subject.id)}">
            ${h.image('/images/details/eye_open.png', alt='ignore')|n}
          </a>
          <a class="unignore_subject_button"
             href="${url(controller='profile', action='unignore_subject', subject_id=subject.id)}">
            ${h.image('/images/details/eye_closed.png', alt='unignore')|n}
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
${subjects_block(_("Personally watched subjects' notifications"), url(controller='profile', action='set_receive_email_each'), c.user.receive_email_each, c.subjects)}

%for group in c.groups:
  ${subjects_block(_("Group's %(group_title)s notifications") % dict(group_title=h.link_to(group.title, group.url())),
                   group.url(action='set_receive_email_each'), group.is_member(c.user).receive_email_each, group.watched_subjects, group)}
%endfor
</div>
