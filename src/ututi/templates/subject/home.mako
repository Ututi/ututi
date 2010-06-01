<%inherit file="/subject/base.mako" />
<%namespace file="/sections/content_snippets.mako" import="*"/>
<%namespace name="files" file="/sections/files.mako" />

<%def name="head_tags()">
    ${parent.head_tags()}
   <%files:head_tags />
</%def>

<%def name="title()">
${c.subject.title}
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

<%self:rounded_block id="subject_description">
   %if c.subject.description:
   <div class="content">
	 ${h.html_cleanup(c.subject.description)|n,decode.utf8}
   </div>
   %else:
	 ${_("The subject's description is empty.")}
   %endif
   <div class="right_arrow1"><a href="${c.subject.url(action='edit')}"> ${_('Edit')}</a></div>
</%self:rounded_block>

<%self:rounded_block class_='portletGroupFiles' id="subject_files">
<div class="GroupFiles">
  <h2 class="portletTitle bold">${_('Subject files')} (${c.subject.file_count})</h2>
</div>
<%files:file_browser obj="${c.subject}", title="${_('Subject files')}", controls="['upload', 'folder']" />
</%self:rounded_block>

<%self:rounded_block class_='portletGroupFiles' id="subject_pages">
<div class="GroupFiles GroupFilesWiki">
  <%
     count = len([page for page in c.subject.pages if not page.isDeleted()])
  %>
  <h2 class="portletTitle bold">${_("Subject's Wiki Pages")} (${count})</h2>
  <span class="group-but">
      ${h.button_to(_('Create a wiki document'), url(controller='subjectpage', action='add', id=c.subject.subject_id, tags=c.subject.location_path),
                method='GET')}
  </span>
</div>
% if c.subject.pages:
  % for n, page in enumerate(c.subject.pages):
	% if not page.isDeleted() or h.check_crowds(['moderator']):
     <%
        class_ = 'wiki-tekstas' if n < count - 1 else 'wiki-tekstas-last'
     %>
     <div class="${class_}">
       <p><span class="orange bold"><a href="${page.url()}" title="${page.title}">${page.title}</a></span>
         <span class="grey verysmall"> ${h.fmt_dt(page.last_version.created_on)} </span>
         <span class="orange verysmall"><a href="${page.last_version.created.url()}">${page.last_version.created.fullname}</a></span>
       </p>
       <p>
         ${h.ellipsis(page.last_version.plain_text, 250)}
       </p>
     </div>
	% endif
  % endfor
% else:
  <br />
  <span class="notice">${_('The subject has no pages yet - create one!')}</span>
% endif
</%self:rounded_block>
