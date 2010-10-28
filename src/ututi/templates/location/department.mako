<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/search/index.mako" import="search_results"/>
<%namespace file="/portlets/structure.mako" import="*"/>
<%namespace file="/portlets/school.mako" import="*"/>
<%namespace file="/location/university.mako" import="tabs"/>

<%def name="portlets()">
<div id="sidebar">
  ${struct_info_portlet()}
  ${school_members_portlet(_("Faculty's members"))}
  ${struct_groups_portlet()}
</div>
</%def>

<%def name="title()">
  ${c.location.parent.title_short} ${c.location.title} - ${_('subjects list')}
</%def>

<h1 class="pageTitle">${c.location.parent.title_short} ${c.location.title}</h1>
<br />

${tabs()}

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
