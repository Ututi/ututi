<%inherit file="/base.mako" />

<%def name="title()">
${_('New page')}
</%def>

<a class="back-link" href="${c.subject.url()}">${_('Back to %(subject_title)s') % dict(subject_title=c.subject.title)}</a>

<h1>${_('New page')}</h1>

<form method="post" action="${h.url_for(action='create')}"
     id="page_add_form" enctype="multipart/form-data">
  ${h.input_line('page_title', _('Title'))}
  ${h.input_wysiwyg('page_content', _('Content'))}
  ${h.input_submit()}
</form>
