<%inherit file="/portlets/base.mako"/>

<%def name="forum_info_portlet()">
  <%self:portlet id="forum_info_portlet">
    <%def name="header()">
      <a href="${url(controller='forum', forum_id=c.forum_id)}" title="${c.forum_title}">${c.forum_title}</a>
    </%def>
    <div class="structured_info">
      <img id="group-logo" src="${url('/images/%s' % c.forum_logo) }" alt="logo" />
      <span class="small">
        ${ungettext("%(count)s active poster", "%(count)s active posters", c.poster_count) % dict(count=c.poster_count)}
      </span>
      <br />
      <span class="small">
        ${ungettext("%(count)s topic", "%(count)s topics", c.topic_count) % dict(count=c.topic_count)}
      </span>
      <br />
      <span class="small">
        ${ungettext("%(count)s post", "%(count)s posts", c.post_count) % dict(count=c.post_count)}
      </span>
    </div>
    <hr />
    <div class="description small">
      ${c.forum_description}
    </div>
  </%self:portlet>
</%def>

<%def name="forum_posts_portlet(forum_id, new_post_subtitle, messages, portlet_title, new_post_title)">
  <%self:portlet id="group_latest_messages" portlet_class="inactive">
    <%def name="header()">
      <a href="${url(controller='forum', action='index', forum_id=forum_id)}" title="${portlet_title}">${portlet_title}</a>
    </%def>
    %if messages:
      <table id="group_latest_messages">
        %for message in messages[:5]:
        <tr>
          <td class="time">${h.fmt_shortdate(message.created_on)}</td>
          <td class="subject"><a href="${message.url()}" title="${message.title}, ${message.created.fullname}">${h.ellipsis(message.title, 25)}</a></td>
        </tr>
        %endfor
      </table>
    %else:
      <div class="notice">${_("There are no messages.")}</div>
    %endif
    <br style="clear: both;" />
    <div class="footer">
      <a class="more" href="${url(controller='forum', forum_id=forum_id)}" title="${_('more')}">${_('more')}</a>
      <a href="${url(controller='forum', action='new_thread', forum_id=forum_id)}" class="btn"><span>${new_post_title}</span></a>
    </div>
  </%self:portlet>
</%def>

<%def name="bugs_forum_posts_portlet()">
${forum_posts_portlet(forum_id='bugs',
                      new_post_subtitle=_('You found a bug in our system? Something is broken? Report it.'),
                      messages=c.bugs_forum_messages,
                      portlet_title=_('Messages in Bugs forum'),
                      new_post_title=_('Report a bug'))}
</%def>

<%def name="community_forum_posts_portlet()">
${forum_posts_portlet(forum_id='community',
                      new_post_subtitle='',
                      messages=c.community_forum_messages,
                      portlet_title=_('Messages in community forum'),
                      new_post_title=_('New topic'))}
</%def>
