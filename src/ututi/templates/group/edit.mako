<%inherit file="/group/home.mako" />
<%namespace name="newlocationtag" file="/widgets/newlocationtag.mako" import="*"/>
<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="head_tags()">
<%newlocationtag:head_tags />
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
${parent.head_tags()}

${h.javascript_link('/javascript/js-alternatives.js')|n}
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
          <label for="logo_delete">
            <input type="checkbox" name="logo_delete" id="logo_delete" value="delete"/>
            ${_('Delete current logo')}
          </label>
        </div>
      </td>
      <td class="js-alternatives">
        ${h.input_line('title', _('Title'))}
        ${h.input_area('description', _('Description'))}
        <div class="form-field non-js">
          <label for="logo_upload">${_('Group logo')}</label>
          <form:error name="logo_upload" />
          <input type="file" name="logo_upload" id="logo_upload" class="line"/>
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
          ${location_widget(2)}
        </div>
        <br class="clear-left"/>

        <div class="form-field">
          <label for="tags">${_('Tags')}</label>
          ${tags_widget([])}
        </div>
        <hr />
        <div class="form-field">
          <label for="default_tab">${_('Default group tab')}</label>
          ${h.select("default_tab", c.group.default_tab, c.tabs)}
        </div>
        <div class="form-field" id="forum-type-setting">
          <label for="forum_type">${_('Forum type')}</label>
          ${h.select("forum_type", c.forum_type, c.forum_types)}
        </div>

%if h.check_crowds(['root']):
  <div class="form-field">
    <label for="moderators">
    % if c.group.moderators:
       <input name="moderators" id="moderators" type="checkbox" value="true" checked="checked" />
    % else:
       <input name="moderators" id="moderators" type="checkbox" value="true" />
    % endif
       ${_("Moderators")}
    </label>
  </div>
%endif

        <hr />

        <h2>${_('Access settings')}</h2>

        <div id="approve-new-members-setting" class="form-field">
          <label for="approve_new_members">${_('New members')}</label>
          ${h.radio("approve_new_members", "none",
            label=_('Anyone can join the group any time'))}
          ${h.radio("approve_new_members", "admin",
            label=_('Administrators have to approve new members'))}
        </div>

        <div id="forum-visibility-setting" class="form-field">
          <label for="forum_visibility">${_('Group forum and mailing list visibility')}</label>
          ${h.radio("forum_visibility", "public", label=_('Public'))}
          ${h.radio("forum_visibility", "members", label=_('Members only'))}
        </div>

        <div id="page-visibility-setting" class="form-field">
          <label for="page_visibility">${_('Group page visibility')}</label>
          ${h.radio("page_visibility", "public", label=_('Public'))}
          ${h.radio("page_visibility", "members", label=_('Members only'))}
        </div>

        ${h.input_submit()}
      </td>
  </tr></table>
</form>
