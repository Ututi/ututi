<%inherit file="/base.mako" />
<%namespace file="/profile/base.mako" name="profile"/>
<%namespace file="/portlets/user.mako" import="teacher_related_links_portlet"/>
<%namespace file="/portlets/universal.mako" import="login_portlet, powered_by_ututi"/>
<%namespace file="/elements.mako" import="tabs, location_links" />

<%def name="portlets()">
  ${teacher_related_links_portlet(c.teacher)}
  ${login_portlet(c.teacher.location)}
  ${powered_by_ututi()}
</%def>

<%def name="head_tags()">
  ${parent.head_tags()}
  %if c.teacher.location.title_path == ['vu', 'mif']:
    ${h.stylesheet_link(h.path_with_hash('/branded/vu-mif/style.css'))}
    <script type="text/javascript">
      $(function () {
          $('#language-switch-form select option[value=pl]').remove();
      });
    </script>
  %endif
</%def>

<%def name="title()">
  ${c.teacher.fullname}
</%def>

<%def name="css()">
  ${parent.css()}
  .teacher-position {
    font-size: 14px;
  }
  #user-information .label {
    font-weight: bold;
  }
  #user-information #user-logo {
    width: 130px;
    height: 130px;
  }
</%def>

<%def name="teacher_info_block()">
<div id="user-information" class="clearfix">
  <div class="user-logo-container">
    <img id="user-logo" src="${c.teacher.url(action='logo', width=200)}" alt="logo" />
  </div>

  <div class="user-info">

    <div class="teacher-name">
      ${c.teacher.fullname}
    </div>

    %if c.teacher.teacher_position:
      <div class="teacher-position">
        ${c.teacher.teacher_position}
      </div>
    %endif

    <div class="teacher-location">
      ${location_links(c.teacher.location, full_title=True, external=True, sub_department=c.teacher.sub_department)}
    </div>

    <ul class="icon-list" id="teacher-contact-information">

      %if c.teacher.work_address:
      <li class="address icon-university">
        <span class="label">${_('Address')}:</span> ${c.teacher.work_address}
      </li>
      %endif

      %if c.teacher.phone_number and c.teacher.phone_confirmed:
      <li class="phone icon-mobile">
        <span class="label">${_('Phone')}:</span> ${c.teacher.phone_number}
      </li>
      %endif

      %if c.teacher.emails and (c.user or c.teacher.email_is_public):
      <li class="email icon-contact">
        <span class="label">${_('E-mail')}:</span> ${h.literal(', '.join([h.mail_to(email.email) for email in c.teacher.emails if email.confirmed]))}
      </li>
      %endif

      %if c.teacher.site_url:
      <li class="webpage icon-network">
        <span class="label">${_('Personal webpage')}:</span> <a href="${c.teacher.site_url}">${c.teacher.site_url}</a>
      </li>
      %endif

      ## <li class="icon-social-buttons">
      ##   <a href="#"><img src="${url('/img/social/facebook_16.png')}" /></a>
      ##   <a href="#"><img src="${url('/img/social/twitter_16.png')}" /></a>
      ## </div>

    </ul>
  </div>
</div>
</%def>

${teacher_info_block()}

${tabs(c.tabs, c.current_tab)}

<%def name="pagetitle()"></%def>

%if c.user is c.teacher and hasattr(self, 'actionlink'):
  <div class="above-page-title" id="edit-action-link">
    ${self.actionlink()}
  </div>
%endif

<h1 class="page-title underline">
  ${self.pagetitle()}
</h1>

${next.body()}
