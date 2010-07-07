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
          <p>
            <span class="verysmall grey bold">${_('Lecturer:')}</span>
            <span class="orange verysmall">${subject.lecturer}</span>
          </p>
        %endif
    </div>
    <div class="dalyko-info">
      <p>
        <span class="verysmall grey bold">${_('Subject rating:')} </span>
        <span>${h.image('/images/details/stars%d.png' % subject.rating(), alt='', class_='subject_rating')|n}</span>
      </p>
      <p><span class="verysmall grey bold">${_('The subject is watched by:')}</span>
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
    <div style="padding-top: 5px; padding-bottom: 5px">
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

<%def name="subject_similar_subjects_portlet(subject=None)">
  <%
     if subject is None:
         subject = c.subject
  %>
  %if c.similar_subjects:
  <%self:uportlet id="similar_subjects_portlet">
    <%def name="header()">
      ${_('Similar subjects')}
    </%def>
      <ul class="Dalykail">
        <%
           count_subjects = len(c.similar_subjects)
        %>
        %for index, item in enumerate(c.similar_subjects):
		<li${index==count_subjects-1 and " class='Dalykail-last'" or ''}>
		  <dl>
            <%
               subject = item.object
               location = subject.location.hierarchy(True)
               length = len(location)
            %>

			<dt><a href="${item.object.url()}">${subject.title}</a></dt>
            %for n, tag in enumerate(location):
              <dd class="s-line"><a class="uni" href="${tag.url()}" title="${tag.title}">${tag.title_short}</a></dd>
              %if n != length -1:
                <dd class="s-line">|</dd>
              %endif
            %endfor
            %if subject.lecturer:
			  <dd class="s-line">${_('Lect.')} ${subject.lecturer}</dd>
            %endif
			<dt></dt>
            <%
                file_cnt = len(subject.files)
                page_cnt = len(subject.pages)
                group_cnt = subject.group_count()
                user_cnt = subject.user_count()
             %>
            <dd class="files">${ungettext('%(count)s <span class="a11y">file</span>', '%(count)s <span class="a11y">files</span>', file_cnt) % dict(count = file_cnt)|n}</dd>
            <dd class="pages">${ungettext('%(count)s <span class="a11y">wiki page</span>', '%(count)s <span class="a11y">wiki pages</span>', page_cnt) % dict(count = page_cnt)|n}</dd>
            <dd class="watchedBy"><span class="a11y">${_('Watched by:')}</span>
              ${ungettext("%(count)s group", "%(count)s groups", group_cnt) % dict(count = group_cnt)|n}
              ${_('and')}
              ${ungettext("%(count)s member", "%(count)s members", user_cnt) % dict(count = user_cnt)|n}
            </dd>
		  </dl>
		</li>
        %endfor
	  </ul>
  </%self:uportlet>
  %endif
</%def>
