<%inherit file="/ubase-sidebar.mako" />
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
  ${c.location.title} (${c.location.title_short}) - ${_('department list')}
</%def>

<%def name="department_list(children, departments_shown, department_count)">
<div class="click2show">
  <table id="faculties-list">
      %for n, (dep_left, dep_right) in enumerate(children):
      <%
         cls = '' if n < departments_shown / 2 else 'show'
      %>
      <tr class="${cls}">
        <td style="width: 50%;">
          %if dep_left is not None:
            ${location_tag(dep_left)}
          %endif
        </td>
        <td style="width: 50%;">
          %if dep_right is not None:
            ${location_tag(dep_right)}
          %endif

        </td>
      </tr>
      %endfor
  </table>
  %if department_count > 6:
  <div>
    <span class="files_more">
      <span class="green verysmall click hide">
        ${ungettext("Show the other %(count)s department", "Show the other %(count)s departments", department_count - departments_shown ) % dict(count = department_count - departments_shown)}
      </span>
    </span>
  </div>
  %endif
</div>
</%def>


<h1 class="pageTitle">${c.location.title}</h1>
<br />

${h.department_listing(c.location.id, 6)}

<h2 class="overline">${_('Search in the university')}</h2>
##%if c.came_from_search:
##<script type="text/javascript"><!--
##google_ad_client = "pub-1809251984220343";
##/* Universities ads menu - 728x15 */
##google_ad_slot = "1300049814";
##google_ad_width = 650;
##google_ad_height = 15;
##//-->
##</script>
##<script type="text/javascript"
##src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
##</script> 
##%endif

${search_form(c.text, c.obj_type, c.location.hierarchy,
  parts=['obj_type', 'text'], target=c.location.url(), js=True,
  js_target=c.location.url(action='search_js'))}

  ${search_results(c.results, controller='structureview', action='search_js')}

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
