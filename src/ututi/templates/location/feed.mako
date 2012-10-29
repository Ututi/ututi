<%inherit file="/location/base.mako" />
<%namespace name="wall" file="/sections/wall_entries.mako" />
<%namespace name="discussion" file="/sections/discussion.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${wall.head_tags()}
  ${h.javascript_link('/javascript/dashboard.js')}
</%def>

<%def name="body_class()">wall location-wall</%def>

%if c.show_discussion_form:
  ${discussion.discussion_form('create_location_wall_post', 'location_id', c.location.id)}
  ${discussion.discussion_javascript()}
%endif

<%def name="empty_discussions_location()">
  <div class="feature-box one-column icon-message">
    <div class="title">
      ${_("About discussions:")}
    </div>
    <div class="clearfix">
      <div class="feature icon-discussions">
        <strong>${_("Start a discussion")}</strong>
        - ${_("discuss various topics. Both students and teachers from your university will be able to join the discussion.")}
      </div>
    </div>
    <div class="action-button">
      <button id="start-discussion-actionbutton">${_('Start a discussion')}</button>
    </div>
  </div>
</%def>

<%
  tip_dict = {'all': _('This is a list of all recent events in this university.'),
              'subjects': _('This is a list of all the recent events in the subjects and groups of this university.'),
              'discussions': _('This is a list of all recent discussions in this university.')}

  emptytext_dict = {'all': _('Sorry, nothing new at the moment.'),
                    'subjects': _('Sorry, no subject news the moment.'),
                    'discussions': "Sorry, no discussions for this university."}
%>
<div class="tip">
  ${tip_dict.get(c.current_tab, tip_dict['all'])}
</div>

${wall.wall_entries(c.events)}
%if not c.events:
<div id="empty-wall-notice">
  <p>${emptytext_dict.get(c.current_tab, emptytext_dict['all'])}</p>
  %if c.current_tab == 'discussions':
    ${empty_discussions_location()}
  %endif
</div>
%endif
