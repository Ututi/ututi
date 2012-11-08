<%inherit file="/user/teacher_base.mako" />
<%namespace name="snippets" file="/sections/content_snippets.mako" />

<div class="back-link">
  <a class="back-link" href="${url(controller='user', action='teacher_blog_index', id=c.teacher.id)}"
    >${_('Back to post list')}</a>
</div>
<div class="page-section blog">
  <%snippets:blog_post post="${c.blog_post}" />
</div>
