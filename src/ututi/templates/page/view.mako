<%inherit file="/page/base.mako" />

<%def name="title()">${h.ellipsis(c.page.title,30)} - ${h.ellipsis(c.subject.title, 30)}</%def>

<div class="back-link">
  <a class="back-link" href="${c.subject.url()}">${_('Go back to %(subject_title)s') % dict(subject_title=c.subject.title)}</a>
</div>

<%self:rounded_block class_='portletGroupFiles smallTopMargin'>
  <div class="GroupFiles GroupWiki" style="height: auto; position: auto; padding-bottom: 10px">
        <div class="floatright wiki3">
          ${h.button_to(_('edit'), c.page.url(action='edit'), method='GET')}
        </div>
        %if h.check_crowds(['user']):
          <div class="floatright wiki3">
            ${h.button_to(_('history'), c.page.url(action='history'), method='GET')}
          </div>
        %endif
        %if h.check_crowds(['moderator']):
          %if not c.page.isDeleted():
          <div class="floatright wiki3">
            ${h.button_to(_('delete'), c.page.url(action='delete'))}
          </div>
          %else:
          <div class="floatright wiki3">
            ${h.button_to(_('undelete'), c.page.url(action='undelete'))}
          </div>
          %endif
        %endif
        <div style="float: right; margin-top: 11px">
          <fb:like width="90" layout="button_count" show_faces="false" url="${c.page.url(qualified=True)}"></fb:like>
        </div>
        <div class="wiki2">
          <h2 class="portletTitle bold" style="padding-top: 3px; padding-left: 50px">${c.page.title}</h2>
          <% last_version = c.page.last_version %>
          %if last_version:
            <p><span class="grey verysmall">${_('Last edit: ')}
            <a class="orange verysmall" href="${last_version.created.url()}">${last_version.created.fullname}</a>
            <span class="grey verysmall">${h.fmt_dt(last_version.created_on)}</span>
          %endif
        </div>
    </div>
    <div id="page_content">
      ${h.latex_to_html(h.html_cleanup(c.page.content))}
    </div>
</%self:rounded_block>

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
