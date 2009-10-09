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
${search_form(c.text, c.obj_type, c.tags, parts=['obj_type', 'text', 'tags'], target=url(controller='profile', action='search'), js_target=url(controller='profile', action='search_js'), js=True)}

${search_results(c.results)}
%if c.searched:


  %if c.obj_type == 'group':
  <div class="create_item">
    <span class="notice">${_('Did not find what you were looking for?')}</span>
    ${h.button_to(_('Create a new group'), url(controller='group', action='add'))}
    ${h.image('/images/details/icon_question.png', alt=_('Create your group, invite your classmates and use the mailing list, upload private group files'), class_='tooltip')|n}
  </div>


  %else:
  <div class="create_item">
    <span class="notice">${_('Did not find what you were looking for?')}</span>
    ${h.button_to(_('Create a new subject'), url(controller='subject', action='add'))}
    ${h.image('/images/details/icon_question.png',
                alt=_("Store all the subject's files and notes in one place."),
                class_='tooltip')|n}
  </div>
  %endif
%endif
