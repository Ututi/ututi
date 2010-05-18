<%inherit file="/base.mako" />

<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/portlets/anonymous.mako" import="*"/>

<%def name="head_tags()">
${parent.head_tags()}
<meta name="robots" content="noindex, nofollow" />
</%def>

<%def name="body_class()">anonymous_index</%def>

<%def name="portlets()">
<div id="sidebar">
  ${ututi_join_portlet()}
</div>
</%def>


<h1>${c.header}</h1>

<div id="login_message" class="${c.message_class or 'permission-denied'}">
${c.message|n}
%if c.final_msg:
<p>
  ${c.final_msg|n}
</p>
%endif
</div>

%if c.show_login:
  <hr style="border: 0; border-top: 1px solid #ded8d8;"/>
  <div id="login-page-form">
    <form method="post" id="page_login_form" action="${url('/login')}">
      <input type="hidden" name="came_from" value="${request.params.get('came_from', request.url)}" />
      % if request.params.get('login'):
      <div class="error">${_('Wrong password or username!')}</div>
      % endif
      <div class="form-field overlay">
        <label for="login_page" class="small">${_('Email')}</label>
        <div class="input-line"><div>
            <input type="text" size="20" id="login_page" name="login" class="small line" value="${request.params.get('login')}" />
        </div></div>
      </div>
      <br style="clear: left; height: 0; margin: 0; padding: 0;"/>
      <div class="form-field overlay">
        <label for="password_page" class="small">${_('Password')}</label>
        <div class="input-line"><div>
            <input type="password" size="20" name="password" id="password_page" class="small line"/>
        </div></div>
      </div>
      <br style="clear: left; height: 0; margin: 0; padding: 0;"/>
      <div class="form-field">
        <span class="btn" style="float: right;"><input class="submit small" type="submit" name="join" value="Login" /></span>
      </div>
      <br style="clear: left; height: 0; margin: 0; padding: 0;"/>
      <div class="form-field">
        <a class="small-link small" href="${url(controller='home', action='pswrecovery')}" rel="nofollow">${_('forgotten password?')}</a>
      </div>
    </form>
    <script type="text/javascript">
      $("#login-page-form .overlay label").labelOver('over');
    </script>
  </div>
%else:
  <h3 class="underline">${_('Why should I join?')}</h3>
  <div id="ututi_features">
    <div id="can_find">
      <h3>${_('What can You find here?')}</h3>
      ${_('Group <em>forums</em>, subject <em>wikis</em>, <em>files</em>, lecture notes and <em>answers</em> to \
      questions that matter for your studies.')|n}
    </div>
    <div id="can_do">
      <h3>${_('What can you do here?')}</h3>
      ${_('Store <em>study materials</em> and pass them on for future generations, create <em>academic groups</em> \
      and communicate with groupmates.')|n}
    </div>
  </div>
%endif
