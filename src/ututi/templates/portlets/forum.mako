<%inherit file="/portlets/base.mako"/>

<%def name="forum_info_portlet()">
  <%self:portlet id="forum_info_portlet">
    <%def name="header()">
        <a href="${url(controller=c.controller, action='index', id=c.group_id, category_id=c.category.id)}" title="${c.category.title}">${c.category.title}</a>
    </%def>
    % if c.category.id == 1:
      <img id="forum-logo"  class="logo" src="${url('/images/community.png') }" alt="logo" />
    % elif c.category.id == 2:
      <img id="forum-logo"  class="logo" src="${url('/images/report_bug.png') }" alt="logo" />
    % endif
    <div class="structured_info">
      <span class="small">
        ${ungettext("<em>%(count)s</em> active poster", "<em>%(count)s</em> active posters", c.category.poster_count()) % dict(count=c.category.poster_count())|n}
      </span>
      <br />
      <span class="small">
        ${ungettext("<em>%(count)s</em> topic", "<em>%(count)s</em> topics", c.category.topic_count()) % dict(count=c.category.topic_count())|n}
      </span>
      <br />
      <span class="small">
        ${ungettext("<em>%(count)s</em> post", "<em>%(count)s</em> posts", c.category.post_count()) % dict(count=c.category.post_count())|n}
      </span>
    </div>
    <br />
    <hr />
    <div class="description small">
      ${c.category.description}
    </div>
  </%self:portlet>
</%def>

<%def name="forum_posts_portlet(category_id, controller, new_post_subtitle, messages, portlet_title, new_post_title)">
  <%self:portlet id="group_latest_messages" portlet_class="inactive">
    <%def name="header()">
      <a href="${url(controller=controller, action='index', id=None, category_id=category_id)}">${portlet_title|n}</a>
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
      <a class="more" href="${url(controller=controller, action='index')}" title="${_('more')}">${_('more')}</a>
      <a href="${url(controller=controller, action='new_thread')}" class="btn"><span>${new_post_title}</span></a>
    </div>
  </%self:portlet>
</%def>

<%def name="community_forum_posts_portlet()">
${forum_posts_portlet(category_id=1,
                      controller='community',
                      new_post_subtitle='',
                      messages=c.community_category.messages(),
                      portlet_title=_('Messages in community forum'),
                      new_post_title=_('New topic'))}
</%def>

<%def name="bugs_forum_posts_portlet()">
${forum_posts_portlet(category_id=2,
                      controller='bugs',
                      new_post_subtitle=_('You found a bug in our system? Something is broken? Report it.'),
                      messages=c.bugs_category.messages(),
                      portlet_title=_('Messages in Bugs forum'),
                      new_post_title=_('Report a bug'))}
</%def>
