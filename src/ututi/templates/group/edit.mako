<%inherit file="/group/home.mako" />
<%namespace file="/widgets/locationtag.mako" import="*"/>
<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/locationwidget.css')|n}
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
${h.stylesheet_link('/stylesheets/group.css')|n}
${parent.head_tags()}

${h.javascript_link('/javascripts/js-alternatives.js')|n}
  <script type="text/javascript">
  //<![CDATA[
  $(document).ready(function() {
    new AjaxUpload('#group-logo-editable', {
      action: '${url(controller="group", id=c.group.group_id, action="logo_upload")}',
      name: 'logo',
      // Submit file after selection
      autoSubmit: true,
      responseType: false,
      onSubmit: function(file, extension) {
        if (! (extension && /^(jpg|png|jpeg|gif|tiff|bmp)$/.test(extension))){
          alert('${_("The file type is not supported.")}');
          return false;
        }
      },
      onComplete: function(file, response) {
        var img_id = '#group-logo-editable';
        var img_src = "${url(controller='group', id=c.group.group_id, action='logo', width='120', height='200')}";
        var timestamp = new Date().getTime();
        $(img_id).attr('src', img_src+'?'+timestamp);
      }
    });
    new AjaxUpload('#group-logo-button', {
      action: '${url(controller="group", id=c.group.group_id, action="logo_upload")}',
      name: 'logo',
      // Submit file after selection
      autoSubmit: true,
      responseType: false,
      onSubmit: function(file, extension) {
        if (! (extension && /^(jpg|png|jpeg|gif|tiff|bmp)$/.test(extension))){
          alert('${_("The file type is not supported.")}');
          return false;
        }
      },
      onComplete: function(file, response) {
        var img_id = '#group-logo-editable';
        var img_src = "${url(controller='group', id=c.group.group_id, action='logo', width='120', height='200')}";
        var timestamp = new Date().getTime();
        $(img_id).attr('src', img_src+'?'+timestamp);
      }
    });

   });
  //]]>
  </script>
</%def>


<h1>${_('Edit')}</h1>
<form method="post" action="${url(controller='group', action='update', id=c.group.group_id)}" name="edit_profile_form" enctype="multipart/form-data">
  <table>
    <tr>
      <td style="width: 180px; padding-top: 30px; vertical-align: top;">
        <div class="js-alternatives" id="group-logo">
          <img src="${url(controller='group', id=c.group.group_id, action='logo', width='120', height='200')}" alt="Group logo" id="group-logo-editable"/>
          <br />
          <a href="#" id="group-logo-button" class="btn js"><span>${_('Change logo')}</span></a>
        </div>
        <br class="clear-left"/>
        <div class="form-field no-break" style="text-align: center;">
          <input type="checkbox" name="logo_delete" id="logo_delete" value="delete"/>
          <label for="logo_delete">${_('Delete current logo')}</label>
        </div>
      </td>
      <td class="js-alternatives">
        <div class="form-field">
          <label for="title">${_('Title')}</label>
          <div class="input-rounded"><div>
              <input type="text" class="line" id="title" name="title" value="${c.group.title}"/>
          </div></div>
        </div>
        <div class="form-field">
          <label for="description">${_('Description')}</label>
          <textarea class="line" name="description" id="description" cols="25" rows="5">${c.group.description}</textarea>
        </div>
        <div class="form-field non-js">
          <label for="logo_upload">${_('Group logo')}</label>
          <input type="file" name="logo_upload" id="logo_upload" class="line"/>
        </div>

        <div class="form-field">
          ${location_widget(2, c.group.location.hierarchy())}
        </div>
        <br class="clear-left"/>
        <div class="form-field">
          <label for="year">${_("Year")}</label>
          <select name="year" id="year">
            %for year in c.years:
            %if year == c.group.year:
            <option value="${year}" selected="selected">${year}</option>
            %else:
            <option value="${year}">${year}</option>
            %endif
            %endfor
          </select>
        </div>

        <div class="form-field">
          <label for="tags">${_('Tags')}</label>
          ${tags_widget(c.group.tags_list)}
        </div>
        <div class="form-field">
          <label for="show_page">${_('Show group page')}</label>
          %if c.group.show_page:
            <input type="checkbox" name="show_page" id="show_page" value="true" checked="checked"/>
          %else:
            <input type="checkbox" name="show_page" id="show_page" value="true" checked="checked"/>
          %endif
        </div>

<%
from ututi.lib.security import is_root
%>
% if is_root(c.user):
  <div class="form-field">
    <label for="moderators">${_("Moderators")}</label>
    % if c.group.moderators:
       <input name="moderators" id="moderators" type="checkbox" value="true" checked="checked" />
    % else:
       <input name="moderators" id="moderators" type="checkbox" value="true" />
    % endif
  </div>
% endif


  <div>
    <span class="btn"><input type="submit" value="${_('Save')}"/></span>
  </div>
      </td>
  </tr></table>
</form>
