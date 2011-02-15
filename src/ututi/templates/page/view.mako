<%inherit file="/page/base.mako" />

%if getattr(c, 'subject', None):
        <%def name="title()">${h.ellipsis(c.page.title,30)} - ${h.ellipsis(c.subject.title, 30)}</%def>
%else:
        <%def name="title()">${h.ellipsis(c.page.title,30)}</%def>
        %if show_title:
          <h1 class="pageTitle">
            ${self.title()}
            %if not c.group.is_member(c.user):
              <div style="float: right;">
                ${h.button_to(_('become a member'), url(controller='group', action='request_join', id=c.group.group_id))}
              </div>
            %endif
          </h1>
        %endif

        %if c.group.is_member(c.user) or c.security_context and h.check_crowds(['admin', 'moderator']):
        <ul class="moduleMenu" id="moduleMenu">
            %for menu_item in c.group_menu_items:
              <li class="${'current' if menu_item['name'] == getattr(c, 'group_menu_current_item', None) else ''}">
                <a href="${menu_item['link']}">${menu_item['title']}
                    <span class="edge"></span>
                </a></li>
            %endfor
        </ul>
        %endif
%endif


<%self:rounded_block class_='portletGroupFiles smallTopMargin'>
  <div class="GroupFiles GroupWiki" style="height: auto; position: auto; padding-bottom: 10px">
        <div class="floatright wiki3">
          %if getattr(c, 'subject', None):
          ${h.button_to(_('edit'), c.page.url(action='edit'), method='GET')}
          %else:
          ${h.button_to(_('edit'), c.page.url('grouppage', action='edit'), method='GET')}
          %endif
        </div>
        %if h.check_crowds(['user']):
          <div class="floatright wiki3">
          %if getattr(c, 'subject', None):
            ${h.button_to(_('history'), c.page.url(action='history'), method='GET')}
          %else:
            ${h.button_to(_('history'), c.page.url('grouppage', action='history'), method='GET')}
          %endif
          </div>
        %endif
        %if h.check_crowds(['moderator']):
          %if not c.page.isDeleted():
          <div class="floatright wiki3">
            %if getattr(c, 'subject', None):
              ${h.button_to(_('delete'), c.page.url(action='delete'))}
            %else:
              ${h.button_to(_('delete'), c.page.url('grouppage', action='delete'))}
            %endif
          </div>
          %else:
          <div class="floatright wiki3">
            %if getattr(c, 'subject', None):
              ${h.button_to(_('undelete'), c.page.url(action='undelete'))}
            %endif
          </div>
          %endif
        %endif
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
    <div id="page_content" class="wiki-page">
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
