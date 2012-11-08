<%inherit file="/user/external/teacher_base.mako" />
<%namespace name="snippets" file="/sections/content_snippets.mako" />

<%def name="pagetitle()">${_("Blog")}</%def>

<div class="page-section blog">
  <div class="blog-post-list">
    %for post in c.blog_posts:
      <%snippets:blog_post post="${post}" show_comments="${False}" title_link="external" />
    %endfor
  </div>
</div>
