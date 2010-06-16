<%inherit file="/ubase.mako" />

<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/portlets/anonymous.mako" import="*"/>
<%namespace file="/portlets/banners/base.mako" import="*"/>

<%def name="body_class()">anonymous_index</%def>

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
    <a href="${uni.url()}" title="${uni.title}">${h.ellipsis(uni.title, 38)}</a>
  </div>
  <div class="stats">
    <span>
        <%
           cnt = uni.count('subject')
        %>
        ${ungettext("%(count)s subject", "%(count)s subjects", cnt) % dict(count = cnt)|n}
    </span>
    <span>
        <%
           cnt = uni.count('group')
        %>
        ${ungettext("%(count)s group", "%(count)s groups", cnt) % dict(count = cnt)|n}
    </span>
    <span>
        <%
           cnt = uni.count('file')
        %>
        ${ungettext("%(count)s file", "%(count)s files", cnt) % dict(count = cnt)|n}
    </span>
  </div>
</div>
</%def>

<%def name="universities(unis, ajax_url)">
    %for uni in unis:
      ${university(uni)}
    %endfor
    <div id="pager">
      ${unis.pager(format='~3~',
                     partial_param='js',
                     onclick="$('#pager').addClass('loading'); $('#university-list').load('%s'); return false;") }
    </div>
    <div id="sorting">
      ${_('Sort by:')}
      <%
        url_args = dict(sort='alpha')
        if request.params.get('region_id'):
            url_args['region_id'] = request.params.get('region_id')
      %>
      <a id="sort-alpha" class="${c.sort == 'alpha' and 'active' or ''}" href="${url(ajax_url, **url_args)}">${_('name')}</a>
      <input type="hidden" id="sort-alpha-url" name="sort-alpha-url" value="${url(ajax_url, js=True, **url_args)}" />
      <a id="sort-popular" class="${c.sort == 'popular' and 'active' or ''}" href="${url(ajax_url, **url_args)}">${_('popularity')}</a>
      <input type="hidden" id="sort-popular-url" name="sort-popular-url" value="${url(ajax_url, js=True, **url_args)}" />
    </div>
</%def>

<%def name="universities_section(unis, ajax_url)">
  <div id="university-list" class="${c.teaser and 'collapsed_list' or ''}">
    ${universities(unis, ajax_url)}
  </div>
  %if c.teaser:
    <div id="teaser_switch" style="display: none;">
      <a href="#" class="more">${_('More universities')}</a>
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
      $('#sort-alpha,#sort-popular').live("click", function() {
        var url = $('#'+$(this).attr('id')+'-url').val();
        $('#sorting').addClass('loading');
        $('#university-list').load(url);
        return false;
      });
    });
  //]]>
  </script>
</%def>

  <h1>${_('UTUTI - student information online')}</h1>
  <div id="frontpage-search">
    ${search_form(parts=['obj_type', 'text'])}
  </div>

  ${universities_section(c.unis, url(controller='home', action='index'))}
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
          <h3>${_('What can you find here?')}</h3>
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
