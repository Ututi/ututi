<%inherit file="/portlets/base.mako"/>

<%def name="portlet_file(file)">
  <li>
    <a href="${file.url()}" title="${file.title}">${h.ellipsis(file.title, 30)}</a>
    <input class="delete_url" type="hidden" value="${file.url(action='delete')}" />
    %if file.can_write():
      <img src="${url('/images/delete.png')}" alt="delete file" class="delete_button" />
    %endif
  </li>
</%def>

<%def name="group_info_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>

  <%self:portlet id="group_info_portlet">
    <%def name="header()">
      <a ${h.trackEvent(c.group, 'home', 'portlet_header')|n} href="${group.url()}" title="${group.title}">${_('Group information')}</a>
    </%def>
    %if group.logo is not None:
      <img id="group-logo" src="${url(controller='group', action='logo', id=group.group_id, width=70)}" alt="logo" />
    %endif
    <div class="structured_info">
      <h4>${group.title}</h4>
      <span class="small">${group.location and ' | '.join(group.location.path)}</span><span class="small year"> | ${group.year.year}</span><br />
      <a class="small" href="${url(controller='groupforum', action='new_thread', id=c.group.group_id)}" title="${_('Mailing list address')}">${group.group_id}@${c.mailing_list_host}</a><br />
      <span class="small">${len(group.members)} ${_('members')}</span>
    </div>
    <div class="description small">
      ${group.description}
    </div>

    <div class="footer">
      %if group.is_admin(c.user):
        <a class="more" href="${url(controller='group', action='edit', id=group.group_id)}" title="${_('Edit group settings')}">${_('Edit')}</a>
      %endif
      %if group.is_member(c.user):
        <div class="click2show">
          <span id="group_settings_toggle" class="click">${_("My group settings")}</span>
          <div class="show" id="group_settings_block">
            %if group.is_subscribed(c.user):
              <a href="${group.url(action='unsubscribe')}" class="btn inactive"><span>${_("Do not get email")}</span></a>
            %else:
              <a href="${group.url(action='subscribe')}" class="btn"><span>${_("Get email")}</span></a>
            %endif
            <a href="${group.url(action='leave')}" class="btn inactive"><span>${_("Leave group")}</span></a>
          </div>
        </div>
      %endif
    </div>
  </%self:portlet>
</%def>

<%def name="group_changes_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>

  <%self:portlet id="group_changes_portlet" portlet_class="inactive">
    <%def name="header()">
      <a ${h.trackEvent(c.group, 'events', 'portlet_header')|n} href="${group.url()}" title="${_('Latest changes')}">${_('Latest changes')}</a>
    </%def>
    <ul class="event-list">
      %for event in group.group_events[:5]:
        <li>${event.render()|n}</li>
      %endfor
    </ul>
    <div class="footer">
      <a ${h.trackEvent(c.group, 'events', 'portlet_footer')|n} class="more" href="${url(controller='group', action='home', id=group.group_id)}" title="${_('All changes')}">${_('All changes')}</a>
    </div>
  </%self:portlet>
</%def>

<%def name="group_members_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>

  <%self:portlet id="group_members_portlet" portlet_class="inactive">
    <%def name="header()">
      <a ${h.trackEvent(c.group, 'members', 'portlet_header')|n} href="${group.url(action='members')}" title="${_('Group members')}">${_('Recently seen')}</a>
    </%def>
    %for member in group.last_seen_members[:3]:
    <div class="user-logo-link">
      <div class="user-logo">
        <a href="${url(controller='user', action='index', id=member.id)}" title="${member.fullname}">
          %if member.logo is not None:
            <img src="${url(controller='user', action='logo', id=member.id, width=40, height=40)}" alt="${member.fullname}"/>
          %else:
            ${h.image('/images/user_logo_small.png', alt=member.fullname)|n}
          %endif
        </a>
      </div>
      <div>
        <a href="${url(controller='user', action='index', id=member.id)}" title="${member.fullname}">
          <span class="small">${member.fullname}</span>
        </a>
      </div>
    </div>
    %endfor
    <br style="clear: both;" />
    <div class="footer">
      <a ${h.trackEvent(c.group, 'members', 'portlet_footer')|n} class="more" href="${url(controller='group', action='members', id=group.group_id)}" title="${_('All group members')}">${_('All group members')}</a>
    </div>
  </%self:portlet>
</%def>

<%def name="group_watched_subjects_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>
  <%self:portlet id="subject_portlet" portlet_class="inactive">
    <%def name="header()">
      <a ${h.trackEvent(c.group, 'subjects', 'portlet_header')|n} href="${group.url(action='subjects')}" title="${_('All watched subjects')}">${_('Watched subjects')}</a>
    </%def>
    %if not group.watched_subjects:
      ${_('Your group is not watching any subjects!')}
    %else:
    <ul id="group-subjects" class="subjects-list">
      % for subject in group.watched_subjects[:5]:
      <li>
        <a href="${subject.url()}" title="${subject.title}">${h.ellipsis(subject.title, 35)}</a>
      </li>
      % endfor
    </ul>
    %endif
    <div class="footer">
      <a ${h.trackEvent(c.group, 'subjects', 'portlet_footer')|n}
         class="more"
         href="${url(controller='group', action='subjects', id=group.group_id)}"
         title="${_('All watched subjects')}">${_('All watched subjects')}</a>
    </div>
  </%self:portlet>
</%def>

<%def name="group_forum_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>
  <%self:portlet id="forum_portlet" portlet_class="inactive">
    <%def name="header()">
      <a ${h.trackEvent(c.group, 'forum', 'portlet_header')|n} href="${group.url(action='forum')}" title="${_('Group forum')}">${_('Group messages')}</a>
    </%def>
    %if group.all_messages:
      <table id="group_latest_messages">
        %for message in group.all_messages[:5]:
        <tr>
          <td class="time">${h.fmt_shortdate(message.sent)}</td>
          <td class="subject"><a href="${message.url()}" title="${message.subject}, ${message.author.fullname}">${h.ellipsis(message.subject, 25)}</a></td>
        </tr>
        %endfor
      </table>
    %else:
      <div class="notice">${_("The groups's forum is empty.")}</div>
    %endif
    <br style="clear: both;" />
    <div class="footer">
      <a ${h.trackEvent(c.group, 'forum', 'portlet_footer')|n}
         class="more" href="${url(controller='group', action='forum', id=group.group_id)}" title="${_('Group forum')}">${_('Group forum')}</a>
      <a href="${url(controller='groupforum', action='new_thread', id=c.group.group_id)}" class="btn"><span>${_("New topic")}</span></a>
    </div>
  </%self:portlet>
</%def>

<%def name="group_files_portlet(group=None)">
  <%
     if group is None:
         group = c.group
     files = group.all_files(5)
  %>
  <%self:portlet id="group_files_portlet" portlet_class="inactive">
    <%def name="header()">
      <a ${h.trackEvent(c.group, 'files', 'portlet_header')|n} href="${group.url(action='files')}" title="${_('Group files')}">${_('Fast file upload')}</a>
    </%def>
   <script type="text/javascript">
   //<![CDATA[
   function deleteFile(event) {
       var folder = $(event.target).parent().parent();
       var url = $(event.target).prev('.delete_url').val();
       $.ajax({type: "GET",
               url: url,
               success: function(msg){
                   $(event.target).parent().remove();
                   if ($('.file', folder).size() == 0) {
                       $('.message', folder).show();
                   }
       }});
   }

   $(document).ready(function(){
    $('.delete_button').click(deleteFile);

    function setUpUpload(i, btn) {
      var button = $(btn);
      var upload_url = $(btn).siblings('input').val();
      var list = $(btn).parents('#group_files_portlet_content').children('ul');
      new AjaxUpload(button,{
          action: upload_url,
          name: 'attachment',
          data: {folder: ''},
          onSubmit : function(file, ext, iframe){
              iframe['progress_indicator'] = $(document.createElement('li'));
              $('li:first', list).before(iframe['progress_indicator']);
              iframe['progress_indicator'].text(file);
              iframe['progress_ticker'] = $(document.createElement('span'));
              iframe['progress_ticker'].appendTo(iframe['progress_indicator']).text('Uploading');
              var progress_ticker = iframe['progress_ticker'];
              var interval;

              // Uploding -> Uploading. -- Uploading...
              interval = window.setInterval(function(){
                  var text = progress_ticker.text();
                  if (text.length < 13){
                      progress_ticker.text(text + '.');
                  } else {
                      progress_ticker.text('Uploading');
                  }
              }, 200);
              iframe['interval'] = interval;
          },
          onComplete: function(file, response, iframe){
              iframe['progress_indicator'].replaceWith(response);
              window.clearInterval(iframe['interval']);
              $('.delete_button').click(deleteFile);
          }
      });
    };
    $('.upload .target').each(setUpUpload);
   });
   //]]>
   </script>
    %if files:
      <ul>
        %for f in files:
        ${portlet_file(f)}
        %endfor
      </ul>
    %else:
      <div class="notice">${_("There are no files yet.")}</div>
    %endif
    <br />
    <div class="footer">
      <a ${h.trackEvent(c.group, 'files', 'portlet_footer')|n}
         class="more" href="${group.url(action='files')}" title="${_('All group files')}">${_('All group files')}</a>

      <div class="upload_dropdown click2show">
      <div class="click button">
        <div>
          ${_('upload file to...')}
        </div>
      </div>
      <div class="show target_list">
        <%
           items = [group] + group.watched_subjects
           n = len(items)
        %>
        %for i, obj in enumerate(items):
          <%
             cls = ''
             if i == 0:
                 cls = 'first'
             if i == n - 1:
                 cls = 'last'
          %>
        <div class="upload target_item ${cls}">
          <input type="hidden" name="upload_url" value="${obj.url(action='upload_file_short')}"/>
          <div class="target">${h.ellipsis(obj.title, 17)}</div>
        </div>
        %endfor
      </div>
    </div>
    </div>
  </%self:portlet>
</%def>
