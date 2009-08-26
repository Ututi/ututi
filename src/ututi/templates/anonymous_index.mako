<%inherit file="/base.mako" />

<%namespace file="/search/index.mako" import="search_form"/>

<%def name="head_tags()">
${parent.head_tags()}
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
${h.stylesheet_link('/stylesheets/anonymous.css')|n}
</%def>

<%def name="portlets()">
<div id="sidebar">
  <%self:portlet id="ututi_join_portlet">
    <%def name="header()">
      ${_('Become a part of Ututi')}
    </%def>
      <form id="registration_form" method="post" action="${url('/register')}">
        <div class="form-field">
          <input class="line" type="text" id="fullname" name="fullname" size="40"/>
          <label for="fullname">${_('Fullname')}</label>
        </div>
        <div class="form-field">
          <input class="line" type="text" id="email" name="email" size="40"/>
          <label for="email">${_('Email')}</label>
        </div>
        <div class="form-field">
          <input class="line" type="password" id="new_password" name="new_password" size="40"/>
          <label for="new_password">${_('Password')}</label>
        </div>
        <div class="form-field">
          <input class="line" type="password" id="repeat_password" name="repeat_password" size="40"/>
          <label for="repeat_password">${_('Repeat password')}</label>
        </div>
        <div class="form-field">
          <span class="btn">
            <input type="submit" value="${_('Register')}"/>
          </span>
        </div>
      </form>
      <br style="clear: right;" />
  </%self:portlet>
</div>
</%def>



  <h1>${_('UTUTI - student information online')}</h1>
  <ul id="ututi_info" class="bullets_large">
    <li>${_('What can You find here?')}<br/>
      <span class="small">${_('Mailing lists, academic groups, universities, file sharing.')}</span>
    </li>
    <li>${_('What can You do here?')}<br/>
      <span class="small">${_('Create lecture notes, keep Your study materials, upload and store files.')}</span>
    </li>
    <li>${_('Why here?')}<br/>
      <span class="small">${_("Because it's convenient.")}</span>
    </li>
    <li>${_('What is convenient?')}<br/>
      <span class="small">${_('Everything is in one place.')}</span>
    </li>
  </ul>

  <div id="frontpage-search">
    <h1>${_('Ututi search')}</h1>

    ${search_form()}

  </div>

