<%inherit file="/group/home.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="head_tags()">
${h.javascript_link('/javascripts/jquery-ui-1.7.2.custom.min.js')|n}
<script type="text/javascript">
//<![CDATA[
$(document).ready(function(){

    $(".folder").sortable({
      connectWith: ['.folder']
    });

	var buttons = $('.file_upload_dropdown .upload');
    buttons.each(
      function (i, btn) {
          var button = $(btn);

          [ign, i1, i2] = button[0].id.split('-');
          var progress_area = $('#file_upload_progress-' + i1);
          var folder = $('#file_folder_name-' + i1 + '-' + i2).val();
          var result_area = $('#file_area-' + i1 + '-' + i2);
          var upload_url = $('#file_upload_url-' + i1).val();

          new AjaxUpload(button,{
              action: upload_url,
              name: 'attachment',
              data: {folder: folder},
              onSubmit : function(file, ext, iframe){
                  iframe['progress_indicator'] = $(document.createElement('div'));
                  iframe['progress_indicator'].appendTo(progress_area).text(file);
                  iframe['progress_ticker'] = $(document.createElement('span'));
                  iframe['progress_ticker'].appendTo(iframe['progress_indicator']).text('Uploading');
                  var progress_ticker = iframe['progress_ticker'];
                  var interval;

                  // Uploding -> Uploading. -- Uploading...
                  interval = window.setInterval(function(){
                      var text = progress_ticker.text();
                      if (text.length < 13){
                          progress_ticker.text(text + '.');
                      } else {
                          progress_ticker.text('Uploading');
                      }
                  }, 200);
                  iframe['interval'] = interval;
              },
              onComplete: function(file, response, iframe){
                  iframe['progress_ticker'].text('Done');
                  window.clearInterval(iframe['interval']);
                  // add file to the list
                  $('.folder', result_area).append(response);
              }
          });

    });

    function newFolder(target) {
        var n = target[0].id.split('-')[1]
        var folder_name = target.id;
        // file_upload_dropdown-{self.n} - append button
        // file_section-{self.n} - append new folder
    }

    $(".delete_button").click(function(event) {
        // send delete file command
        // set progress indicator
        // on success - remove block with file
        // if last file in block, enable message for the block (toggle class hidden on "#section_id .message")
        var folder = $(event.target).parent().parent();
        $(event.target).parent().remove();
        if ($(".file", folder).size() == 0) {
            $(".message", folder).show();
        }
    });

	var buttons = $('#new_folder_button');
    buttons.each(function (i, val) {
        newFolder($(val));
    });

});
//]]>
</script>

</%def>

<h1>${_('Group Files')}</h1>

<%
    self.n = 0
%>

<%def name="file(file)">
            <li class="file">
              <img src="${url('/images/mimetypes_icons/unknown.png')}" />
              ${h.link_to(file.title, file.url())}
              <img src="${url('/images/delete.png')}" class="delete_button" />
            </li>
</%def>

<%def name="folder_button(folder, section_id, fid)">
        % if folder.title == '':
      <li class="alternative upload" id="file_upload_button-${section_id}-${fid}"><span>Here</span></li>
        % else:
      <li class="alternative upload" id="file_upload_button-${section_id}-${fid}">${folder.title}</li>
        % endif
</%def>

<%def name="folder(folder, section_id, fid)">
      <div id="file_area-${section_id}-${fid}">
        <input id="file_folder_name-${section_id}-${fid}" type="hidden" value="${folder.title}" />
        % if folder.title == '':
          <ul class="folder">
            <li style="display: none;" class="message">There are no files here, this folder is empty!</li>
            % for file in folder:
              <%self:file file="${file}" />
            % endfor
          </ul>
        % else:
          <h4>
            <img src="${url('/images/folder.png')}" />
            ${folder.title} (<a href="">trinti</a>)
          </h4>
          <ul class="folder">
          % if folder:
              <li style="display: none;" class="message">There are no files here, this folder is empty!</li>
            % for file in folder:
              <%self:file file="${file}" />
            % endfor
          % else:
              <li class="message">There are no files here, this folder is empty!</li>
          % endif
          </ul>
        % endif
      </div>
</%def>

<%def name="file_browser(obj)">
  <fieldset id="file_section-${self.n}">
    <legend>${obj.title}</legend>
    <input type="hidden" id="file_upload_url-${self.n}"
           value="${obj.url(action='upload_file')}" />
    <input type="hidden" id="create_folder_url-${self.n}"
           value="${obj.url(action='create_folder')}" />
    <div id="file_upload_progress-${self.n}">
    </div>
    <ul class="file_upload_dropdown" id="file_upload_dropdown-${self.n}">
      <li class="active">
        <span>
          Upload file
        </span>
      </li>
      % for fid, folder in enumerate(obj.folders):
        <%self:folder_button folder="${folder}" section_id="${self.n}" fid="${fid}" />
      % endfor
    </ul>
    <div>
      <input id="new_folder_input-${self.n}" type="text" value="" />
      <input id="new_folder_button-${self.n}" class="new_folder_button" type="button" value="New folder" />
    </div>
    % for fid, folder in enumerate(obj.folders):
        <%self:folder folder="${folder}" section_id="${self.n}" fid="${fid}" />
    % endfor
  </fieldset>
  <%
      self.n += 1
  %>
</%def>


<%self:file_browser obj="${c.group}" />

% for subject in c.group.watched_subjects:
  <%self:file_browser obj="${subject}" />
% endfor
