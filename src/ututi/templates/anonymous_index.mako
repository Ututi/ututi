<%inherit file="/base.mako" />

<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/anonymous.css')|n}
${h.javascript_link('/javascripts/forms.js')|n}
</%def>

<div id="block-left">

  <div class="sidebar-block">
    <div class="rounded-header">
      <div class="rounded-right">
        <h3>${_('Become a part of Ututi')}</h3>
      </div>
    </div>
    <div class="content">
      <ul class="horizontal-menu">
        <li class="active"><a href="#" class="larger">${_('New account')}</a></li>
        <li><a href="#" class="larger">${_('OpenID')}</a></li>
      </ul>

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
    </div>
  </div>


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
    <ul class="horizontal-menu larger">
      <li class="active">${_('Subjects')}</li>
      <li>${_('Groups')}</li>
      <li>${_('Answers')}</li>
      <li>${_('Everything')}</li>
    </ul>
    <form id="frontpage-search-form" method="post" action="#">
      <div class="form-field">
        <label for="search-text" style="display: none;">${_('Search text')}</label>
        <input class="line large" type="text" name="search-text" id="search-text"/>
        <input class="submit" type="image" src="/images/search.png" name="search" value="Search"/>
      </div>
    </form>

  </div>

</div>

