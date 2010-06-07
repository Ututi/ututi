<%inherit file="/page/base.mako" />

<%def name="title()">
   ${h.ellipsis(c.page.title, 30)} - ${h.ellipsis(c.subject.title, 30)}
</%def>

<a class="back-link" href="${h.url_for(action='history')}">${_('Go back to history')}</a>

<%self:rounded_block id="subject_description" class_='portletGroupFiles'>
	<div class="GroupFiles GroupFilesWiki">
		<div class="floatleft wiki2">
			<h2 class="portletTitle bold">${c.version.title}</h2>
            <p>
              <a  class="orange verysmall" href="${c.version.created.url()}">${c.version.created.fullname}</a>
              <span class="grey verysmall">${h.fmt_dt(c.version.created_on)}</span>
            </p>
		</div>
		<div class="floatleft wiki3">
         % if c.version is not c.page.versions[0]:
            ${h.button_to(_('Restore'), c.version.url(action='restore'))}</span></a>
         % endif

		</div>
	</div>
    <div id="page_content">
      ${h.latex_to_html(h.html_cleanup(c.version.content))|n}
    </div>
</%self:rounded_block>

<div id="old-version-note" class="clear-left small">
  % if c.version is not c.page.versions[0]:
	  ${h.literal(
		 _('You are viewing an old version of this page created'
		  ' by %(link_to_user)s on %(date)s') % dict(
				link_to_user=h.link_to(c.version.created.fullname,
									   c.version.created.url()),
				date=h.fmt_dt(c.version.created_on)))}
  % endif
</div>
<br />

