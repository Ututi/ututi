<%inherit file="/user/teacher_base.mako" />
<%namespace name="snippets" file="/sections/content_snippets.mako" />

<div class="page-section blog">
  <%snippets:blog_post post="${c.blog_post}" />
</div>
