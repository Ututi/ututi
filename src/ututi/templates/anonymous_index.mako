<%inherit file="/ubase-nomenu.mako" />

<%def name="css()">
#vote_link {
  font-size: 14px;
  font-weight: bold;
  text-align: center;
  padding: 10px 0;
}
</%def>

%if c.lang != 'pl':
<div id="vote_link">
  ${_('Changes are coming to %s!') % h.link_to('UTUTI', url(controller='home', action='new_ututi'))|n}
  ${_('See if <a href="/voting">Your university has gathered enough votes</a> to be transfered to the new UTUTI!')|n}
</div>
%endif

<div id="homeSearchNotesBlock">
  <h2>
    <a href="${url(controller='search', action='index', obj_type='subject')}" class="frontpage-title-link">${_('Search for notes')}</a>
  </h2>
<a class="link-to-search-for-notes" href="${url(controller='search', action='index', obj_type='subject')}"></a>
  <p>${_('Your study materials')}</p>
  <ul>
    <li>${_('Subjects and files')}</li>
    <li>${_('Shared lecture notes')}</li>
    <li>${_('Universities and departments')}</li>
  </ul>
  <form method="get" action="${url(controller='search', action='index')}" id="search_form_portlet">
    <fieldset>
      <label class="textField textFieldBig">
        <span class="a11y">${_('Enter the search string')}: </span><input name="text" type="text"><span class="edge"></span>
      </label>
      <button type="submit" class="btnMedium"><span>${_('search_fp')}</span></button>
    </fieldset>
  </form>
</div><div id="homeRegisterBlock">
  <h2>
    <a class="frontpage-title-link" href='#' onclick="$('#homeRegisterStep').click()">${_('Join')}</a>    
  </h2>

  <div id="registrationForm" class="${'shown' if c.show_registration else 'hidden'}">
    <form id="registration_form" method="post" action="${url(controller='home', action='register')}">
    <fieldset>
      %if c.hash:
        <input type="hidden" name="hash" value="${c.hash}"/>
      %endif
      <form:error name="came_from"/>
      %if c.came_from:
        <input type="hidden" name="came_from" value="${c.came_from}" />
      %endif
      <form:error name="fullname"/>
      <label>
        <span class="labelText">${_('Full name')}</span>
        <span class="textField">
          <input type="text" name="fullname"/>
          <span class="edge"></span>
        </span>
      </label>
      <form:error name="email"/>
      <label>
        <span class="labelText">${_('Email')}</span>
        <span class="textField">
          <input type="text" name="email" value="${c.email}"/>
          <span class="edge"></span>
        </span>
      </label>
      %if c.gg_enabled:
      <form:error name="gadugadu"/>
      <label>
        <span class="labelText">${_('Gadu gadu')}</span>
        <span class="textField">
          <input type="text" name="gadugadu" value=""/>
          <span class="edge"></span>
        </span>
      </label>
      %else:
      <input type="hidden" id="gadugadu" name="gadugadu"/>
      %endif

      <form:error name="new_password"/>
      <label>
        <span class="labelText">${_('Password')}</span>
        <span class="textField">
          <input type="password" name="new_password" />
          <span class="edge"></span>
        </span>
      </label>
      <form:error name="repeat_password"/>
      <label>
        <span class="labelText">${_('Repeat password')}</span>
        <span class="textField">
          <input type="password" name="repeat_password"/>
          <span class="edge"></span>
        </span>
      </label>
      <form:error name="agree"/>
      <label id="agreeWithTOC"><input class="checkbox" type="checkbox" checked="checked" name="agree" value="true"/>${_('I agree to the ')} <a rel="nofollow" id="terms_link" href="${url(controller='home', action='terms')}">${_('terms of use')}</a></label>
      <div style="text-align: center;">
        <button class="btnMedium" type="submit" value="${_('Register')}"><span>${_('Register')}</span></button>
      </div>
    </fieldset>
  </form>

  <div id="federated-login-comment">
      ${_('... or connect using your Google or Facebook account.')}
  </div>

  <div id="register_openid">
    <a href="${url(controller='federation', action='google_register')}">
      ${h.image('/img/google-logo.gif', alt='Log in using Google', class_='google-login')}
    </a>
    <fb:login-button perms="email"
      onlogin="show_loading_message(); window.location = '${url(controller='federation', action='facebook_login')}'"
     >${_('Connect')}</fb:login-button>
  </div>

  </div>
  <div id="registrationTeaser" class="${'hidden' if c.show_registration else ''}">
    <a href='#' onclick="$('#homeRegisterStep').click()">
      <img src="${url('/img/person.png')}" alt="${_('Register')}"/>
    </a>
    <div id="homeRegisterWelcome">
      ${_('Here you and your classmates can use the file storage for sharing information and create group for communication.')}
    </div>
    <div class="homeRegisterStep">
      <button class="btnLarge" type="button" id="homeRegisterStep"><span>${_('register')}</span></button>
    </div>
    <script type="text/javascript">
      $('#homeRegisterStep').click(function() {
          $('#registrationTeaser').addClass('hidden');
          $('#registrationForm').removeClass('hidden');
      });
    </script>
  </div>
</div><div id="homeCreateGroupBlock">
    <h2><a class="frontpage-title-link" href="${url(controller='group', action='create_academic')}">${_("Create a group")}</a></h2>

  <a class="home-link-to-create-group" href="${url(controller='group', action='create_academic')}"></a>
  <p>${_('Groups have')}</p>
  <ul>
    <li style="background-image: url('img/icons/comment_green_17.png');">${_('A mailing list or forum')}</li>
    <li style="background-image: url('img/icons/file_private_green_17.png');">${_('Private file storage')}</li>
    <li style="background-image: url('img/icons/subjects_green_17.png');">${_('A list of studied subjects')}</li>
  </ul>
  <div class="homeCreateGroup">
    ${h.button_to(_('Create group'), url(controller='group', action='create_academic'),  method='GET', class_='btnPlus btnLarge')}
  </div>

</div>
<div id="homePopularSubjects">
  <h2>${_('Popular subjects')}</h2>
  %if c.subjects:
  <ul>
    %for subject in c.subjects:
    <li>
      <dl>
        <dt><a href="${subject['url']}">${subject['title']}</a></dt>
        <%
           file_cnt = subject['file_cnt']
           page_cnt = subject['page_cnt']
           group_cnt = subject['group_cnt']
           user_cnt = subject['user_cnt']
        %>
        <dd class="files">${ungettext('%(count)s <span class="a11y">file</span>', '%(count)s <span class="a11y">files</span>', file_cnt) % dict(count = file_cnt)|n}</dd>
        <dd class="pages">${ungettext('%(count)s <span class="a11y">wiki page</span>', '%(count)s <span class="a11y">wiki pages</span>', page_cnt) % dict(count = page_cnt)|n}</dd>
        <dd class="watchedBy"><span class="a11y">${_('Watched by:')}</span> 
          ${ungettext("%(count)s group", "%(count)s groups", group_cnt) % dict(count = group_cnt)|n}
          ${_('and')}
          ${ungettext("%(count)s member", "%(count)s members", user_cnt) % dict(count = user_cnt)|n}
        </dd>
      </dl>
    </li>
    %endfor
  </ul>
  %endif

</div><div id="homeActiveUniversities">
  <h2>${_('Active universities')}</h2>
  %if c.universities:
  <ul>
    %for university in c.universities:
    <%
       logo_style = ''
       if university['has_logo']:
           logo_style = 'background-image: url(%s);' % url(controller='structure', action='logo', id=university['id'], width=20, height=20)
       subject_cnt = h.location_count(university['id'], 'subject')
       group_cnt = h.location_count(university['id'], 'group')
       file_cnt = h.location_count(university['id'], 'file')
    %>
    <li style="${logo_style|n}">
      <dl>
        <dt><a href="${university['url']}">${university['title']}</a></dt>
        <dd>
          ${ungettext("%(count)s subject", "%(count)s subjects", subject_cnt) % dict(count=subject_cnt)|n},
          ${ungettext("%(count)s group", "%(count)s groups", group_cnt) % dict(count=group_cnt)|n},
          ${ungettext("%(count)s file", "%(count)s files", file_cnt) % dict(count=file_cnt)|n}
        </dd>
      </dl>
    </li>
    %endfor
  </ul>
  %endif
  <p class="more"><a href="${url(controller='search', action='browse')}">${_('All universities')}</a></p>
</div><div id="homeActiveGroups">
  <h2>${_('Latest groups')}</h2>
  %if c.groups:
  <ul>
    %for group in c.groups:
    <%
       logo_style = ''
       if group['has_logo']:
           logo_style = 'background-image: url(%s);' % url(controller='group', action='logo', id=group['group_id'], width=20, height=20)
    %>
    <li style="${logo_style|n}">
      <dl>
        <dt><a href="${group['url']}">${group['title']}</a></dt>
        <dd>
          <%
             hierarchy = group['hierarchy']
             total_hierarchy = len(hierarchy)
          %>
          %for n, tag in enumerate(hierarchy):
            <a href="${tag['url']}" title="${tag['title']}">${tag['title_short']}</a>
            %if n != total_hierarchy - 1:
             |
            %endif
          %endfor
        </dd>
      </dl>
    </li>
    %endfor
  </ul>
  %endif
</div>
