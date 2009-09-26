<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/files.css')|n}
${h.javascript_link('/javascripts/jquery-ui-1.7.2.custom.min.js')|n}

<script type="text/javascript">
//<![CDATA[
$(document).ready(function(){

    function folderReceive(event, ui) {

          var move_url = ui.item.children('.move_url').val();
          var copy_url = ui.item.children('.copy_url').val();

          var source_id = ui.sender.parents('.section').children('.container').children('.id').val();
          var target_id = ui.item.parents('.section').children('.container').children('.id').val();
          var target_folder = ui.item.parents('.folder_file_area').children('.folder_name').val();

          if (source_id != target_id) {
              $.ajax({type: "POST",
                      url: copy_url,
                      data: ({source_id: source_id,
                              target_id: target_id,
                              target_folder: target_folder}),
                      success: function(msg){
                          var new_item = $(msg).insertAfter($(ui.item));
                          $(ui.sender).sortable('cancel');
                          new_item.parents('.folder').children('.message').hide();
                          $('.delete_button', new_item).click(deleteFile);
                      },
                      error: function(msg){
                          $(ui.sender).sortable('cancel');
                      }
              })
          }
          else {
              $.ajax({type: "POST",
                      url: move_url,
                      data: ({target_folder: target_folder}),
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
                      },
                      error: function(msg){
                          $(ui.sender).sortable('cancel');
                      }
              })
          }
    }


    $(".folder").sortable({
      connectWith: ['.folder'],
      cancel: '.message',
      helper: 'clone',
      receive: folderReceive,
      handle: 'img.drag-target',
      axis: 'y'
    });

    function setUpFolder(i, btn) {
      var button = $(btn);

      var ids = button[0].id.split('-');
      var ign = ids[0];
      var i1 = ids[1];
      var i2 = ids[2];
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
              iframe['progress_ticker'].text('Done').parent().addClass('done');
              window.clearInterval(iframe['interval']);
              $('.folder', result_area).append(response);
              $('.delete_button', result_area).click(deleteFile);
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
        if ($.trim(folder_name) != '') {
           $('#new_folder_input-' + section_id).val('');
            var url = $('#create_folder_url-' + section_id).val();
            $.ajax({type: "POST",
                  url: url,
                  data: ({section_id: section_id, folder: folder_name}),
                  success: function(msg){
                      if (msg != '') {
                          $('#file_section-' + section_id + ' .container').append($(msg).filter('.folder_file_area'));
                          if ($('#file_upload_dropdown-' + section_id).hasClass('open')) {
                              $('#file_upload_dropdown-' + section_id).children('.click').click();
                          }
                          $('#file_upload_dropdown-' + section_id).find('.target_item:last').removeClass('last').after($(msg)[0]);
                          $('#file_upload_dropdown-' + section_id).find('.target_item:last').addClass('last');
                          setUpFolder(0, $('#file_upload_dropdown-' + section_id + ' .upload:last')[0]);
                          $(".folder").sortable({
                            connectWith: ['.folder'],
                            cancel: '.message',
                            receive: folderReceive
                          });
                        }
                  }});
        }
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
                    $('#file_upload_button-' + section_id + '-' + fid).parent().remove()
                }});
    }

    function deleteFile(event) {
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
    }

    $('.delete_button').click(deleteFile);

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
              ${h.image('/images/details/icon_drag_file.png', alt='file icon', class_='drag-target')|n}
              ${h.link_to(file.title, file.url())}
              <span class="size">(${h.file_size(file.size)})</span>
              <span class="date">${h.fmt_dt(file.created_on)}</span>
              <a href="${url(controller='user', action='index', id=file.created_by)}" class="author">
                ${file.created.fullname}
              </a>
              <input class="move_url" type="hidden" value="${file.url(action='move')}" />
              <input class="copy_url" type="hidden" value="${file.url(action='copy')}" />
              <input class="delete_url" type="hidden" value="${file.url(action='delete')}" />
              %if file.can_write():
                <img src="${url('/images/delete.png')}" alt="delete file" class="delete_button" />
              %endif
            </li>
</%def>

<%def name="folder_button(folder, section_id, fid, cls='')">
  % if folder.title == '':
    <div class="target_item ${cls}"><div class="upload target" id="file_upload_button-${section_id}-${fid}">${_('Here')}</div></div>
  % else:
    <div class="target_item ${cls}"><div class="upload target" id="file_upload_button-${section_id}-${fid}">${h.ellipsis(folder.title, 17)}</div></div>
  % endif
</%def>

<%def name="folder(folder, section_id, fid)">
      <%
         cls = folder.title == '' and 'root_folder' or 'subfolder'
      %>
      <div class="folder_file_area ${cls}" id="file_area-${section_id}-${fid}">
        <input class="folder_name" id="file_folder_name-${section_id}-${fid}" type="hidden" value="${folder.title}" />
        % if folder.title != '':
          <h4>
            ${folder.title}
            % if folder.can_write():
              <a href="${folder.parent.url(action='delete_folder', folder=folder.title)}" id="delete_folder_button-${section_id}-${fid}" class="delete_folder_button">${_("(Delete)")}</a>
            % endif
          </h4>
        % endif
          <ul class="folder">
        % if folder:
              <li style="display: none;" class="message">${_("There are no files here, this folder is empty!")}</li>
              % for file in folder:
                <%self:file file="${file}" />
              % endfor
        % else:
              <li class="message">${_("There are no files here, this folder is empty!")}</li>
        % endif
          </ul>
      </div>
</%def>

<%def name="file_browser(obj, section_id=0, collapsible=False, title=None)">
  <div class="section click2show" id="file_section-${section_id}">
    <%
       cls_head = cls_container = ''
       if collapsible:
           cls_head = 'click'
           cls_container = 'show'
    %>
    <h2 class="${cls_head}">
      %if title is None:
        ${h.ellipsis(obj.title, 80)}
      %else:
        ${h.ellipsis(title, 80)}
      %endif
      <span class="small">(${ungettext("%(count)s file", "%(count)s files", obj.file_count) % dict(count = obj.file_count)})</span>
    </h2>
    <div class="container ${cls_container}">
      <input type="hidden" id="file_upload_url-${section_id}"
             value="${obj.url(action='upload_file')}" />
      <input type="hidden" id="create_folder_url-${section_id}"
             value="${obj.url(action='js_create_folder')}" />
      <input type="hidden" id="delete_folder_url-${section_id}"
             value="${obj.url(action='js_delete_folder')}" />
      <input type="hidden" class="id" value="${obj.id}" />
      %if c.user:
      <div class="controls">
        <div id="file_upload_progress-${section_id}" class="file_upload_progress">
        </div>
      <div class="file_upload upload_dropdown click2show">
       <div class="click button">
         <div>
           ${_('upload file to...')}
         </div>
       </div>
       <div class="show target_list file_upload_dropdown" id="file_upload_dropdown-${section_id}">
        <%
           n = len(obj.folders)
        %>
        %for fid, folder in enumerate(obj.folders):
          <%
             cls = ''
             if fid == 0:
                 cls = 'first'
             if fid == n - 1:
                 cls = 'last'
          %>
          <%self:folder_button folder="${folder}" section_id="${section_id}" fid="${fid}" cls="${cls}"/>
        %endfor
      </div>
    </div>
      ${h.image('/images/details/icon_question.png', alt=_('Upload the file to any folder.'), class_='tooltip')|n}

        <div style="float: left; margin-left: 20px;">
          <form action="${obj.url(action='create_folder')}">
            <div>
              <label for="folder">${_('New folder:')}</label>
              <input name="folder" id="new_folder_input-${section_id}" type="text" value="" class="new-folder-name" />
              <span class="btn">
                <input id="new_folder_button-${section_id}" class="new_folder_button" type="submit" value="${_('create')}" />
              </span>
            </div>
          </form>
        </div>
        <br class="clear-left"/>
      </div>
      %endif
      % for fid, folder in enumerate(obj.folders):
        <%self:folder folder="${folder}" section_id="${section_id}" fid="${fid}" />
      % endfor
    </div>
  </div>
</%def>
