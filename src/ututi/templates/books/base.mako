<%inherit file="/prebase.mako" />
<%namespace file="/portlets/user.mako" import="*"/>
<%namespace file="/portlets/banners/base.mako" import="*"/>
<%namespace file="/portlets/books.mako" import="*"/>

<%def name="head_tags()">
${h.stylesheet_link(h.path_with_hash('/books.css'))}
</%def>

<%def name="anonymous_header()">
${self.anonymous_menu()}
</%def>

<%def name="portlets()">
${books_menu()}
</%def>

<%def name="main_menu()">
<p class="a11y">${_('Main menu')}</p>
<div class="head-nav">
  <ul>
    <li><a href="${url(controller='books', action='index')}">${_('Home')}</a></li>
    <li><a href="${url(controller='books', action='about')}">${_('About U-Books')}</a></li>
    <li><a class="orange" href="${url(controller='books', action='add')}">${_('Upload a Book')}</a></li>
  </ul>
</div>
</%def>

<%def name="anonymous_menu()">
${local.main_menu()}
<p class="a11y">${_('Login')}</p>
<div class="loggedin-nav">
    <ul>
      <li>
        <a href="${url(controller='home', action='login', context_type='books_login', came_from=url.current())}">
          ${_('Login')}
        </a>
      </li>
      <li>
        <a href="${url(controller='home', action='login', context_type='books_register', came_from=url.current())}">
          ${_('Register')}
        </a>
      </li>
    </ul>
</div>
</%def>

<%def name="loggedin_menu()">
${local.main_menu()}
<div class="loggedin-nav" id="personal-data">
    <ul>
      <li>${h.link_to(_("My books"), url(controller="books", action="my_books"))}</li>
      <li class="expandable profile-nav">
        <span class="fullname">${c.user.fullname}</span>
        <div>
          <ul>
            <li class="action"><a href="${url(controller='profile', action='edit')}">${_('Settings')}</a></li>
            <li class="action"><a href="${url(controller='user', action='index', id=c.user.id)}">${_('Public profile')}</a></li>
          </ul>
        </div>
      </li>
      <li><a href="${url(controller='home', action='logout')}">${_('log out')}</a></li>
    </ul>
</div>
<script type="text/javascript">
  // nav ul li expandable
    $('ul li.expandable').toggle(function() {
    $(this).addClass('expanded').find('div:last-child ul').show();
    }, function(){
        $(this).removeClass('expanded').find('div:last-child ul').hide();
    }).click(function(){ // remove selection
        if(document.selection && document.selection.empty) {
            document.selection.empty() ;
        } else if(window.getSelection) {
            var s = window.getSelection();
            if(s && s.removeAllRanges)
                s.removeAllRanges();
        }
    }).find('li a').click(function(ev){
        ev.preventDefault();
        window.location.href = $(this).attr('href');
    });
</script>

</%def>

<%def name="loggedin_header()">
  ${self.loggedin_menu()}
</%def>

<div id ="books-container">
<div id="aside">
  ${self.portlets()}
</div>
<div id="mainContent">
  ${self.flash_messages()}
  ${next.body()}
</div>
</div>

