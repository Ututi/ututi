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
  %for index, title in enumerate([_('Group settings'), _('Member invitations'), _('Subject selection')]):
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

<h1>${_('Create your Ututi group and start sharing!')}
  ${h.image('/images/details/icon_question.png',
            alt=_('Create your group, invite your classmates and use the mailing list, upload private group files'),
            class_='tooltip')|n}
</h1>

${path_steps()}

<form method="post" action="${url(controller='group', action='new_group')}"
     id="group_add_form" enctype="multipart/form-data">

  <div class="form-field">
    %if c.location:
      ${location_widget(2, c.location.hierarchy())}
    %else:
      ${location_widget(2)}
    %endif
  </div>
  <br class="clear-left"/>
  ${h.input_line('title', _('Group title'))}
  <div class="form-field">
    <label for="id">${_("Group email address")}</label>
    <form:error name="id" />
    <div class="input-line"><div>
        <input type="text" id="id" name="id" class="line"/>
    </div></div>
    @${c.mailing_list_host}
    <div class="explanation">${_("Your group's email address at Ututi")}</div>
  </div>
  <div class="form-field">
    <label for="year">${_("Year")}</label>
    <form:error name="year" />
    <select name="year" id="year">
      %for year in c.years:
      <option value="${year}">${year}</option>
      %endfor
    </select>
  </div>
  <div class="form-field">
    <label for="logo_upload">${_('Group logo')}</label>
    <form:error name="logo_upload" />
    <input type="file" name="logo_upload" id="logo_upload" class="line"/>
  </div>
  ${h.input_area('description', _('Description'))}
<%
from ututi.lib.security import is_root
%>
% if is_root(c.user):
  <div class="form-field">
    <label for="moderators">${_("Moderators")}</label>
    <input name="moderators" id="moderators" type="checkbox" />
  </div>
% endif

  ${h.input_submit(_('Continue'))}
</form>
