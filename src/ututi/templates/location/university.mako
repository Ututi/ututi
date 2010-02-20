<%inherit file="/base.mako" />
<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/search/index.mako" import="search_results"/>
<%namespace file="/portlets/structure.mako" import="*"/>
<%namespace file="/anonymous_index/en.mako" import="*"/>

<%def name="portlets()">
<div id="sidebar">
  ${struct_info_portlet()}
  ${struct_groups_portlet()}
</div>
</%def>

<%def name="title()">
  ${c.location.title}
</%def>

<%def name="head_tags()">
${parent.head_tags()}
${h.stylesheet_link('/stylesheets/location.css')|n}
</%def>

<h2 class="underline">${c.location.title_short} ${_('department list')}</h2>
<%
   children = c.location.children
   l = len(children)
   children = [children[:l/2], children[l/2:]]
%>
<table id="faculties-list">
  <tr>
    %for group in children:
      <td style="width: 50%;">
        %for department in group:
        ${location_tag(department)}
        %endfor
      </td>
    %endfor
  </tr>
</table>


<h2 class="underline">${_('Search')}</h2>
${search_form(c.text, c.obj_type, c.location.hierarchy,
  parts=['obj_type', 'text'], target=c.location.url(), js=True,
  js_target=c.location.url(action='search_js'))}

  ${search_results(c.results)}

  %if c.user:
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
