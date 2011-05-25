<%inherit file="/profile/home_base.mako" />
<%namespace name="b" file="/sections/standard_blocks.mako" import="title_box"/>

<%def name="pagetitle()">
${_('Add a student group')}
</%def>

<%def name="css()">
  ${parent.css()}
  #group-features {
    float: right;
    width: 200px;
  }
</%def>

<%def name="group_action_url()">${url(controller='profile', action='add_student_group')}</%def>

<div class="clearfix">
  <%b:title_box title="${_('Your student groups:')}" id="group-features">
    <ul class="feature-list small">
      <li class="group">${_("Keep track of your student groups")}</li>
      <li class="email">${_("Email your students from your dashboard")}</li>
      <li class="files">${_("Attach files to your messages")}</li>
      <li class="sms">${_("Send SMS messages from your dashboard to Ututi groups")}</li>
    </ul>
  </%b:title_box>
  <form method="post" action="${self.group_action_url()}" id="student_group_form" class="narrow">
    <fieldset>
    ${h.input_line('title', _('Title'),
      help_text=_("Enter a title to identify this group, e. g. Computer Science freshmen or CS 1st year."))}
    ${h.input_line('email', _('Email address'),
      help_text=_("Enter email address for this group. It can be Ututi or any other mailing list, or a private email address."))}
    ${h.input_submit(_('Save'), class_='btnMedium')}
    </fieldset>
  </form>
</div>
