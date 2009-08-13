<%inherit file="/base.mako" />

<%namespace file="/widgets/locationtag.mako" import="*"/>

<%def name="head_tags()">
    ${parent.head_tags()}
    ${h.stylesheet_link('/stylesheets/group.css')|n}
    ${h.stylesheet_link('/stylesheets/locationwidget.css')|n}
</%def>

<%def name="title()">
${_('New group')}
</%def>

<%def name="path_steps(step=0)">
<div id="steps">
  %for index, title in enumerate([_('Group settings'), _('Subject selection'), _('Member invitations')]):
<%
   cls=''
   if step == index:
       cls='active'%>
    <span class="step ${cls}">
      <span class="number">${index + 1}</span>
      <span class="title">${title}</span>
    </span>
  %endfor
</div>

</%def>

<h1>${_('New group')}</h1>

${path_steps()}

<form method="post" action="${url(controller='group', action='new_group')}"
     id="group_add_form" enctype="multipart/form-data">

  <div class="form-field">
    <label for="location-0">${_('Specify the school')}</label>
    ${location_widget(3)}
  </div>
  <div class="form-field">
    <label for="title">${_('Group title')}</label>
    <input type="text" id="title" name="title" class="line"/>
  </div>
  <div class="form-field">
    <label for="id">${_("Group email address")}</label>
    <input type="text" id="id" name="id" class="line"/>@${c.mailing_list_host}
  </div>
  <div class="form-field">
    <label for="year">${_("Year")}</label>
    <select name="year" id="year">
      %for year in c.years:
        %if year == c.current_year:
          <option value="${year}" selected="selected">${year}</option>
        %else:
          <option value="${year}">${year}</option>
        %endif
      %endfor
    </select>
  </div>

  <div class="form-field">
    <label for="description">${_('Description')}</label>
    <textarea class="line" name="description" id="description" cols="60" rows="5"></textarea>
  </div>

  <div class="form-field">
    <label for="logo_upload">${_('Group logo')}</label>
    <input type="file" name="logo_upload" id="logo_upload" class="line"/>
  </div>

  <div>
    <span class="btn">
      <input type="submit" value="${_('Save')}"/>
    </span>
  </div>
</form>
