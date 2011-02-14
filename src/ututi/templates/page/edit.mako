<%inherit file="/page/base.mako" />

<%def name="head_tags()">
${parent.head_tags()}
${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
</%def>

<%def name="title()">
${_('Edit page')}
</%def>
%if getattr(c, 'subject', None):
<a class="back-link" href="${c.page.url()}">
%else:
<a class="back-link" href="${c.page.url('grouppage')}">
%endif
  ${_('Back to %(page_title)s') % dict(page_title=c.page.title)}
</a>

<h1>${_('Edit page')}</h1>

<form method="post" action="${h.url_for(action='update')}"
     id="page_add_form" enctype="multipart/form-data"
     class="fullForm">
  ${h.input_line('page_title', _('Title'))}
  ${h.input_wysiwyg('page_content', _('Content'))}
  <br />
  ${h.input_submit()}
</form>
