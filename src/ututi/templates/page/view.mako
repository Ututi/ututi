<%inherit file="/page/base.mako" />

<%def name="title()">
   ${h.ellipsis(c.page.title,30)} - ${h.ellipsis(c.subject.title, 30)}
</%def>

<a class="back-link" href="${c.subject.url()}">${_('Go back to %(subject_title)s') % dict(subject_title=c.subject.title)}</a>

<%self:rounded_block id="subject_description" class_='portletGroupFiles'>
    <div class="GroupFiles GroupWiki">
        <div class="floatleft wiki2">
            <h2 class="portletTitle bold">${c.page.title}</h2>
            %if c.page.last_version:
              <p><span class="grey verysmall">${_('Last edit: ')}
              <a class="orange verysmall" href="${c.page.last_version.created.url()}">${c.page.last_version.created.fullname}</a>
              <span class="grey verysmall">${h.fmt_dt(c.page.last_version.created_on)}</span>
            %endif
        </div>
        <div class="floatleft wiki3">
          ${h.button_to(_('edit'), c.page.url(action='edit'), method='GET')}
          %if h.check_crowds(['user']):
            ${h.button_to(_('history'), c.page.url(action='history'), method='GET')}
          %endif
          %if h.check_crowds(['moderator']):
            %if not c.page.isDeleted():
              ${h.button_to(_('delete'), c.page.url(action='delete'))}
            %else:
              ${h.button_to(_('undelete'), c.page.url(action='undelete'))}
            %endif
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
