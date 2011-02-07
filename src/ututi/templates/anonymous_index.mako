<%inherit file="/ubase-nomenu.mako" />

<%def name="location_tag(uni)">
<div class="university_block">
  %if uni['has_logo']:
    <div class="logo">
      <img src="${url(controller='structure', action='logo', id=uni['id'], width=26, height=26)}" alt="logo" />
    </div>
  %elif uni['parent_has_logo']:
    <div class="logo">
      <img src="${url(controller='structure', action='logo', id=uni['parent_id'], width=26, height=26)}" alt="logo" />
    </div>
  %endif

  <div class="title">
    <a href="${uni['url']}" title="${uni['title']}">${h.ellipsis(uni['title'], 36)}</a>
  </div>
  <div class="stats">
    <span>
      ${ungettext("%(count)s subject", "%(count)s subjects", uni['n_subjects']) % dict(count=uni['n_subjects'])|n}
    </span>
    <span>
      ${ungettext("%(count)s group", "%(count)s groups", uni['n_groups']) % dict(count=uni['n_groups'])|n}
    </span>
    <span>
      ${ungettext("%(count)s file", "%(count)s files", uni['n_files']) % dict(count=uni['n_files'])|n}
    </span>
  </div>
</div>
</%def>


<%def name="universities(unis, ajax_url)">
    %for uni in unis:
      ${location_tag(uni)}
    %endfor
    <div id="pager">
      ${unis.pager(format='~3~',
                     partial_param='js',
                     onclick="$('#pager').addClass('loading'); $('#university-list').load('%s'); return false;") }
    </div>
    <div id="sorting">
      ${_('Sort by:')}
      <%
         url_args_alpha = dict(sort='alpha')
         url_args_pop = dict(sort='popular')
         if request.params.get('region_id'):
             url_args_alpha['region_id'] = request.params.get('region_id')
             url_args_pop['region_id'] = request.params.get('region_id')
      %>
      <a id="sort-alpha" class="${c.sort == 'alpha' and 'active' or ''}" href="${url(ajax_url, **url_args_alpha)}">${_('name')}</a>
      <input type="hidden" id="sort-alpha-url" name="sort-alpha-url" value="${url(ajax_url, js=True, **url_args_alpha)}" />
      <a id="sort-popular" class="${c.sort == 'popular' and 'active' or ''}" href="${url(ajax_url, **url_args_pop)}">${_('popularity')}</a>
      <input type="hidden" id="sort-popular-url" name="sort-popular-url" value="${url(ajax_url, js=True, **url_args_pop)}" />
    </div>
</%def>

<%def name="universities_section(unis, ajax_url, collapse=True, collapse_text=None)">
  <%
     if collapse_text is None:
       collapse_text = _('More universities')
  %>
  %if unis:
  <div id="university-list" class="${c.teaser and 'collapsed_list' or ''}">
    ${universities(unis, ajax_url)}
  </div>
  %if collapse and len(unis) > 6:
    %if c.teaser:
      <div id="teaser_switch" style="display: none;">
        <span class="files_more">
          <a class="green verysmall">
            ${collapse_text}
          </a>
        </span>
      </div>
    %endif
    <script type="text/javascript">
    //<![CDATA[
      $(document).ready(function() {
        $('#university-list.collapsed_list').data("preheight", $('#university-list.collapsed_list').height()).css('height', '115px');
        $('#teaser_switch').show();
        $('#teaser_switch a').click(function() {
          $('#teaser_switch').hide();
          $('#university-list').animate({
            height: $('#university-list').data("preheight")},
            200, "linear",
            function() {
              $('#university-list').css('height', 'auto');
            });
          return false;
        });
      });
    //]]>
    </script>
  %endif
  <script type="text/javascript">
  //<![CDATA[
    $(document).ready(function() {
      $('#sort-alpha,#sort-popular').live("click", function() {
        var url = $('#'+$(this).attr('id')+'-url').val();
        $('#sorting').addClass('loading');
        $('#university-list').load(url);
        return false;
      });
    });
  //]]>
  </script>
  %endif
</%def>

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
