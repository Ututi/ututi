<%inherit file="/base.mako" />

<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/portlets/anonymous.mako" import="*"/>
<%namespace file="/portlets/banners/base.mako" import="*"/>

<%def name="head_tags()">
${parent.head_tags()}
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
${h.stylesheet_link('/stylesheets/anonymous.css')|n}
</%def>

<%def name="portlets()">
<div id="sidebar">
  ${ututi_join_portlet()}
  ${ututi_links_portlet()}
  ${ututi_banners_portlet()}
</div>
</%def>

<%def name="university(uni)">
<div class="university_block">
  %if uni.logo is not None:
  <div class="logo">
    <img src="${url(controller='structure', action='logo', id=uni.id, width=26, height=26)}" alt="logo" />
  </div>
  %endif
  <div class="title">
    <a href="${uni.url()}" title="${uni.title}">${uni.title}</a>
  </div>
  <div class="stats">
    <span>
        <%
           cnt = uni.count('subject')
        %>
        ${ungettext("%(count)s <em>subject</em>", "%(count)s <em>subjects</em>", cnt) % dict(count = cnt)|n}
    </span>
    <span>
        <%
           cnt = uni.count('group')
        %>
        ${ungettext("%(count)s <em>group</em>", "%(count)s <em>groups</em>", cnt) % dict(count = cnt)|n}
    </span>
    <span>
        <%
           cnt = uni.count('file')
        %>
        ${ungettext("%(count)s <em>file</em>", "%(count)s <em>files</em>", cnt) % dict(count = cnt)|n}
    </span>
  </div>
</div>
</%def>

<%def name="universities(unis)">
    %for uni in unis:
      ${university(uni)}
    %endfor
    <div id="pager">
      ${unis.pager(format='~3~',
                     partial_param='js',
                     onclick="$('#pager').addClass('loading'); $('#university-list').load('%s'); return false;") }
    </div>
    <div id="sorting">
      ${_('Sort  by: ')}
      <a id="sort-alpha" class="${c.sort == 'alpha' and 'active' or ''}" href="${url(controller='home', action='index', sort='alpha')}">${'alphabetically'}</a>
      <input type="hidden" id="sort-alpha-url" name="sort-alpha-url" value="${url(controller='home', action='index', sort='alpha', js=True)}" />
      <a id="sort-popular" class="${c.sort == 'popular' and 'active' or ''}" href="${url(controller='home', action='index', sort='popular')}">${'by popularity'}</a>
      <input type="hidden" id="sort-popular-url" name="sort-popular-url" value="${url(controller='home', action='index', sort='popular', js=True)}" />
    </div>
</%def>

  <h1>${_('UTUTI - student information online')}</h1>
  <div id="frontpage-search">
    ${search_form(parts=['obj_type', 'text'])}
  </div>

  <div id="university-list" class="${c.teaser and 'collapsed_list' or ''}">
    ${universities(c.unis)}
  </div>
  %if c.teaser:
    <div id="teaser_switch" style="display: none;">
      <a href="#" class="more">${_('More universities')}</a>
    </div>
  %endif
  <script type="text/javascript">
  //<![CDATA[
    $(document).ready(function() {
      $('#university-list.collapsed_list').data("preheight", $('#university-list.collapsed_list').height()).css('height', '100px');
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
      $('#sort-alpha,#sort-popular').live("click", function() {
        var url = $('#'+$(this).attr('id')+'-url').val();
        console.log('#'+$(this).attr('id')+'-url');
        console.log(url);
        $('#sorting').addClass('loading');
        $('#university-list').load(url);
        return false;
      });

    });
  //]]>
  </script>

  <br class="clear-left" />
  <script type="text/javascript">
  //<![CDATA[
    $(document).ready(function() {
      $('#presentation-img a').click(function() {
        $('#ututi_features').hide();
        $('#presentation-img img').animate({
          width: '570px',
          height: '325px'
        },
        700,
        'linear',
        function() {
          $(this).hide();
          $('#presentation-actual').show();
        });
        return false;
      });
    });
  //]]>
  </script>
  <div id="infoblock">
      <div id="presentation">
        <div id="presentation-img" class="${c.slideshow and 'hidden' or ''}">
          <a href="${url(controller='home', action='index', slide='show')}">
            <img src="${url('/images/slideshow_lt.png')}" alt="${_('About ututi')}"/>
          </a>
        </div>
        <div id="presentation-actual" class="${(not c.slideshow) and 'hidden' or ''}">
          <object id='stV09QR0JIR1xZQVhbWltYU1NQ'
                  width='570'
                  height='325'
                  type='application/x-shockwave-flash'
                  data='http://www.screentoaster.com/swf/STPlayer.swf'
                  codebase='http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,115,0'>
            <param name='movie' value='http://www.screentoaster.com/swf/STPlayer.swf'/>
            <param name='allowFullScreen' value='true'/>
            <param name='allowScriptAccess' value='always'/>
            <param name='flashvars' value='video=stV09QR0JIR1xZQVhbWltYU1NQ'/>
          </object>
        </div>
      </div>
      <div id="ututi_features" class="${c.slideshow and 'hidden' or ''}">
        <div id="can_find">
          <h3>${_('What can You find here?')}</h3>
          ${_('Group mailing lists, <a href="%(link)s" title="Subject list">subject</a> wikis, files, lecture notes and answers to questions that matter for your studies.') %\
            dict(link=url(controller='search', action='index', obj_type='subject'))|n}
        </div>
        <div id="can_do">
          <h3>${_('What can you do here?')}</h3>
          ${_('Store <a href="%(subjects)s" title="Subject list">study materials</a>\
          and pass them on for future generations, create\
          <a href="%(groups)s" title="Group list">academic groups</a>\
          and communicate with groupmates.') % dict(subjects=url(controller='search', action='index', obj_type='subject'),\
                                                    groups=url(controller='search', action='index', obj_type='group'))|n}
        </div>
      </div>
  </div>
