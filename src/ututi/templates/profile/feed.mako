<%inherit file="/profile/home_base.mako" />
<%namespace file="/elements.mako" import="tooltip" />
<%namespace name="actions" file="/profile/wall_actionblock.mako" import="action_block, head_tags, css"/>
<%namespace name="wall" file="/sections/wall_entries.mako" />

<%def name="body_class()">wall profile-wall</%def>

<%def name="pagetitle()">
  ${_("News feed")}
</%def>

<%def name="head_tags()">
  ${wall.head_tags()}
  ${actions.head_tags()}
</%def>

<%def name="css()">
  ${actions.css()}
  .wall a#settings-link {
      display: block;
      float: right;
      margin-top: -30px; /* throws above page title (XXX) */
      padding-left: 14px;
      background: url('/img/icons.com/settings.png') no-repeat left center;
  }
</%def>

<%def name="empty_wall_page()">
  <div class="feature-box one-column icon-group">
    <div class="title">
      ${_("About groups:")}
    </div>
    <div class="clearfix">
      <div class="feature icon-discussions">
        <strong>${_("Discussions")}</strong>
        - ${_("a place to discuss study matters and your student life.")}
      </div>
      <div class="feature icon-email">
        <strong>${_("E-mail")}</strong>
        - ${_("each group has an email address. If someone writes to this address, all groupmates will receive the email.")}
      </div>
      <div class="feature icon-file">
        <strong>${_("Private group files")}</strong>
        - ${_("private file storage area for files that you don't want to share with outsiders.")}
      </div>
      <div class="feature icon-notifications">
        <strong>${_("Subject notifications")}</strong>
        - ${_("receive notifications from subjects that your group is following.")}
      </div>
    </div>
    <div class="action-button">
      ${h.button_to(_('Find your group'), c.user.location.url(action='catalog', obj_type='group'), class_='add', method='GET')}
    </div>
  </div>
  <div class="feature-box one-column icon-subject">
    <div class="title">
      ${_("About subjects:")}
    </div>
    <div class="clearfix">
      <div class="feature icon-file">
        <strong>${_("A place for course material sharing")}</strong>
        - ${_("upload and share course material with students of your class, university or the entire world.")}
      </div>
      <div class="feature icon-discussions">
        <strong>${_("Discussions")}</strong>
        - ${_("a place to discuss subject related questions with students and teachers.")}
      </div>
    </div>
    <div class="clearfix">
      <div class="feature icon-wiki">
        <strong>${_("Shared notes")}</strong>
        - ${_("create wiki notes collaboratively with your class-mates or take notes during the lecture and upload it directly to Ututi.")}
      </div>
    </div>
    <div class="action-button">
      ${h.button_to(_('Find your subjects'), c.user.location.url(action='catalog', obj_type='subject'), class_='add')}
    </div>
  </div>
</%def>

%if not c.user.groups and not c.user.watched_subjects:
    ${empty_wall_page()}
%else:
    <a id="settings-link" href="${url(controller='profile', action='wall_settings')}">${_('News feed settings')}</a>
    ${actions.action_block(c.msg_recipients, c.file_recipients, c.wiki_recipients)}
    ${wall.wall_entries(c.events)}
%endif
