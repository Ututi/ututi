<%inherit file="/profile/teacher/edit_text_base.mako" />

<div class="single_button">
    <form id="message_button" action="${url(controller='profile', action='create_blog_post')}">
        <input type="submit" class="black" value="${_('Create a new post')}" />
    </form>
</div>
<div class="single-messages">
%if bool(c.posts):
  <div>${_("Click on a blog post to edit it.")}</div>
  % for post in c.posts:
    <div class="message-list-off1">
      <div class="floatleft m-on">
        <div class="orange">
          <a href="${url(controller='profile', action='edit_blog_post', id=post.id)}"
             class="post-title">${post.title}</a>
          <span class="reply-count">
            (${ungettext("%(count)s comment", "%(count)s comments", len(post.comments)) % dict(count=len(post.comments))})
          </span>
          ${h.button_to('Delete', url(controller='profile', action='delete_blog_post', id=post.id), style='display: none')}
          <a href="#" class="delete-post-link"><img src="${url('/img/icons/cross_small.png')}" alt="delete" /></a>
        </div>
      </div>
      <div class="floatleft user">
        <div class="grey verysmall">${h.fmt_dt(post.created_on)}</div>
      </div>
      <br style="clear: left;" />
    </div>
  %endfor
%else:
  <div>${_("You haven't created any blog posts yet.")}</div>
%endif
</div>

<script>
    $('.delete-post-link').click(function() {
        $(this).siblings('form').submit();
    });
</script>
