<%inherit file="/profile/base.mako" />
<%namespace name="wall" file="/sections/wall_snippets.mako" import="head_tags"/>
<%namespace name="dashboard" file="/sections/wall_dashboard.mako" />
<%def name="head_tags()">
  ${parent.head_tags()}
  ${wall.head_tags()}
  ${dashboard.head_tags()}
</%def>

<%def name="pagetitle()">
  ${_("What's new?")}
</%def>

${dashboard.dashboard(c.file_recipients, c.wiki_recipients)}

<div id='wall'>
  <div class="tip">
    ${_('This is a list of all the recent events in the subjects you are watching and the groups you belong to.')}
    <a href="${url(controller='profile', action='wall_settings')}">${_('Edit shown updates.')}</a>
  </div>

  %if c.events:
    % for event in c.events:
      ${event.snippet()}
    % endfor
  %else:
  <%self:rounded_block id="empty_wall_block">
    <%
        if c.user.location is None:
            groups_list_link = '/search?obj_type=group'
            subjects_list_link = '/search?obj_type=subject'
        else:
            groups_list_link = c.user.location.url(action='groups')
            subjects_list_link =  c.user.location.url(action='subjects')

    %>
    ${_('This is the Ututi wall. Here you will find notifications about '\
        'things that concern you such as changes in your groups and the '\
        'subjects you are watching. Start by <a href="%(create_group_link)s">creating</a> '\
        'or <a href="%(groups_list_link)s">joining</a> a group and watching '\
        'some <a href="%(subjects_list_link)s">subjects</a>.')\
        % dict(
            create_group_link = url(controller = 'group', action = 'group_type'),
            groups_list_link = groups_list_link,
            subjects_list_link = subjects_list_link) | n}
  </%self:rounded_block>

  %endif
</div>
