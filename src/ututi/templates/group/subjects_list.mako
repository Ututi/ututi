<%inherit file="/group/base.mako" />
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
                $(event.target).closest('.snippet-subject').remove();
                if ($('#SearchResults').children().size() == 2) {
                  $('#empty_subjects_msg').toggleClass('hidden');
                  $('').toggleClass('');
                }

    }});
    return false;
  }

  $('.remove_subject_button').click(unselectSubject);

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

${parent.head_tags()}

</%def>


<%def name="subjects_block(title, subjects)">
<%self:rounded_block class_='portletGroupFiles subject_description'>
  <div class="GroupFiles GroupFilesDalykai">
    <h2 class="portletTitle bold">
      ${title|n}
    </h2>
    <div class="group-but" style="top: 10px;">
      ${h.button_to(_('add a subject'), c.group.url(action='subjects_watch'))}
    </div>
  </div>
  <div id="SearchResults">
    %if subjects:
      ${subject_list(subjects)}
    %endif
    <div class="empty_note${' hidden' if subjects else ''|n}" 
         id="empty_subjects_msg"
         style="border-bottom: 1px solid #ded8d8">
      ${_('No watched subjects were found.')}
    </div>
    <div class="search-item" style="padding-top: 10px">
      <form class="select_interval_form" action="${c.group.url(action='set_receive_email_each')}">
        ${h.input_submit(_('Confirm'))}
        <script type="text/javascript">
          //<![CDATA[
            $('.select_interval_form .btn').hide();
          //]]>
        </script>
        <label for="each" class="blark">${_('Receive email notifications')}
          <% selected = c.group.is_member(c.user).receive_email_each %>
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
        <img class="done_icon" src="${url('/images/details/icon_done.png')}" style="margin-right: 15px;"/>
        <img class="in_progress_icon" src="${url('/images/details/icon_progress.gif')}" style="margin-right: 15px;"/>
      </form>
    </div>

  </div>
</%self:rounded_block>
</%def>

<%def name="subject_item(object)">
  <div class="search-item snippet-subject">
    <div style="float: right; margin-right: 15px;">
      <input type="hidden" class="remove_url"
             value="${c.group.url(action='js_unwatch_subject', subject_id=object.subject_id, subject_location_id=object.location.id)}" />
      <a href="${c.group.url(action='unwatch_subject', subject_id=object.subject_id, subject_location_id=object.location.id)}" class="remove_subject_button">
        ${h.image('/img/icons/cross_big.png', alt='unwatch')|n}
      </a>
    </div>

    <a href="${object.url()}" title="${object.title}" class="item-title bold">${object.title}</a>
    <span class="verysmall">(${_('Subject rating:')} </span><span>${h.image('/images/details/stars%d.png' % object.rating(), alt='', class_='subject_rating')}<span class="verysmall">)</span></span>
    <div class="description">
      ${item_location(object)}
      % if object.lecturer:
       | ${object.lecturer}
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

<%def name="subject_list(subjects)">
  <%
     count = len(subjects)
  %>
  %for subject in subjects:
    ${subject_item(subject)}
  %endfor
</%def>

<div id="subject_settings">
  ${subjects_block(_('Subjects'), c.group.watched_subjects)}
</div>
