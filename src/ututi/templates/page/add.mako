<%inherit file="/page/base.mako" />

<%def name="head_tags()">
${parent.head_tags()}
${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
</%def>

<%def name="title()">
${_('New page')}
</%def>

% if getattr(c,'subject', None):
<a class="back-link" href="${c.subject.url()}">${_('Back to %(subject_title)s') % dict(subject_title=c.subject.title)}</a>
% endif


<h1>${_('New page')}</h1>

<form method="post" action="${h.url_for(action='create')}"
     id="page_add_form" enctype="multipart/form-data" class="fullForm">
  <fieldset>
    ${h.input_line('page_title', _('Title'))}
    ${h.input_wysiwyg('page_content', _('Content'))}
    <br />
    ${h.input_submit()}
  </fieldset>
</form>
