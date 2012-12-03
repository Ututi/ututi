<%inherit file="/profile/home_base.mako" />
<%namespace file="/sections/standard_buttons.mako" import="close_button" />
<%namespace name="b" file="/sections/standard_blocks.mako" import="title_box"/>
<%namespace name="location" file="/widgets/ulocationtag.mako" />
<%namespace file="/widgets/sms.mako" import="sms_widget" />
<%namespace name="elements" file="/elements.mako" />
<%namespace file="/portlets/user.mako" import="invite_friends_portlet"/>
<%namespace file="/portlets/universal.mako" import="users_online_portlet,
                                                    about_portlet"/>

<%def name="head_tags()">
  ${parent.head_tags()}
  <script type="text/javascript">
  $(document).ready(function() {
      $('.group-description .action-link').click(function() {
          var group = $(this).closest('.group-description')
          $('.action-block:visible').slideUp('fast');
          if ($(this).hasClass('email'))
              group.find('.email.action-block:hidden').slideDown('fast');
          else if ($(this).hasClass('sms'))
              group.find('.sms.action-block:hidden').slideDown('fast');
          return false;
      });
  });
  </script>
</%def>

<%def name="portlets_secondary()">
  ${about_portlet()}
  ${invite_friends_portlet()}
  ${users_online_portlet()}
</%def>

<%def name="css()">
${parent.css()}

.alternative-link {
  font-size: 11px;
  margin-top: 5px;
}
.create-subject .side-box {
  float: right;
  border-color: #eee;
}

#view-page-link {
  float: right;
}
#subject-features {
  max-width: 220px;
}
#subject-search-form input {
  width: 200px;
}

button#add-student-group {
  font-weight: normal;
}
.group-description .action-reply {
    display: none;
}

.group-description .action-block {
    display: none;
}

.group-description .email.action-block {
    margin-top: 15px;
}

.group-description .sms-widget #sms_message {
    width: 100%;
}

.group-description .sms-widget .sms-box {
    background: transparent;
}

button.submit {
    margin-top: 10px;
}

.sms-widget .sms-box {
    width: 300px;
}

.sms-widget button.submit {
    margin-top: 0px;
}

.browse-link {
    display: block;
    margin-top: 5px;
}
</%def>

<%def name="pagetitle()">
  %if hasattr(c, 'welcome'):
    ${_("Welcome to Ututi")}
  %else:
    ${_("Dashboard")}
  %endif
</%def>

<% done = h.teacher_done_items(c.user) %>
<% counter = 1 %>

<%def name="profile_section()">
%if not 'profile' in done:
<div class="page-section feature-box profile">
  <div class="title">
    ${_("Fill your page")}
  </div>
  <p>${_("Tell some basic information about yourself by editing your profile.")}</p>
  ${h.button_to(_("Edit my page"), url(controller='profile', action='edit'),
                   method='GET', class_='dark edit')}
</div>
%else:
<div class="page-section profile">
  <div class="title">
    ${_("My profile page")}
    <span class="action-button">
      ${h.button_to(_("edit my page"), url(controller='profile', action='edit'),
                    method='GET', class_='dark edit')}
    </span>
  </div>
  <p>${_("Tell some basic information about yourself by editing your profile.")}</p>
  <a class="forward-link" href="${c.user.url(action='external_teacher_index')}">
    ${_("View my page")}
  </a>
</div>
%endif
</%def>

<%def name="group_entry(group, first)">
<div class="u-object group-description ${'with-top-line' if not first else ''}">
  <form class="close-button" method="POST" action="${url(controller='profile', action='delete_student_group')}">
    <div>
      <input type="hidden" name="group_id" value="${group.id}" class="event_type"/>
      <input type="image" src="/img/icons.com/close.png" title="${_('Delete this group')}" class="delete_group" name="delete_group_${group.id}"/>
    </div>
  </form>
  <div>
    <div class="group-title">
      <dt> ${group.title} </dt>
      <dd class="group-email" style="margin-right: 10px"> ${group.email} </dd>
      %if group.group:
        ${elements.location_links(group.group.location)}
      %endif
    </div>
  </div>

  <div class="group-actions">
      <dd class="settings">
        <a href="${url(controller='profile', action='edit_student_group', id=group.id)}" >
          ${_('Edit group')}
        </a>
      </dd>
      <dd class="email">
        <a href="#" title="${_('Send message')}" class="email action-link">
          ${_('Send message')}
        </a>
      </dd>
      %if group.group is not None:
      <dd class="sms">
        <a href="#" title="${_('Send SMS')}" class="sms action-link">
          ${_('Send SMS')}
        </a>
      </dd>
      %endif
  </div>

  <div class="email action-block">
    <form method="POST" action="${url(controller='profile', action='studentgroup_send_message', id=group.id)}" class="inelement-form group-message-form" enctype="multipart/form-data">
      ${h.input_line('subject', _('Message subject:'), class_='message_subject wide-input')}
      <div class="formField">
        <textarea name="message" class="message" rows="5" rows="50"></textarea>
      </div>
      <div class="formField">
        <label for="file">
          <span class="labelText">${_('Attachment:')}</span>
          <input type="file" name="file" />
        </label>
      </div>
      <div class="formSubmit">
        ${h.input_submit(_('Send'), class_="btn message-send")}
      </div>
      <br class="clear-right" />
    </form>
  </div>
  <div class="message-sent action-reply">
    ${_('Your message was successfully sent.')}
  </div>
  %if group.group is not None:
  <div class="sms action-block">
    ${sms_widget(user=c.user, group=group.group, text='', parts=[])}
  </div>
  <div class="sms-sent action-reply">
    ${_('Your SMS was successfully sent.')}
  </div>
  %endif
</div>
</%def>

<%def name="blog_post_entry(post, first=False)">
<div class="u-object blog-post-description ${'with-top-line' if not first else ''}">
  <div>
    <dt>
      <a class="action" href="${post.url()}">${h.ellipsis(post.title, 60)}</a>
    </dt>
  </div>
  <div style="margin-top: 5px">
    <dd class="edit">
      <a href="${url(controller='profile', action='edit_blog_post', id=post.id)}">${_("Edit")}</a>
    </dd>
    <dd class="comments">
      <a href="${post.url()}">${_("Comments")} (${len(post.comments)})</a>
    </dd>
  </div>
</div>
</%def>

<%def name="blog_section(blog_posts)">
<div class="page-section blog_posts">
  %if not c.has_blog_posts:
  <div class="title">
    ${_("Create a blog post")}
  </div>
  <div>
    <div class="create-blog-post clearfix">
      <p>${_('Create your first blog post.')}</p>
      ${h.button_to(_('Create a blog post'),
                    url(controller='profile', action='create_blog_post'),
                    class_='dark add',
                    method='GET')}
    </div>
  </div>
  %else:
  <div class="title">
    ${_("My blog posts")}
    <span class="action-button">
      ${h.button_to(_('create a blog post'),
                    url(controller='profile', action='create_blog_post'),
                    class_='dark add', method='GET')}
    </span>
  </div>
  <div>
    %for n, blog_post in enumerate(blog_posts[:3]):
      ${blog_post_entry(blog_post, n==0)}
    %endfor
  </div>
  <div class="all-posts-link">
    <a href="${url(controller='profile', action='edit_blog_posts')}">${_('All posts')}</a>
  </div>
  %endif
</div>
</%def>

<%def name="subject_entry(subject, first=False)">
<div class="u-object subject-description ${'with-top-line' if not first else ''}">
  ${close_button(url(controller='profile', action='unteach_subject', subject_id=subject.id), class_='unteach-button')}
  <div>
    <dt>
      <a class="action" href="${subject.url(action='feed')}">${h.ellipsis(subject.title, 60)}</a>
    </dt>
    ${elements.location_links(subject.location)}
  </div>
  <div style="margin-top: 5px">
    <dd class="feed">
      <a href="#" class="create-discussion-link">${_("Create discussion")}</a>
    </dd>
    <dd class="settings">
      <a href="${subject.url(action='edit')}">${_("Settings")}</a>
    </dd>
    <dd class="files">
      <a href="${subject.url(action='files')}">${_("Files")}</a>
      (${h.item_file_count(subject.id)})
    </dd>
    <dd class="pages">
      <a href="${subject.url(action='pages')}">${_("Wiki notes")}</a>
      (${h.subject_page_count(subject.id)})
    </dd>
  </div>
  <div class="action-block add_wall_post_block">
    <a name="wall-post"></a>
    <form method="POST" action="${url(controller='wall', action='create_subject_wall_post', redirect_to=subject.url(action='feed'))}" class="inelement-form wallpost_form">
        <input type="hidden" name="subject_id" value="${subject.id}"/>
        <div class="action-tease">${_("Write your post")}</div>
        <textarea name="post" class="tease-element"></textarea>
        ${h.input_submit(_('Send'), class_='dark inline action-button')}
        <a class="cancel-button" href="#cancel">${_("Cancel")}</a>
    </form>
  </div>
</div>
</%def>

<%def name="subject_section(subjects)">
<div class="page-section subjects">
  <div class="title">
    %if not 'subject' in done:
    ${_("Create your subjects")}
    %else:
    ${_("My courses")}
    <span class="action-button">
      ${h.button_to(_('add courses'),
                    url(controller='subject', action='add'),
                    class_='dark add')}
    </span>
    %endif
  </div>
  %if not 'subject' in done:
  <div class="create-subject clearfix">
    <%b:title_box title="${_('Features:')}" id="subject-features" class_="side-box">
    <ul class="feature-list small">
      <li class="files">${_("Upload course material")}</li>
      <li class="wiki">${_("Edit subject notes")}</li>
      <li class="notifications">${_("Notify your students")}</li>
      <li class="discussions">${_("Discuss the subject")}</li>
    </ul>
    </%b:title_box>
    <div class="content">
      <p>${_("Find subjects that your teach or create them.")}</p>
      <form id="subject-search-form" action="${url(controller='subject', action='lookup')}" method="POST">
        <input type="text" name="title" />
        ${location.hidden_fields(c.user.location)}
        ${h.input_submit(_('Create course'), '', class_='inline')}
      </form>
    </div>
  </div>
  %else:
  <div class="subject-description-list">
    <dl>
      %for n, subject in enumerate(subjects):
        ${subject_entry(subject, n == 0)}
      %endfor
    </dl>
  </div>
  %endif

  <script type="text/javascript">
  $(document).ready(function() {
    $('.subject-description-list a.unteach-button').click(function() {
      return confirm('${_("Are you sure you want to delete this subject?")}');
    });
    function clearBlock(block) {
        block.find('input[type="text"], textarea').val('');
        block.find('.tease-element').hide();
        block.find('.action-tease').show();
    }
    $('.subject-description .cancel-button').click(function() {
        clearBlock($(this).closest('.action-block'));
        return false;
    });

    $('.create-discussion-link').click(function () {
        $(this).closest('.subject-description').find('.action-block').toggle();
        return false;
    });
    $('.subject-description .action-tease').click(function() {
        $(this).hide().siblings('.tease-element').show().focus();
    });
  });
  </script>
</div>
</%def>

<%def name="group_section(groups)">
<div class="page-section groups">
  <div class="title">
    %if not 'group' in done:
    ${_("Add your students' contacts")}
    %else:
    ${_("My students' contacts")}
    <span class="action-button">
      ${h.button_to(_('add a contact'),
                    url(controller='profile', action='add_student_group'),
                    class_='dark add',
                    method='GET')}
    </span>
    %endif
  </div>
  %if not 'group' in done:
  <div class="content">
    <p>${_("Ututi will keep track of your student groups and make it easy to reach them.")}</p>
    ${h.button_to(_('Add student group'), url(controller='profile', action='add_student_group'),
       class_='dark add inline', method='GET', id='add-student-group')}
  </div>
  %else:
  <div class="group-description-list">
    <dl>
      %for n, group in enumerate(groups):
        ${group_entry(group, n == 0)}
      %endfor
    </dl>
  </div>
  <script type="text/javascript">
  $(document).ready(function() {
    $('.group-description-list .close-button').click(function() {
      return confirm('${_("Are you sure you want to delete this group?")}');
    });
  });
  </script>
  %endif
</div>
</%def>
${profile_section()}
${blog_section(c.user_blog_posts)}
${subject_section(c.user.taught_subjects)}
${group_section(c.user.student_groups)}
