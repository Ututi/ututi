<%inherit file="/page/view.mako" />

<%def name="title()">
${_('Edit page')}
</%def>
<a class="back-link" href="${c.page.url()}">${_('Back to %(page_title)s') % dict(page_title=c.page.title)}</a>
<h1>${_('Edit page')}</h1>

<form method="post" action="${h.url_for(action='update')}"
     id="page_add_form" enctype="multipart/form-data">
  ${h.input_line('page_title', _('Title'))}
  ${h.input_wysiwyg('page_content', _('Content'))}
  ${h.input_submit()}
</form>
