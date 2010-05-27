<%inherit file="/ubase-sidebar.mako" />
<%namespace name="files" file="/sections/files.mako" />
<%namespace file="/portlets/subject.mako" import="*"/>
<%namespace file="/sections/content_snippets.mako" import="*"/>
<%namespace file="/portlets/banners/base.mako" import="*"/>

<%def name="title()">
  ${c.subject.title}
</%def>

<%def name="head_tags()">
    ${parent.head_tags()}
   <%files:head_tags />
</%def>

<%def name="portlets()">
  ${subject_info_portlet()}
  ${ututi_prizes_portlet()}
</%def>

<h1 class="pageTitle">${c.subject.title}</h1>

%if c.subject.deleted:
<div id="note" style="margin-bottom: 25px; margin-top: 6px;">
  %if h.check_crowds(['moderator']):
  <div style="float: left;"><span class="message"><span>${_('Subject has been deleted, you can restore it if you want to.')}</span></span></div>
  <div style="float: left; margin-left: 6px;">
    <a class="btn" href="${c.subject.url(action='undelete')}" title="${_('Restore deleted subject')}">
      <span>${_('Restore subject')}</span>
    </a>
  </div>
  %else:
  <span class="message"><span>${_('Subject has been deleted, it will soon disappear from your watched subjects list.')}</span></span>
  %endif
  <br style="clear: left;" />
</div>
%endif

##google ads
%if c.came_from_search:
<script type="text/javascript">
  <!--
 google_ad_client = "pub-1809251984220343";
 /* 468x60, sukurta 10.2.3 */
 google_ad_slot = "3543124516";
 google_ad_width = 468;
 google_ad_height = 60;
 //-->
</script>
<script type="text/javascript"
	src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
%endif

<div class="portlet portletSmall">
			<div class="ctl"></div>
			<div class="ctr"></div>
			<div class="cbl"></div>
			<div class="cbr"></div>
            %if c.subject.description:
              ${h.html_cleanup(c.subject.description)|n,decode.utf8}
            %else:
              ${_("The subject's description is empty.")}
            %endif
			<div class="right_arrow1"><a href="${c.subject.url(action='edit')}"> ${_('Edit')}</a></div>
</div>

<%files:file_browser obj="${c.subject}", title="${_('Subject files')}" />

<div id="subject_pages" class="section">
  <h2>${_('Pages')}</h2>
  <div class="container">
    <br />
    %if c.user:
    <a class="btn" href="${url(controller='subjectpage', action='add', id=c.subject.subject_id, tags=c.subject.location_path)}">
      <span>${_('New page')}</span>
    </a>
    %endif
    % if c.subject.pages:
      % for page in c.subject.pages:
        % if not page.isDeleted() or h.check_crowds(['moderator']):
          ${page_extra(page)}
        % endif
      % endfor
    % else:
      <br />
      <span class="notice">${_('The subject has no pages yet - create one!')}</span>
    % endif
  </div>
</div>
