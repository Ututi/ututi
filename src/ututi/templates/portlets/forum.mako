<%inherit file="/portlets/base.mako"/>

<%def name="forum_info_portlet()">
  <%self:uportlet id="forum_info_portlet" portlet_class='MyProfile'>
    <%def name="header()">
        <a href="${url(controller=c.controller, action='index', id=c.group_id, category_id=c.category.id)}" title="${c.category.title}">${c.category.title}</a>
    </%def>
    <div class="profile"><div class="floatleft avatar">
    % if c.category.id == 1:
      <img id="forum-logo"  class="logo" src="${url('/images/community.png') }" alt="logo" />
    % elif c.category.id == 2:
      <img id="forum-logo"  class="logo" src="${url('/images/report_bug.png') }" alt="logo" />
    % endif
    </div>
    <div class="floatleft personal-data">
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
    <div class="clear"></div>
    </div>
    <div class="description small" style="padding-top: 5px">
      ${c.category.description}
    </div>
  </%self:uportlet>
</%def>

<%def name="forum_posts_portlet(category_id, controller, new_post_subtitle, messages, portlet_title, new_post_title)">
  <%self:uportlet id="group_latest_messages" portlet_class="inactive">
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
    <div class="footer">
      <div class="grey verysmall" style="padding-top: 7px; padding-bottom: 7px">
        ${new_post_subtitle}
      </div>
      ${h.button_to(new_post_title, url(controller=controller, action='new_thread'))}
    </div>
  </%self:uportlet>
</%def>
