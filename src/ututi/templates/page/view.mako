<%inherit file="/page/base.mako" />

<%def name="title()">${h.ellipsis(c.page.title,30)} - ${h.ellipsis(c.subject.title, 30)}</%def>

<div class="back-link">
  <a class="back-link" href="${c.subject.url(action="pages")}">${_('Go back to %(subject_title)s notes') % dict(subject_title=c.subject.title)}</a>
</div>

<div class="notes-header">
  %if h.check_crowds(['user']):
  <div class="floatright controls edit">
    <a href="${c.page.url(action='edit')}">${_('edit')}</a>
  </div>
  <div class="floatright controls history">
    <a href="${c.page.url(action='history')}">${_('history')}</a>
  </div>
  %endif
  %if h.check_crowds(['moderator']):
     %if not c.page.isDeleted():
     <div class="floatright wiki3 controls delete">
       <a href="${c.page.url(action='delete')}">${_('delete')}</a>
     </div>
     %else:
     <div class="floatright wiki3">
       ${h.button_to(_('undelete'), c.page.url(action='undelete'))}
     </div>
     %endif
  %endif
  <div class="note">
    <h2 class="page-title">${c.page.title}</h2>
    <% last_version = c.page.last_version %>
    %if last_version:
    <p><span class="grey verysmall">${_('Last edit: ')}
        <a class="verysmall" href="${last_version.created.url()}">${last_version.created.fullname}</a>
        <span class="grey verysmall">${h.fmt_dt(last_version.created_on)}</span>
        %endif
  </div>
</div>
<div id="note-content" class="wiki-page">
  ${h.latex_to_html(h.html_cleanup(c.page.content))}
</div>

##%if c.came_from_search:
##  <script type="text/javascript">
##    <!--
##       google_ad_client = "pub-1809251984220343";
##       /* 468x60, sukurta 10.2.3 */
##       google_ad_slot = "3543124516";
##       google_ad_width = 468;
##       google_ad_height = 60;
##       //-->
##  </script>
##  <script type="text/javascript"
##          src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
##  </script>
##%endif
