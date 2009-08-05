<%def name="head_tags()">
${h.javascript_link('/javascripts/jquery-ui-1.7.2.custom.min.js')|n}
<script type="text/javascript">
//<![CDATA[
$(document).ready(function(){

    function folderReceive(event, ui) {

          var url = ui.item.children('.move_url').val();

          var source_type = ui.sender.parents('.section').children('.type').val();
          var source_id = ui.sender.parents('.section').children('.id').val();
          var source_location = ui.sender.parents('.section').children('.location').val();

          var target_type = ui.item.parents('.section').children('.type').val();
          var target_id = ui.item.parents('.section').children('.id').val();
          var target_location = ui.item.parents('.section').children('.location').val();
          var target_folder = ui.item.parents('.folder_file_area').children('.folder_name').val();

          $.ajax({type: "POST",
                  url: url,
                  data: ({source_type: source_type,
                          source_id: source_id,
                          source_location: source_location,
                          target_type: target_type,
                          target_id: target_id,
                          target_location: target_location,
                          target_folder: target_folder}),
                  success: function(msg){
                      if (ui.sender.children('.file').size() == 0) {
                         ui.sender.children('.message').show();
                      } else {
                          ui.sender.children('.message').hide();
                      }
                      if (ui.item.parents('.folder').children('.file').size() == 0) {
                          ui.item.parents('.folder').children('.message').show();
                      } else {
                          ui.item.parents('.folder').children('.message').hide();
                      }
           }});
    }


    $(".folder").sortable({
      connectWith: ['.folder'],
      cancel: '.message',
      receive: folderReceive
    });

    function setUpFolder(i, btn) {
      var button = $(btn);

	  [ign, i1, i2] = button[0].id.split('-');
	  var progress_area = $('#file_upload_progress-' + i1);
      var folder_name_input_id = '#file_folder_name-' + i1 + '-' + i2;
	  var folder = $(folder_name_input_id).val();
      var result_area_id = '#file_area-' + i1 + '-' + i2;
	  var result_area = $(result_area_id);
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
			  $('.folder', result_area).append(response);
              $('.folder .message', result_area).hide();
		  }
      });

      $('.delete_folder_button', result_area).click(function (event) {
          deleteFolder(event.target);
          return false;
      });
    }

	var buttons = $('.file_upload_dropdown .upload');
    buttons.each(setUpFolder);

    function newFolder(target) {
        var section_id = target.id.split('-')[1];
        var folder_name = $('#new_folder_input-' + section_id).val();
        $('#new_folder_input-' + section_id).val('');
        var url = $('#create_folder_url-' + section_id).val();
        $.ajax({type: "POST",
                url: url,
                data: ({section_id: section_id, folder: folder_name}),
                success: function(msg){
                    if (msg != '') {
                        $('#file_section-' + section_id).append($(msg)[2]);
                        $('#file_upload_dropdown-' + section_id).append($(msg)[0]);
                        setUpFolder(0, $('#file_upload_dropdown-' + section_id + ' .upload:last')[0]);
                        $(".folder").sortable({
                          connectWith: ['.folder'],
                          cancel: '.message',
                          receive: folderReceive
                        });
                    }
                }});
    }

    function deleteFolder(target) {
        var section_id = target.id.split('-')[1];
        var fid = target.id.split('-')[2];
        var folder_name = $('#file_folder_name-' + section_id + '-' + fid).val();
        var url = $('#delete_folder_url-' + section_id).val();
        $.ajax({type: "POST",
                url: url,
                data: ({folder: folder_name}),
                success: function(msg){
                    $('#file_area-' + section_id + '-' + fid).hide()
                    $('#file_upload_button-' + section_id + '-' + fid).hide()
                }});
    }

    $('.delete_button').click(function(event) {
        var folder = $(event.target).parent().parent();
        var url = $(event.target).prev('.delete_url').val();
        $.ajax({type: "GET",
                url: url,
                success: function(msg){
                    $(event.target).parent().remove();
                    if ($('.file', folder).size() == 0) {
                        $('.message', folder).show();
                    }
        }});
    });

	$('.new_folder_button').click(function (event) {
        newFolder(event.target);
        return false;
    });

});
//]]>
</script>
</%def>

<%def name="file(file)">
            <li class="file">
              <img src="${url('/images/mimetypes_icons/unknown.png')}" />
              ${h.link_to(file.title, file.url())}
              <input class="move_url" type="hidden" value="${file.url(action='move')}" />
              <input class="delete_url" type="hidden" value="${file.url(action='delete')}" />
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
      <div class="folder_file_area" id="file_area-${section_id}-${fid}">
        <input class="folder_name" id="file_folder_name-${section_id}-${fid}" type="hidden" value="${folder.title}" />
        % if folder.title != '':
          <h4>
            <img src="${url('/images/folder.png')}" />
            ${folder.title} (<a href="#" id="delete_folder_button-${section_id}-${fid}" class="delete_folder_button">trinti</a>)
          </h4>
        % endif
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
      </div>
</%def>

<%def name="file_browser(obj, section_id=0)">
  <fieldset class="section" id="file_section-${section_id}">
    <legend>${obj.title}</legend>
    <input type="hidden" id="file_upload_url-${section_id}"
           value="${obj.url(action='upload_file')}" />
    <input type="hidden" id="create_folder_url-${section_id}"
           value="${obj.url(action='create_folder')}" />
    <input type="hidden" id="delete_folder_url-${section_id}"
           value="${obj.url(action='delete_folder')}" />
    <input type="hidden" class="type" value="${type(obj).__name__.lower()}" />
    <input type="hidden" class="id" value="${obj.id}" />
    <input type="hidden" class="location" value="${obj.location.id}" />
    <div id="file_upload_progress-${section_id}">
    </div>
    <ul class="file_upload_dropdown" id="file_upload_dropdown-${section_id}">
      <li class="active">
        <span>
          Upload file
        </span>
      </li>
      % for fid, folder in enumerate(obj.folders):
        <%self:folder_button folder="${folder}" section_id="${section_id}" fid="${fid}" />
      % endfor
    </ul>
    <div>
      <form action="${obj.url(action='create_folder')}">
        <input name="folder" id="new_folder_input-${section_id}" type="text" value="" />
        <input id="new_folder_button-${section_id}" class="new_folder_button" type="submit" value="New folder" />
      </form>
    </div>
    % for fid, folder in enumerate(obj.folders):
        <%self:folder folder="${folder}" section_id="${section_id}" fid="${fid}" />
    % endfor
  </fieldset>
</%def>
