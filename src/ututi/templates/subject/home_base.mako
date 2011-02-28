<%inherit file="/subject/base.mako" />
<%namespace name="files" file="/sections/files.mako" />
<%namespace file="/location/base_university.mako" import="*"/>

<%def name="head_tags()">
    ${parent.head_tags()}
   <%files:head_tags />

   <meta property="og:title" content="${c.subject.title}"/>
   <meta property="og:url" content="${c.subject.url(qualified=True)}"/>
   ## Need an HTML stripper here for this to work properly.
   ##<meta property="og:description" content="${c.subject.description}|h.html_cleanup"/>
</%def>

<%def name="title()">${c.subject.title}</%def>

<div style="float: right; margin-top: 10px;">
  <fb:like width="90" layout="button_count" show_faces="false" url="${c.subject.url(qualified=True)}"></fb:like>
</div>

<h1 class="page-title">${c.subject.title}</h1>

%if c.subject.deleted:
<div id="note" style="margin-bottom: 25px; margin-top: 6px;">
  %if h.check_crowds(['moderator']):
  <div style="float: left;"><span class="message"><span>${_('Subject has been deleted, you can restore it if you want to.')}</span></span></div>
  <div style="float: left; margin-left: 6px;">
    ${h.button_to(_('Restore subject'), c.subject.url(action='undelete'))}
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

${next.body()}
