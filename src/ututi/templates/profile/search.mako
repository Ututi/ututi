<%inherit file="/profile/base.mako" />
<%namespace file="/portlets/user.mako" import="*"/>
<%namespace file="/widgets/tags.mako" import="*"/>
<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/search/index.mako" import="search_results"/>

<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}

${parent.head_tags()}
</%def>

<%def name="portlets()">
<div id="sidebar">
  ${user_subjects_portlet()}
  ${user_groups_portlet()}

</div>
</%def>


<h1>${_('Search')}</h1>
${search_form(c.text, c.obj_type, c.tags, parts=['obj_type', 'text'], target=url(controller='profile', action='search'))}

%if c.results:
${search_results(c.results)}
%endif

%if c.obj_type == 'group':
  <div class="create_item">
    ${_('Did not find what you were looking for?')}
    ${h.button_to(_('Create a new group'), url(controller='group', action='add'))}
  </div>
%elif c.obj_type == 'subject':
  <div class="create_item">
    ${_('Did not find what you were looking for?')}
    ${h.button_to(_('Create a new subject'), url(controller='subject', action='add'))}
  </div>
%endif
