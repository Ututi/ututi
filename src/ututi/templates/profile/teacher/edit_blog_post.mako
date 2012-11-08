<%inherit file="/profile/teacher/edit_text_base.mako" />

<%def name="pagetitle()">
${_('Blog post')}
</%def>

<div>
  <form action="${c.blog_post_form_url}" method="POST">
    <fieldset>
      ${h.input_line('title', _('Title'),
        help_text=_("Enter a blog post title"))}
      ${h.input_wysiwyg('description', _('Post'))}
      ${h.input_submit(_('Save'), class_='btnMedium')}
    </fieldset>
  </form>
</div>
