<%inherit file="/base.mako" />

<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/portlets/anonymous.mako" import="*"/>
<%namespace file="/portlets/banners/base.mako" import="*"/>

<%def name="head_tags()">
${parent.head_tags()}
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
${h.stylesheet_link('/stylesheets/anonymous.css')|n}
${h.stylesheet_link('/stylesheets/pl.css')|n}
</%def>

<%def name="portlets()">
<div id="sidebar">
  ${ututi_join_portlet()}
  ${ututi_links_portlet()}
  ${ututi_banners_portlet()}
</div>
</%def>

  <h1>
    ${_('UTUTI - student information online')}
    <div class="subhead">
      ${_('A place where you can store your study materials and leave them for future generations.')}
    </div>
  </h1>

  <div id="group_create">
    <a class="btn" href="${url(controller='home', action='join')}">
      <span>${_('Create your group')}</span>
    </a>
  </div>

  <div id="ututi_main_features">
    <div class="feature icon_file">
      <h2>${_('Unlimited file size')}</h2>
      <span>${_('Store and share with your group mates without restrictions!')}</span>
    </div>
    <div class="feature icon_group">
      <h2>${_('Communicate with your group mates')}</h2>
      <span>${_('All groups have their own mailing lists.')}</span>
    </div>
    <div class="feature icon_gadugadu">
      <h2>${_('Gadu Gadu integration')}</h2>
      <span>${_('Receive notifications by email and gadu gadu!')}</span>
    </div>
  </div>

  <br class="clear-left" />
  <script type="text/javascript">
  //<![CDATA[
    $(document).ready(function() {
      $('#presentation-img a').click(function() {
        $('#ututi_features').hide();
        $('#presentation-img img').animate({
          width: '550px',
          height: '308px'
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
            <img src="${url('/images/slideshow_%(lang)s.png' % dict(lang=c.lang))}" alt="${_('About ututi')}"/>
          </a>
        </div>

        <div id="presentation-actual" class="${(not c.slideshow) and 'hidden' or ''}">
          <div style="width:550px;text-align:left" id="__ss_2549808">
            <object style="margin:0px" width="550" height="434">
              <param name="movie"
                     value="${_('presentation_url')}" />
              <param name="allowFullScreen" value="true"/>
              <param name="allowScriptAccess" value="always"/>
              <embed src="${_('presentation_url')}"
                     type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="550" height="434">
              </embed>
            </object>
          </div>
        </div>
      </div>
      <div id="ututi_features" class="${c.slideshow and 'hidden' or ''}">
        <div id="can_find">
          <h3>${_('What can You find here?')}</h3>
          ${_('Group mailing lists, <a href="%(link)s" title="Subject list">subjects</a> files and lecture notes.') %\
            dict(link=url(controller='search', action='index', obj_type='subject'))|n}
        </div>
        <div id="can_do">
          <h3>${_('What can you do here?')}</h3>
          ${_('Share <a href="%(subjects)s" title="Subject list">study materials</a>\
          create <a href="%(groups)s" title="Group list">academic groups</a>\
          and communicate with groupmates.') % dict(subjects=url(controller='search', action='index', obj_type='subject'),\
                                                    groups=url(controller='search', action='index', obj_type='group'))|n}
        </div>
      </div>
  </div>
