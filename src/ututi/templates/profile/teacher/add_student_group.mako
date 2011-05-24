<%inherit file="/profile/home_base.mako" />
<%namespace name="b" file="/sections/standard_blocks.mako" import="title_box"/>

<%def name="pagetitle()">
${_('Add a student group')}
</%def>

<%def name="css()">
  ${parent.css()}
  .side-box {
    float: right;
    width: 200px;
  }
</%def>

<div class="clearfix">
  <%b:title_box title="${_('Features:')}" id="group-features" class_="side-box">
    <ul class="feature-list small">
      <li class="email">${_("Email your students")}</li>
      <li class="file">${_("Attach course material")}</li>
    </ul>
  </%b:title_box>
  <!--
  <div class="feature-box one-column icon-group">
    <div class="title">
      ${_('Students groups that you teach to')}
    </div>
    <div class="clearfix">
      <div class="feature icon-email">
        ${h.literal(_("Easy way to contact your groups by sending a <strong>group message</strong>."))}
      </div>
    </div>
    <div class="action-button">
      ${h.button_to(_('Add students groups'), url(controller='profile', action='add_student_group'), class_='add', method='GET')}
    </div>
  </div>
  -->

  <form method="post" action="${url(controller='profile', action='add_student_group')}" id="student_group_form" class="fullForm">
    <fieldset>
    ${h.input_line('title', _('Title'))}
    ${h.input_line('email', _('Email address'))}
    ${h.input_submit(_('Save'), class_='btnMedium')}
    </fieldset>
  </form>
</div>
