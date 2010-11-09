<%inherit file="/subject/base.mako" />
<%namespace file="/sections/content_snippets.mako" import="*"/>
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
<h1 class="pageTitle">${c.subject.title}</h1>

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

<% blank_subject = not c.subject.n_files(False) and not c.subject.pages %>

%if blank_subject:
  <%self:rounded_block class_='subject-intro-block' id="subject-intro-block">
    %if c.user:
      <div class="right_arrow1" style="float: right" ><a href="${c.subject.url(action='edit')}">${_('Edit')}</a></div>
    %endif
    <h2 style="margin-top: 5px">${_('What is a subject page?')}</h2>
    <p>${_('A subject page is a place for all information related to a particular course.')}</p>

    <h2>${_('Where do I start?')}</h2>
    <ul class="subject-intro-message">
      <li>
        <span class="heading">${_('Create wiki pages for a subject')}</span>
        ${_('Collecting course notes in Word? Writing things down on a computer during lectures? You can store your notes here, where they can be read and edited by your classmates.')}
        ${h.button_to(_('Create a wiki document'), url(controller='subjectpage', action='add', id=c.subject.subject_id, tags=c.subject.location_path),
                  method='GET')}
      </li>
      <li>
      <span class="heading">${_('Upload course files')}</span>
        ${_('You may upload course notes, sample tasks and solutions, coursework examples. You can also upload <strong>very</strong> large files (do not abuse this feature though, the moderators will promptly delete any inappropriate material).')|n}
      </li>

      <div style="margin-left: 43px">
        ${h.button_to(_('Upload files'), "", id='upload-files-button')}
      </div>

      ##<%files:file_browser obj="${c.subject}", title="${_('Subject files')}", controls="['upload', 'folder']" />

    </ul>
  </%self:rounded_block>
%endif

%if c.subject.description:
  <%self:rounded_block id="subject_description">
    <div class="content">
      ${h.html_cleanup(c.subject.description)}
    </div>
    %if c.user:
      <div class="right_arrow1"><a href="${c.subject.url(action='edit')}">${_('Edit')}</a></div>
    %endif
  </%self:rounded_block>
%elif not blank_subject:

  <%self:rounded_block class_='subject-intro-block' id="subject-intro-block">
    %if c.user:
      <div class="right_arrow1" style="float: right" ><a href="${c.subject.url(action='edit')}">${_('Edit')}</a></div>
    %endif
    <h2 style="margin-top: 5px">${_('What is a subject page?')}</h2>
    <p>${_('A subject page is a place for all information related to a particular course.')}</p>

    <h2 style="margin-bottom: 5px">${_('Where do I start?')}</h2>
    <ul class="subject-intro-message" style="margin-top: 5px">
      <li>
        <span class="heading">${_('Enter a subject description,')}</span>
        ${_('so that others would find their way around more easily.')}
        ${h.button_to(_('Create a subject description'), c.subject.url(action='edit'))}
      </li>

    </ul>
  </%self:rounded_block>

%endif


<div id="subject-tabs" ${"style='display: none'" if blank_subject  else ''}>
 ${tabs()}
</div>
 ${next.body()}
