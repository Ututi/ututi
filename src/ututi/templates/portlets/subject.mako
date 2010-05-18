<%inherit file="/portlets/base.mako"/>
<%namespace file="/sections/content_snippets.mako" import="*"/>

<%def name="subject_info_portlet(subject=None)">
  <%
     if subject is None:
         subject = c.subject
  %>

  <%self:portlet id="subject_info_portlet">
    <%def name="header()">
      ${_('Subject information')}
    </%def>
    <div class="structured_info">
      <h4>${subject.title}</h4>
      <div class="small">
        ${_('Lecturer')}: ${subject.lecturer}
      </div>
      <div class="border-top">
        <span class="small">${_('Subject rating:')} ${h.image('/images/details/stars%d.png' % subject.rating(), alt='', class_='subject_rating')|n}</span>
        <br/>
        <span class="small">${h.image('/images/details/eye_open.png', alt='')|n}
          ${ungettext("<em>%(count)s</em> user", "<em>%(count)s</em> users", subject.user_count()) % dict(count = subject.user_count())|n},
          ${ungettext("<em>%(count)s</em> group", "<em>%(count)s</em> groups", subject.group_count()) % dict(count = subject.group_count())|n}
        </span>
      </div>
      % if subject.tags:
      <div class="item-tags border-top">
        %for tag in subject.tags:
          ${tag_link(tag)}
        %endfor
      </div>
      % endif
    </div>
    <br />
    %if c.user:
    <div class="footer">
      <a id="subject_edit_link"
         class="more"
         href="${url(controller='subject', action='edit', id=subject.subject_id, tags=c.subject.location_path)}">${_('Edit')}</a>

      <%
         cls = ''
         text = _('Watch subject')
         if c.user.watches(subject):
             cls = 'inactive'
             text = _('Stop watching the subject')

      %>
      <span>
        <a class="btn ${cls}" href="${url(controller='subject', action='watch', id=subject.subject_id, tags=subject.location_path)}">
          <span>${text}</span>
        </a>
        ${h.image('/images/details/icon_question.png',
            alt=_('By watching a subject, you will be informed about all the changes in it.'),
            class_='tooltip')|n}
      </span>
      <br />
      %if h.check_crowds(['moderator']) and not c.subject.deleted:
      <a class="btn warning" href="${c.subject.url(action='delete')}" title="${_('Delete subject')}">
        <span>${_('Delete')}</span>
      </a>
      %endif
    </div>
    %endif
  </%self:portlet>

%if c.user is None:
<script type="text/javascript"><!--
google_ad_client = "pub-1809251984220343";
/* Šoninis blokelis (300x250) */
google_ad_slot = "6884411140";
google_ad_width = 300;
google_ad_height = 250;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
%endif

</%def>
