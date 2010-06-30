<%namespace name="prebase" file="/prebase.mako" />

<%def name="head_tags()">
${h.javascript_link('/javascript/jquery-ui-1.7.2.custom.min.js')|n}
${h.javascript_link('/javascript/jquery.form.js')|n}
${h.stylesheet_link('/jquery-ui-1.7.3.custom.css')}

<script type="text/javascript">
//<![CDATA[
$(document).ready(function(){

    function folderReceive(event, ui) {

          var move_url = ui.item.children('.move_url').val();
          var copy_url = ui.item.children('.copy_url').val();

          var source_id = ui.sender.parents('.section').children('.container').children('.id').val();
          var target_id = ui.item.parents('.section').children('.container').children('.id').val();
          var target_folder = ui.item.closest('.folder_file_area').children('.folder_name').val();
          var target_is_trash = ui.item.closest('.folder').hasClass('.trash_folder');
          var source_is_trash = ui.sender.closest('.folder').hasClass('.trash_folder');

          if (source_id != target_id) {
              if (target_is_trash) {
                  $(ui.sender).sortable('cancel');
                  return;
              }
              $.ajax({type: "POST",
                      url: copy_url,
                      data: ({source_id: source_id,
                              target_id: target_id,
                              target_folder: target_folder}),
                      success: function(msg){
                          var new_item = $(msg).insertAfter($(ui.item));
                          $(ui.sender).sortable('cancel');
                          new_item.parents('.folder').children('.message').hide();
                          new_item.parents('.folder').closest('.folder_file_area').find('.delete_folder_button').hide();
                          $('.delete_button', new_item).click(deleteFile);
                          updateSizeInformation($('.section.size_indicated'));
                      },
                      error: function(msg){
                          $(ui.sender).sortable('cancel');
                      }
              })
          }
          else {
              $.ajax({type: "POST",
                      url: move_url,
                      data: ({target_folder: target_folder, remove: target_is_trash}),
                      success: function(msg){
                          if (ui.sender.children('.file').size() == 0) {
                             ui.sender.children('.message').show();
                             ui.sender.closest('.folder_file_area').find('.delete_folder_button').show()
                          } else {
                              ui.sender.children('.message').hide();
                              ui.sender.closest('.folder_file_area').find('.delete_folder_button').hide();
                          }
                          if (ui.item.parents('.folder').children('.file').size() == 0) {
                              ui.item.parents('.folder').children('.message').show();
                              ui.item.closest('.folder_file_area').find('.delete_folder_button').show()
                          } else {
                              ui.item.parents('.folder').children('.message').hide();
                              ui.item.closest('.folder_file_area').find('.delete_folder_button').hide()
                          }
                          if (target_is_trash || source_is_trash) {
                              var new_item = $(msg).insertAfter($(ui.item));
                              $('.delete_button', new_item).click(deleteFile);
                              $('.restore_button', new_item).click(restoreFile);
                              $(ui.item).remove();
                          }
                          updateSizeInformation($('.section.size_indicated'));
                      },
                      error: function(msg){
                          $(ui.sender).sortable('cancel');
                      }
              })
          }
    }

    var sortable_config = {
      connectWith: ['.folder'],
      cancel: '.message',
      helper: 'clone',
      receive: folderReceive,
      handle: 'img.drag-target',
      axis: 'y'
    };

    $(".section.open .folder").sortable(sortable_config);

    $(".section").bind("expand", function() {
      $('.folder', this).sortable(sortable_config);
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
                  if (text.length < "${_('Uploading')}".length){
                      progress_ticker.text(text + '.');
                  } else {
                      progress_ticker.text("${_('Uploading')}");
                  }
              }, 200);
              iframe['interval'] = interval;
          },
          onComplete: function(file, response, iframe){
              if (response != 'UPLOAD_FAILED') {
                  iframe['progress_ticker'].text("${_('Done')}").parent().addClass('done');
                  window.clearInterval(iframe['interval']);
                  $('.folder', result_area).append(response);
                  $('.delete_button', result_area).click(deleteFile);
                  $('.folder .message', result_area).hide();
                  $('.folder_file_area .delete_folder_button', result_area).hide();
                  updateSizeInformation($(result_area).parents('.section'));
              } else {
                  iframe['progress_ticker'].text("${_('File upload failed.')}").parent().addClass('failed');
                  window.clearInterval(iframe['interval']);
                  $('.folder .message', result_area).hide();
                  $('.folder_file_area .delete_folder_button', result_area).hide();
                  updateSizeInformation($(result_area).parents('.section'));
              }
          }
      });

      $('.delete_folder_button', result_area).click(function (event) {
          deleteFolder(event.target);
          return false;
      });
    }

    var buttons = $('.file_upload_dropdown .upload');
    buttons.each(setUpFolder);
    $('.single_upload .upload').each(setUpFolder);

    function createFolder(section_id, folder_name) {
        if ($.trim(folder_name) != '') {
           $('#new_folder_input-' + section_id).val('');
            var url = $('#create_folder_url-' + section_id).val();
            $.ajax({type: "POST",
                  url: url,
                  data: ({section_id: section_id, folder: folder_name}),
                  success: function(msg){
                      if (msg != '') {
                          // XXX find the old folder, insert new one after it, delete it
                          var area = $(msg).filter('.folder_file_area').insertBefore($('#file_section-' + section_id + ' .trash_folder_file_area'));
                          area.find('.delete_button').click(deleteFile);

                          section = $('#file_upload_dropdown-' + section_id)
                          if (section.hasClass('open')) {
                              section.children('.click').click();
                          }
                          section.find('.target_item:last').removeClass('last').after($(msg)[0]);
                          section.find('.target_item:last').addClass('last');
                          setUpFolder(0, $(' .upload:last', section)[0]);
                          $(".folder").sortable(sortable_config);
                          updateSizeInformation($('#file_section-'+section_id));
                        }
                  }});
        }
    }

    function newFolder(target) {
        var section_id = target.id.split('-')[1];
        var folder_name = $('#new_folder_input-' + section_id).val();
        createFolder(section_id, folder_name)
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
                    $('#file_area-' + section_id + '-' + fid).remove()
                    btn = $('#file_upload_button-' + section_id + '-' + fid);
                    control = btn.parents('.upload_dropdown');
                    btn.parent().remove();
                    updateSizeInformation($('#file_section-'+section_id));
                }});
    }

    function deleteFile(event) {
        var folder = $(event.target).closest('.folder');
        var url = $(event.target).closest('.file').children('.delete_url').val();
        var section = $(event.target).closest('.section');
        var section_area_id = section[0].id;
        var sid = section_area_id.split('-')[1];
        var trash_bin = $('#file_area-' + sid + '-trash');

        $.ajax({type: "GET",
                url: url,
                success: function(msg){
                    $(event.target).parent().remove();
                    if ($('.file', folder).size() == 0) {
                        $('.message', folder).show();
                        folder.closest('.folder_file_area').find('.delete_folder_button').show();
                    }
                    var new_item = $(msg);
                    trash_bin.show();
                    trash_bin.children('.folder').append(new_item);
                    new_item.parents('.folder').children('.message').hide();
                    $('.restore_button', new_item).click(restoreFile);
                    updateSizeInformation($(folder).parents('.section'));
        }});
    }

    function flagFile(event) {
        var folder = $(event.target).closest('.folder');
        var url = $(event.target).closest('.file').children('.flag_url').val();

        $.ajax({type: "GET",
                url: url,
                success: function(src){
                    var dlg = $('<div></div>');
                    dlg.html(src);
                    var submit_func = function () {
                        $('form', dlg).ajaxSubmit({
                            url: url,
                            type: 'POST',
                            dataType: 'json',
                            success: function() {
                                alert('OK');
                            }
                        });
                        dlg.dialog("close");
                        return false;
                    };
                    $('form', dlg).submit(submit_func);

                    dlg.dialog({
                        title: '${_('Suspicious file?')}'
                    });
                }
        });
    }

    function restoreFile(event) {
        var folder = $(event.target).closest('.folder');
        var url = $(event.target).closest('.file').children('.restore_url').val();
        var section = $(event.target).closest('.section');

        $.ajax({type: "GET",
                url: url,
                success: function(msg){
                    $(event.target).closest('.file').remove();
                    if ($('.file', folder).size() == 0) {
                        $('.message', folder).show();
                        folder.closest('.folder_file_area').find('.delete_folder_button').show();
                    }
                    var new_item = $(msg);
                    var folder_name = $(msg).children('.folder_title_value').val();
                    var target_folder_title_attr = section.contents().find('.folder_file_area .folder_name').filter(function (n) { return this.value == folder_name});
                    var target_folder = target_folder_title_attr.closest('.folder_file_area').children('.folder');
                    if (target_folder.size() == 0)
                    {
                        createFolder(section[0].id.split('-')[1], folder_name);
                    }
                    else {
                        target_folder.append(new_item);
                        target_folder.show();
                        new_item.parents('.folder').children('.message').hide();
                        new_item.closest('.folder_file_area').find('.delete_folder_button').hide();
                        $('.delete_button', new_item).click(deleteFile);
                        $('.rename_button', new_item).click(renameFile);
                        updateSizeInformation($(folder).parents('.section'));
                    }
        }});
    }

    $('.delete_button').click(deleteFile);
    $('.flag_button').click(flagFile);
    $('.restore_button').click(restoreFile);
    $('.rename_button').click(renameFile);

    function renameFile(event) {
       var file_name = $(event.target).closest('.file').find('.filename');
       var rename_form = $(event.target).closest('.file').find('.file_rename_form');
       var input = rename_form.find('.file_rename_input')
       input.val(file_name.text())\
         .keypress(function(event) {
             if (event.keyCode == '13') {
                 $(event.target).closest('.file_rename_form').find('.rename_confirm').click();
             } else if (event.keyCode == '27') {
                 var rename_form = $(event.target).closest('.file').find('.file_rename_form');
                 rename_form.hide();
                 $(event.target).closest('.file').find('.rename_button').show();
                 file_name.show();
             }
         });
       rename_form.show();
       $(event.target).hide();
       file_name.hide();
       input.focus();
    }

    function performFileRename(event) {
       var new_file_name = $(event.target).closest('.file_rename_form').find('.file_rename_input').val();
       var url = $(event.target).closest('.file').children('.rename_url').val();
       $.ajax({type: "POST",
               url: url,
               data: ({new_file_name: new_file_name}),
               success: function(msg){
                  var file_name = $(event.target).closest('.file').find('.filename');
                  var rename_form = $(event.target).closest('.file').find('.file_rename_form');

                  rename_form.hide();

                  $(event.target).closest('.file').find('.rename_button').show();
                  file_name.text(msg);
                  file_name.show();
       }});
    }

    $('.rename_confirm').click(performFileRename);

    $('.new_folder_button').click(function (event) {
        newFolder(event.target);
        return false;
    });

    function updateSizeInformation(section) {
      section = $(section)
      if (section.hasClass('size_indicated')){
        var ids = section[0].id.split('-');
        section_id = ids[1];
        url = $('#file_size_url-'+section_id).val();
        $.post(url,
               {section_id: section_id},
               function(data, textStatus) {
                 section_id = data['section_id'];
                 $('#file_section-'+section_id+' .area_size_points').replaceWith(data['image']);
                 $('#file_section-'+section_id+' .area_size').replaceWith(data['text']);
               },
               'json');

        url = $('#upload_status_url-'+section_id).val();
        $.post(url,
               {section_id: section_id},
               function(data, textStatus) {
                 section_id = data['section_id'];
                 status = String(data['status']);
                 $('#file_section-'+section_id+' .upload_control').addClass('hidden');
                 switch (status) {
                   case "1":
                     $('#file_section-'+section_id+' .file_upload').removeClass('hidden');
                     break;
                   case "2":
                     $('#file_section-'+section_id+' .single_upload').removeClass('hidden');
                     break;
                   case "0":
                     $('#file_section-'+section_id+' .no_upload').removeClass('hidden');
                     $('#file_section-'+section_id+' .upload_forbidden').removeClass('hidden');
                     break;
                 }
               },
               'json');

      }
    }

});
//]]>
</script>
</%def>

<%def name="file(file, new_file=False, hidden=False)">
  %if file.deleted is None:
            <li class="file${hidden and ' show' or ''}">
              %if new_file:
                ${h.image('/images/details/icon_drag_file_new.png', alt='file icon', class_='drag-target')|n}
              %else:
                ${h.image('/images/details/icon_drag_file.png', alt='file icon', class_='drag-target')|n}
              %endif
                ${h.link_to(file.title, file.url(), class_='filename')}
              %if file.can_write():
                <span class="file_rename_form hidden">
                  <span class="file_rename_input_decorator">
                    <input class="file_rename_input" type="text" />
                  </span>
                  ${h.input_submit(_('Rename'), class_='rename_confirm btn')}
                </span>
                <img src="${url('/images/details/icon_rename.png')}" alt="${_('edit file name')}" class="rename_button" />
              %endif
              <span class="size">(${h.file_size(file.size)})</span>
              <span class="date">${h.fmt_dt(file.created_on)}</span>
              <a href="${url(controller='user', action='index', id=file.created_by)}" class="author">
                ${file.created.fullname}
              </a>
              <input class="move_url" type="hidden" value="${file.url(action='move')}" />
              <input class="copy_url" type="hidden" value="${file.url(action='copy')}" />
              <input class="delete_url" type="hidden" value="${file.url(action='delete')}" />
              <input class="flag_url" type="hidden" value="${file.url(action='flag')}" />
              <input class="rename_url" type="hidden" value="${file.url(action='rename')}" />
              <input class="folder_title_value" type="hidden" value="${file.folder}" />
              %if file.can_write():
                <img src="${url('/images/delete.png')}" alt="${_('delete file')}" class="delete_button" />
              %else:
                <img src="${url('/img/icons/flag-small.png')}" alt="${_('flag as suspicious')}" class="flag_button" />
              %endif
            </li>
  %else: ## deleted file
            <li class="file">
              ${h.image('/images/details/icon_drag_file.png', alt='file icon', class_='drag-target')|n}
              <span class="file_name">
                ${file.title}
              </span>
              %if file.folder:
              <span class="folder_title">(${file.folder})</span>
              %endif
              <span class="size">(${h.file_size(file.size)})</span>
              <span class="date">${_('deleted')} ${h.fmt_dt(file.deleted_on)}</span>,
              <a href="${file.deleted.url()}" class="author">
                ${file.deleted.fullname}
              </a>
              <input class="move_url" type="hidden" value="${file.url(action='move')}" />
              <input class="copy_url" type="hidden" value="${file.url(action='copy')}" />
              <input class="restore_url" type="hidden" value="${file.url(action='restore')}" />
              <input class="folder_title_value" type="hidden" value="${file.folder}" />
              <span>
                <img src="${url('/images/restore.png')}" alt="${_('restore file')}" class="restore_button" />
              </span>
            </li>
  %endif
</%def>

<%def name="folder_button(folder, section_id, fid, cls='', title=None)">
  <%
     if title is None and folder.title != '':
         title = folder.title
     elif title is None and folder.title == '':
         title = _('Here')
  %>
  <div class="target_item ${cls}"><div class="upload target" id="file_upload_button-${section_id}-${fid}">${h.ellipsis(title, 17)}</div></div>
</%def>


<%def name="root_folder(folder, section_id, fid)">
      <div class="folder_file_area root_folder" id="file_area-${section_id}-${fid}">
        <input class="folder_name" id="file_folder_name-${section_id}-${fid}" type="hidden" value="${folder.title}" />
        <%
           files = [file for file in folder if file.deleted is None]
           hidden = False
           file_count = len(files)
        %>
          <ul class="folder${file_count > 4 and ' click2show' or ''}">
        % if files:
              <li style="display: none;" class="message">${_("There are no files here, this folder is empty!")}</li>
              % for n, file in enumerate(files):
                <%
                    if n > 2 and file_count > 4:
                        hidden = True
                %>
                %if n == 3 and file_count > 4:
                    <li class="click hide files_more">
                      <span class="green verysmall">
                      ${ungettext("Show the other %(count)s file", "Show the other %(count)s files", file_count - n ) % dict(count = file_count - n)}
                      </span>
                    </li>
                %endif
                <%self:file file="${file}" hidden="${hidden}" />
              % endfor
        % else:
              <li class="message">${_("There are no files here, this folder is empty!")}</li>
        % endif

          </ul>
      </div>
</%def>

<%def name="sub_folder(folder, section_id, fid)">
        <%
           style = ''
           files = [file for file in folder if file.deleted is None]
           file_count = len(files)
           is_open = file_count > 4
           if files:
               style = h.literal('style="display: none;"')
        %>
      <div class="folder_file_area subfolder click2show${bool(files) and ' open' or ''}" id="file_area-${section_id}-${fid}">
        <input class="folder_name" id="file_folder_name-${section_id}-${fid}" type="hidden" value="${folder.title}" />
        <h4 class="${is_open and 'click' or ''}">
          <span class="cont">
            ${folder.title}
            <span class="small">(${ungettext("%(count)s file", "%(count)s files", len(files)) % dict(count=len(files))})</span>
            % if folder.can_write(c.user):
              <a ${style} href="${folder.parent.url(action='delete_folder', folder=folder.title)}" id="delete_folder_button-${section_id}-${fid}" class="delete_folder_button">${_("(Delete)")}</a>
            % endif
          </span>
        </h4>
        <ul class="folder">
        % if files:
              <li style="display: none;" class="message">${_("There are no files here, this folder is empty!")}</li>
              % for n, file in enumerate(files):
                <%self:file file="${file}" hidden="${n > 2}"/>
                %if n == 3 and file_count > 4:
                    <li class="click hide files_more">
                      <span class="green verysmall">
                      ${ungettext("Show the other %(count)s file", "Show the other %(count)s files", file_count - n ) % dict(count = file_count - n)}
                      </span>
                    </li>
                %endif
              % endfor
        % else:
              <li class="message">${_("There are no files here, this folder is empty!")}</li>
        % endif

          </ul>
      </div>
</%def>

<%def name="folder(folder, section_id, fid)">
      %if folder.title == '':
          <%self:root_folder folder="${folder}" section_id="${section_id}" fid="${fid}" />
      %else:
          <%self:sub_folder  folder="${folder}" section_id="${section_id}" fid="${fid}" />
      %endif

</%def>

<%def name="free_space_indicator(obj)">
  ${h.image('/images/details/pbar%d.png' % obj.free_size_points, alt=h.file_size(obj.size), class_='area_size_points')|n}
</%def>

<%def name="free_space_text(obj)">
  <div class="area_size">${_('free space:')} ${h.file_size(obj.free_size)}</div>
</%def>

<%def name="flag_file(f)">
  <form method="post" action="." class="fullForm fileFlagForm">
    <div>
      ${h.input_area('reason', _('Please state the reason why this file is inappropriate:'), cols=30)}
      ${h.input_line('reporter_email', _('Your e-mail (for followup, optional)'))}
      ${h.input_submit(_('Submit'))}
    </div>
  </form>
</%def>

<%def name="file_browser(obj, section_id=0, collapsible=False, title=None, comment=None, controls=['upload', 'folder', 'title'])">

<%prebase:rounded_block class_='portletGroupFiles' id="subject_files">

  <div class="section click2show ${collapsible and '' or 'open'} ${('size' in controls) and 'size_indicated' or ''}" id="file_section-${section_id}">
    <%
       cls_head = cls_container = ''
       if collapsible:
           cls_head = 'click'
           cls_container = 'show'
    %>

    ##%if 'title' in controls:
    <div class="GroupFiles" style="border-bottom: 0">
      <h2 class="portletTitle bold ${cls_head}" style="border-bottom: 0;">
        %if title is None:
        ${h.ellipsis(obj.title, 80)}
        %else:
        ${h.ellipsis(title, 80)}
        %endif
        <span style="font-weight: normal; font-size: 12px">(${ungettext("%(count)s file", "%(count)s files", obj.file_count) % dict(count=obj.file_count)})</span>
        <span class="cont"></span>
        %if 'size' in controls:
            <div style="float: right; margin-top: -10px; margin-right: 8px">
          %if 'size' in controls:
            ${free_space_indicator(obj)}
            <br />
            ${free_space_text(obj)}
          %endif
        </div>
        %endif
        %if 'unlimited' in controls:
        <span class="unlimited_size">${_('unlimited')}</span>
        %endif
      </h2>
    </div>
    ##%endif


    <div class="container ${cls_container}">
      %if comment:
        <div class="comment" style="padding-top: 10px">
          ${comment}
        </div>
      %endif

      %if 'size' in controls:
      <input type="hidden" id="file_size_url-${section_id}"
             value="${obj.url(action='file_info')}" />
      <input type="hidden" id="upload_status_url-${section_id}"
             value="${obj.url(action='upload_status')}" />

      %endif
      <input type="hidden" id="file_upload_url-${section_id}"
             value="${obj.url(action='upload_file')}" />
      <input type="hidden" id="create_folder_url-${section_id}"
             value="${obj.url(action='js_create_folder')}" />
      <input type="hidden" id="delete_folder_url-${section_id}"
             value="${obj.url(action='js_delete_folder')}" />
      <input type="hidden" class="id" value="${obj.id}" />
      %if c.user:
      <div class="controls">
        %if 'upload' in controls:
        <div id="file_upload_progress-${section_id}" class="file_upload_progress">
        </div>
        <%
            n = len(obj.folders)
        %>
        <div class="upload_control no_upload ${'' if obj.upload_status == obj.LIMIT_REACHED else 'hidden'}">
          <table><tr>
              <td>
                <div style="float: left;" class="btn inactive"><div>${_('upload file to...')}</div></div>
              </td>
              <td>
                <a style="float: left;" class="btn" href="${obj.url(action='pay')}" title="${_('Increase file area limits')}">
                  <span>${_('Increase limits')}</span>
                </a>
              </td>
          </tr></table>
        </div>
        <div class="upload_control single_upload ${'' if obj.upload_status == obj.CAN_UPLOAD_SINGLE_FOLDER else 'hidden'}">
          <div class="button"><div class="inner">
            <%self:folder_button folder="${obj.folders[0]}" section_id="${section_id}" fid="${0}" title="${_('Upload file')}" />
          </div></div>
        </div>
        <div class="upload_control file_upload upload_dropdown click2show ${'' if obj.upload_status == obj.CAN_UPLOAD else 'hidden'}">
          <div class="click button">
            <div class="inner">
              ${_('upload file to...')}
            </div>
          </div>
          <div class="show target_list file_upload_dropdown" id="file_upload_dropdown-${section_id}">
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
        %endif

        %if 'folder' in controls:
        <div style="float: left; margin-left: 20px;">
          <form action="${obj.url(action='create_folder')}">
            <div class="folder_controls">
              ${h.input_line('folder', _('New folder:'), class_="new-folder-name", id="new_folder_input-%s"%section_id)}
              ${h.input_submit(_('create'), id="new_folder_button-%s" % section_id, class_="new_folder_button btn")}
            </div>
          </form>
        </div>
        %endif
        <br class="clear-left"/>
        <div class="upload_control upload_forbidden ${'' if obj.upload_status == 0 else 'hidden'}">
          ${_('No more space for private files. We recommend moving files into subjects or upgrading the group.')}
        </div>
      </div>
      %endif
      % for fid, folder in enumerate(obj.folders):
        <%self:folder folder="${folder}" section_id="${section_id}" fid="${fid}" />
      % endfor

      <%
      if h.check_crowds(['moderator'], context=obj):
          style = ''
          files = [file for file in obj.files
                   if (file.deleted is not None and
                       not file.isNullFile())]
          if not files: style = h.literal('style="display: none"')
      else:
          style = h.literal('style="display: none"')
          files = []
      %>
      <div ${style} class="folder_file_area subfolder trash_folder_file_area" id="file_area-${section_id}-trash">
          <h4 class="trash_heading">${_('Trash')}</h4>
          <ul class="folder trash_folder">
        %if files:
              <li style="display: none;" class="message">${_("There are no deleted files.")}</li>
              %for file in files:
                %if file.deleted is not None:
                  <%self:file file="${file}" />
                %endif
              %endfor
        %else:
              <li class="message">${_("There are no deleted files.")}</li>
        %endif
          </ul>
      </div>
    </div>
  </div>

</%prebase:rounded_block>

</%def>
