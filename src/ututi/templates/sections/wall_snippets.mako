<%def name="wall_item()">
<div class="wall_item ${caller.classes()}">
  <div class="description">
    ${caller.body()}
  </div>
  %if hasattr(caller, "content"):
    <div class="content">
      ${caller.content()}
    </div>
  %endif
  <div class="event_time">${caller.when()}</div>
</div>
</%def>

<%def name="generic(object)">
  <%self:wall_item>
    <%def name="classes()">generic</%def>
    <%def name="when()">${object.when()}</%def>
    ${object.render()|n}
  </%self:wall_item>
</%def>

<%def name="file_uploaded_subject(event)">
  <%self:wall_item>
    <%def name="classes()">file_uploaded subject_event</%def>
    <%def name="content()">
      <div class="file_link">
        ${h.object_link(event.file)}
      </div>
    </%def>
    <%def name="when()">${event.when()}</%def>
    ${_("%(user_link)s has uploaded a new file in the subject %(subject_link)s.") % \
       dict(user_link=h.object_link(event.user),
            subject_link=h.object_link(event.file.parent)) | n}
  </%self:wall_item>
</%def>

<%def name="folder_created_subject(event)">
  <%self:wall_item>
    <%def name="classes()">folder_created subject_event</%def>
    <%def name="when()">${event.when()}</%def>
    ${_("%(user_link)s has created a new folder %(folder_name)s in the subject %(subject_link)s.") % \
       dict(user_link=h.object_link(event.user),
            folder_name=event.file.folder,
            subject_link=h.object_link(event.file.parent)) | n}
  </%self:wall_item>
</%def>

<%def name="file_uploaded_group(event)">
  <%self:wall_item>
    <%def name="classes()">file_uploaded group_event</%def>
    <%def name="content()">
      <div class="file_link">
        ${h.object_link(event.file)}
      </div>
    </%def>
    <%def name="when()">${event.when()}</%def>
    ${_("%(user_link)s has uploaded a new file in the group %(group_link)s.") % \
       dict(user_link=h.object_link(event.user),
            group_link=h.object_link(event.file.parent)) | n}
  </%self:wall_item>
</%def>

<%def name="folder_created_group(event)">
  <%self:wall_item>
    <%def name="classes()">folder_created group_event</%def>
    <%def name="when()">${event.when()}</%def>
    ${_("%(user_link)s has created a new folder %(folder_name)s in the group %(group_link)s.") % \
       dict(user_link=h.object_link(event.user),
            folder_name=event.file.folder,
            group_link=h.object_link(event.file.parent)) | n}
  </%self:wall_item>
</%def>

<%def name="subject_modified(event)">
  <%self:wall_item>
    <%def name="classes()">subject_event subject_modified</%def>
    <%def name="when()">${event.when()}</%def>
    ${_("%(user_link)s has edited the subject %(subject_link)s.") % \
       dict(user_link=h.object_link(event.user),
            subject_link=h.object_link(event.context)) | n}
  </%self:wall_item>
</%def>

<%def name="subject_created(event)">
  <%self:wall_item>
    <%def name="classes()">subject_event subject_created</%def>
    <%def name="when()">${event.when()}</%def>
    ${_("%(user_link)s has created the subject %(subject_link)s.") % \
       dict(user_link=h.object_link(event.user),
            subject_link=h.object_link(event.context)) | n}
  </%self:wall_item>
</%def>

<%def name="mailinglistpost_created(event)">
  <%self:wall_item>
    <%def name="classes()">message_event mailinglistpost_created</%def>
    <%def name="content()">${h.nl2br(h.ellipsis(event.message.body, 100))}</%def>
    <%def name="when()">${event.when()}</%def>
    ${_("%(user_link)s has posted a new message %(message_link)s to the group %(group_link)s.") % \
       dict(user_link=h.object_link(event.user),
            group_link=h.object_link(event.context),
            message_link=h.object_link(event.message)) | n}
  </%self:wall_item>
</%def>

<%def name="forumpost_created(event)">
  <%self:wall_item>
    <%def name="classes()">message_event forumpost_created</%def>
    <%def name="content()">${h.nl2br(h.ellipsis(event.message.message, 100))}</%def>
    <%def name="when()">${event.when()}</%def>
    ${_("%(user_link)s has posted a new message %(message_link)s in the forum %(group_link)s.") % \
       dict(user_link=h.object_link(event.user),
            group_link=h.object_link(event.context),
            message_link=h.object_link(event.post)) | n}
  </%self:wall_item>
</%def>

<%def name="sms_sent(event)">
  <%self:wall_item>
    <%def name="classes()">sms_event sms_sent</%def>
    <%def name="content()">${event.sms_text()}</%def>
    <%def name="when()">${event.when()}</%def>
    ${_("%(user_link)s has sent an sms to the group %(group_link)s.") % \
       dict(user_link=h.object_link(event.user),
            group_link=h.object_link(event.context)) | n}
  </%self:wall_item>
</%def>

<%def name="groupmember_joined(event)">
  <%self:wall_item>
    <%def name="classes()">group_event groupmember_joined</%def>
    <%def name="when()">${event.when()}</%def>
    ${_("%(user_link)s joined the group %(group_link)s.") % \
       dict(user_link=h.object_link(event.user),
            group_link=h.object_link(event.context)) | n}
  </%self:wall_item>
</%def>

<%def name="groupmember_left(event)">
  <%self:wall_item>
    <%def name="classes()">group_event groupmember_left</%def>
    <%def name="when()">${event.when()}</%def>
    ${_("%(user_link)s left the group %(group_link)s.") % \
       dict(user_link=h.object_link(event.user),
            group_link=h.object_link(event.context)) | n}
  </%self:wall_item>
</%def>

<%def name="groupsubject_start(event)">
  <%self:wall_item>
    <%def name="classes()">group_event groupsubject_start</%def>
    <%def name="content()">
      <div class="subject_link">
        ${h.object_link(event.subject)}
      </div>
    </%def>
    <%def name="when()">${event.when()}</%def>
    ${_("The group %(group_link)s has started watching the subject %(subject_link)s.") % \
       dict(subject_link=h.object_link(event.subject),
            group_link=h.object_link(event.context)) | n}
  </%self:wall_item>
</%def>

<%def name="groupsubject_stop(event)">
  <%self:wall_item>
    <%def name="classes()">group_event groupsubject_stop</%def>
    <%def name="content()">
      <div class="subject_link">
        ${h.object_link(event.subject)}
      </div>
    </%def>
    <%def name="when()">${event.when()}</%def>
    ${_("The group %(group_link)s has stopped watching the subject %(subject_link)s.") % \
       dict(subject_link=h.object_link(event.subject),
            group_link=h.object_link(event.context)) | n}
  </%self:wall_item>
</%def>

<%def name="page_created(event)">
  <%self:wall_item>
    <%def name="classes()">page_event page_created</%def>
    <%def name="when()">${event.when()}</%def>
    ${_("%(user_link)s has created a page %(page_link)s in the subject %(subject_link)s.") % \
       dict(subject_link=h.object_link(event.context),
            page_link=h.object_link(event.page),
            user_link=h.object_link(event.user)) | n}
  </%self:wall_item>
</%def>

<%def name="page_modified(event)">
  <%self:wall_item>
    <%def name="classes()">page_event page_modified</%def>
    <%def name="when()">${event.when()}</%def>
    ${_("%(user_link)s has modified a page %(page_link)s in the subject %(subject_link)s.") % \
       dict(subject_link=h.object_link(event.context),
            page_link=h.object_link(event.page),
            user_link=h.object_link(event.user)) | n}
  </%self:wall_item>
</%def>
