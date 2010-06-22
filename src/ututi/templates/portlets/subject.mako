<%inherit file="/portlets/base.mako"/>
<%namespace file="/sections/content_snippets.mako" import="*"/>

<%def name="subject_info_portlet(subject=None)">
  <%
     if subject is None:
         subject = c.subject
  %>

  <%self:uportlet id="subject_info_portlet" portlet_class="first">
    <%def name="header()">
      ${_('Subject information')}
    </%def>
    <div class="dalyko-info">
        <h2 class="group-name">${subject.title}</h2>	
    </div>
    <div class="dalyko-info">
        <p>
          <%
             hierarchy_len = len(subject.location.hierarchy())
          %>
          <span class="green">
          %for index, tag in enumerate(subject.location.hierarchy(True)):
            <a class="green" href="${tag.url()}">${tag.title_short}</a>
            %if index != hierarchy_len - 1:
              |
            %endif
          %endfor
          </span>
        </p>
        %if subject.lecturer:
		<p><span class="green verysmall">${_('Lecturer:')}</span><span class="orange verysmall">${subject.lecturer}</span></p>
        %endif
    </div>
    <div class="dalyko-info">
        <p><span class="verysmall">${_('Subject rating:')} </span><span>${h.image('/images/details/stars%d.png' % subject.rating(), alt='', class_='subject_rating')|n}</span></p>
        <p><span class="verysmall">${_('The subject is watched by:')}</span>
          <span class="verysmall">
            ${ungettext("<span class='orange'>%(count)s</span> user", "<span class='orange'>%(count)s</span> users", subject.user_count()) % dict(count = subject.user_count())|n},
            ${ungettext("<span class='orange'>%(count)s</span> group", "<span class='orange'>%(count)s</span> groups", subject.group_count()) % dict(count = subject.group_count())|n}
          </span>
        </p>
    </div>
    <div class="dalyko-info">
        <div class="item-tags">
        % if subject.tags:
          %for tag in subject.tags:
            <a class="grey" href="${tag.url()}">${tag.title}</a>
          %endfor
	% else:
          ${_('There are no subject tags.')}
        % endif
        </div>
    </div>
    %if c.user is not None:
    <%
       cls = 'btn'
       text = _('Add to my subjects')
       if c.user.watches(subject):
           cls = 'btn btnNegative'
           text = _('Remove from my subjects')

    %>
    <div>
      ${h.button_to(text, subject.url(action='watch'), class_=cls, method='GET')}
    </div>
    <div class="right_arrow"><a href="${url(controller='subject', action='edit', id=subject.subject_id, tags=c.subject.location_path)}">${_('edit subject information')}</a></div>
    %endif
  </%self:uportlet>

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
