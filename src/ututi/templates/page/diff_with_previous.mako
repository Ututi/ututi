<%inherit file="/page/base.mako" />

<%def name="title()">
   ${h.ellipsis(c.page.title,30)} - ${h.ellipsis(c.subject.title, 30)}
</%def>

<a class="back-link" href="${h.url_for(action='history')}">${_('Go back to history')}</a>

<%self:rounded_block id="subject_description" class_='portletGroupFiles'>
	<div class="GroupFiles GroupFilesWiki">
		<div class="floatleft wiki2">
			<h2 class="portletTitle bold">${c.page.title}</h2>
            <p>
              <a  class="orange verysmall" href="${c.version.created.url()}">${c.version.created.fullname}</a>
              <span class="grey verysmall">${h.fmt_dt(c.version.created_on)}</span>
            </p>
		</div>
		<div class="floatleft wiki3">
          ${h.button_to(_('Restore previous'), c.prev_version.url(action='restore'))}</span></a>
		</div>
	</div>
    <div id="page_content" class="wiki-page">
      ${c.diff}
    </div>
</%self:rounded_block>
