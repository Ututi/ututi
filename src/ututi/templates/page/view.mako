<%inherit file="/page/base.mako" />

<%def name="title()">
   ${h.ellipsis(c.page.title,30)} - ${h.ellipsis(c.subject.title, 30)}
</%def>

<a class="back-link" href="${c.subject.url()}">${_('Go back to %(subject_title)s') % dict(subject_title=c.subject.title)}</a>

<div id="page_header">
  <h1 style="float: left;">${c.page.title}</h1>
  <div style="float: left; margin-top: 8px; margin-left: 10px;"><a class="btn" href="${h.url_for(action='edit')}"><span>${_('Edit')}</span></a></div>

  % if h.check_crowds(['user']):
    <div style="float: left; margin-top: 8px; margin-left: 10px;"><a class="btn" href="${h.url_for(action='history')}"><span>${_('View history')}</span></a></div>
  % endif
  % if h.check_crowds(['moderator']):
    % if not c.page.isDeleted():
      <div style="float: left; margin-top: 8px; margin-left: 10px;"><a class="btn warning" href="${h.url_for(action='delete')}"><span>${_('Delete')}</span></a></div>
    % else:
      <div style="float: left; margin-top: 8px; margin-left: 10px;"><a class="btn" href="${h.url_for(action='undelete')}"><span>${_('Undelete')}</span></a></div>
    % endif
  % endif
</div>
<div class="clear-left small">
  ${_('Last edit:')}
  %if c.page.last_version:
    ${h.fmt_dt(c.page.last_version.created_on)}
    <a href="${c.page.last_version.created.url()}">${c.page.last_version.created.fullname}</a>
  %endif
</div>
<br />

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

<div id="page_content">
  ${h.latex_to_html(h.html_cleanup(c.page.content))|n}
</div>
