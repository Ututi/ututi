<%inherit file="/search/base.mako" />
<%namespace file="/portlets/facebook.mako" import="*"/>
<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/frontpage.mako" import="unis_listing"/>

<h1 class="page-title">${_('Universities')}</h1>

${_('Sort by')}: <a id="sort-alpha" class="sorting" href="/browse?sort=alpha">${_('Alphabet')}</a> | <a id="sort-popular" class="sorting active" href="/browse?sort=popular">${_('Popularity')}</a>

<input type="hidden" id="sort-alpha-url" name="sort-alpha-url" value="/browse?sort=alpha&amp;js=True" />
<input type="hidden" id="sort-popular-url" name="sort-popular-url" value="/browse?sort=popular&amp;js=True" />
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
  <div class="clear university-box">
  %for uni in unis:
    ${unis_listing(uni)}
  %endfor
  </div>
  <div id="pager">
    ${unis.pager(format='~3~',
                 partial_param='js',
                 onclick="$('#pager').addClass('loading'); $('#university-list').load('%s'); return false;") }
  </div>
</%def>

<%def name="universities_section(unis, ajax_url, collapse=True, collapse_text=None)">
  <%
     if collapse_text is None:
       collapse_text = _('More universities')
  %>
  %if unis:
  <div id="university-list" class="${c.teaser and 'collapsed_list' or ''} clear">
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
            $('.sorting').removeClass('active');
            $(this).addClass('active');
            $('#sorting').addClass('loading');
            $('#university-list').load(url);
            return false;
        });
      });
  //]]>
  </script>
  %endif
</%def>

<%def name="head_tags()">
  ${h.javascript_link('/javascript/jquery.maphilight.js')}

  <script type="text/javascript">
    $(document).ready(function() {
        $('img#region-map').maphilight({
            strokeColor: 'd45500',
            strokeWidth: 4,
            fillColor: 'd45500',
            fillOpacity: 0.4
        });
    });
  </script>
</%def>

<%def name="portlets()">
  ${facebook_likebox_portlet()}
</%def>

${search_form(c.text, c.obj_type, c.tags, parts=['text'], target=url(controller='search', action='index'))}

${universities_section(c.unis, url(controller='profile', action='browse'))}
<br class="clear-left" />
