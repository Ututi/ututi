<%namespace name="prebase" file="/prebase.mako" />
<%namespace file="/elements.mako" import="tooltip" />

<%def name="head_tags()">

<script type="text/javascript">
//<![CDATA[
$(document).ready(function(){

    $('.clickBlock .clickAction').click(function(){
        $(this).closest('.clickBlock').toggleClass('open').find('.showBlock').toggle();
    });

    function folderReceive(event, ui) {

          var move_url = ui.item.find('.move_url').val();
          var copy_url = ui.item.find('.copy_url').val();

          var source_id = ui.sender.parents('.section').children('.container').children('.id').val();
          var target_id = ui.item.parents('.section').children('.container').children('.id').val();
          var target_folder = ui.item.closest('.folder_file_area').find('.folder_name').val();
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
    
	var DOMBody = $('body');
	var FolderList = $('.file_upload_dropdown');
	
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
              $('.upload_dropdown').children('.click').click();
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
          	  FolderList.hide();
              if (response != 'UPLOAD_FAILED') {
                  iframe['progress_ticker'].text("${_('Done')}").parent().addClass('done');
                  window.clearInterval(iframe['interval']);
                  var newFileDomObj = $(response);
                  newFileDomObj.hide();
                  $('.folder', result_area).append(newFileDomObj);
                  newFileDomObj.fadeIn(1000);
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
    DOMBody.click(function(){ FolderList.hide(); });
     
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
        var section_id = $(target[0]).attr('id').split('-')[1];
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
        var url = $(event.target).closest('.file').find('.delete_url').val();
        var section = $(event.target).closest('.section');
        var section_area_id = section[0].id;
        var sid = section_area_id.split('-')[1];
        var trash_bin = $('#file_area-' + sid + '-trash');

        $.ajax({type: "GET",
                url: url,
                success: function(msg){
                    $(event.target).closest('.file').remove();
                    if ($('.file', folder).size() == 0) {
                        $('.message', folder).show();
                        folder.closest('.folder_file_area').find('.delete_folder_button').show();
                    }
                    var new_item = $(msg);
                    trash_bin.show();
                    trash_bin.children('.folder').append(new_item);
                    new_item.parents('.folder').children('.message').hide();
                    updateSizeInformation($(folder).parents('.section'));
        }});
    }

    function flagFile(event) {
        var folder = $(event.target).closest('.folder');
        var url = $(event.target).closest('.file').find('.flag_url').val();

        $.ajax({type: "GET",
                url: url,
                success: function(src){
                    var dlg = $('<div></div>');
                    dlg.html(src);
                    var submit_func = function () {
                        $('form', dlg).ajaxSubmit({
                            url: url,
                            type: 'POST',
                            success: function() {
                                // hide flag link to indicate submission
                                $(event.target).fadeOut(1000);
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
        var url = $(event.target).closest('.file').find('.restore_url').val();
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
                    var folder_name = $(msg).find('.folder_title_value').val();
                    var target_folder_title_attr = section.contents().find('.folder_file_area .folder_name').filter(function (n) { return this.value == folder_name});
                    var target_folder = target_folder_title_attr.closest('.folder_file_area').children('.folder');
                    if (target_folder.size() == 0)
                    {
                        createFolder(section[0].id.split('-')[1], folder_name);
                    }
                    else {
                        target_folder.append(new_item);
                        target_folder.show();
                        new_item.parents('.folder').find('.message').hide();
                        new_item.closest('.folder_file_area').find('.delete_folder_button').hide();
                        updateSizeInformation($(folder).parents('.section'));
                    }
        }});
    }

    $('.delete_button').live('click', deleteFile);
    $('.flag_button').live('click', flagFile);
    $('.restore_button').live('click', restoreFile);
    $('.rename_button').live('click', renameFile);

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
       var trg = this;
       var new_file_name = $(trg).closest('.file_rename_form').find('.file_rename_input').val();
       var url = $(trg).closest('.file').find('.rename_url').val();
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

    $('.rename_confirm').live('click', performFileRename);
    $('.new_folder_button').live('click', function (event) {
        newFolder($(this));
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
	<li class="${file.created.is_teacher and 'teacher-content ' or ''}file${hidden and ' show' or ''}">
		<span class="tooltip-container">
			%if file.created.is_teacher:
				<span class="teacher-tooltip">${tooltip(_("Teacher's material"), img='/img/icons/teacher-cap.png')}</span>
			%endif
		</span>
		<span class="file-description">
			%if new_file: ## catch eye
				${h.image('/img/icons.com/file_move_medium_orange.png', alt='file icon', class_='drag-target')}
			%else:
				${h.image('/img/icons.com/file_move_medium_grey.png', alt='file icon', class_='drag-target')}
			%endif
			${h.link_to(file.title, file.url(), class_='filename')}
			<!--Edit file name -->
			%if file.can_write():
				<span class="file_rename_form hidden">
					<span class="file_rename_input_decorator">
						<input class="file_rename_input" type="text" />
			    	</span>
			    	${h.input_submit(_('Rename'), class_='rename_confirm btn')}
				</span>
			%endif
			<!--FileSize-->
			<span class="size">(${h.file_size(file.size)})</span>
			<input class="move_url" type="hidden" value="${file.url(action='move')}" />
			<input class="copy_url" type="hidden" value="${file.url(action='copy')}" />
			<input class="delete_url" type="hidden" value="${file.url(action='delete')}" />
			<input class="flag_url" type="hidden" value="${file.url(action='flag')}" />
			<input class="rename_url" type="hidden" value="${file.url(action='rename')}" />
			<input class="folder_title_value" type="hidden" value="${file.folder}" />
		</span>
		<span class="file-owner" >
			<a href="${url(controller='user', action='index', id=file.created_by)}" class="author" title="${file.created.fullname}" >
			     ${h.file_name(file.created.fullname)}
			</a>
		</span>
		<span class="file-date" ><span class="date">${h.fmt_normaldate(file.created_on)}</span></span>
		<span class="file-actions" >
			<!--Edit file btn-->
			%if file.can_write():
				<img src="${url('/images/details/icon_rename.png')}" alt="${_('edit file name')}" class="rename_button" />
			%endif
			<!--Delete file BTN-->
			%if file.can_write():
				<img src="${url('/images/delete.png')}" alt="${_('delete file')}" class="delete_button" />
			%elif file.parent.flaggable_files:
				<img src="${url('/img/icons/flag-small.png')}" alt="${_('flag as suspicious')}" class="flag_button" />
			%endif
		</span>
	</li>
	%else: ## deleted file
	<li class="${file.created.is_teacher and 'teacher-content ' or ''}file">
		<span class="tooltip-container">
			%if file.created.is_teacher:
				<span class="teacher-tooltip">
					${tooltip(_("Teacher's material"), img='/img/icons/teacher-cap.png')}
				</span>
			%endif
		</span>
		<span class="file-description">${h.image('/images/details/icon_drag_file.png', alt='file icon', class_='drag-target')}
			<span class="file_name">
				${file.title}
			</span>
		    %if file.folder:
				<span class="folder_title">(${file.folder})</span>
		    %endif
		     <!--FileSize-->
			<span class="size">(${h.file_size(file.size)})</span>
		    <input class="move_url" type="hidden" value="${file.url(action='move')}" />
		    <input class="copy_url" type="hidden" value="${file.url(action='copy')}" />
		    <input class="restore_url" type="hidden" value="${file.url(action='restore')}" />
		    <input class="folder_title_value" type="hidden" value="${file.folder}" />
		</span>
		<span class="file-owner" >
			<a href="${file.deleted.url()}" class="${'author' if file.deleted == file.created else 'deleted-by'}">
		    	${h.file_name(file.deleted.fullname)}
		    </a>
		</span>
		<span class="file-date" ><span class="date">${h.fmt_normaldate(file.deleted_on)}</span></span>
		<span class="file-actions" >
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

<%def name="root_folder(folder, section_id, fid, collapsed)">
	<div class="folder_file_area root_folder click2show" id="file_area-${section_id}-${fid}">
		<input class="folder_name" id="file_folder_name-${section_id}-${fid}" type="hidden" value="${folder.title}" />
        <%
            more_files = False
            more_files_count = 0
            files = [file for file in folder if file.deleted is None]
            # show teacher files before the rest (python sort is stable)
            files.sort(lambda x, y: int(y.created.is_teacher) - int(x.created.is_teacher))
            hidden = False
            file_count = len(files)
            have_hidden_files = False
        %>
		<ul class="folder${file_count >= 4 and ' click2show' or ''}">
	        % if files:
	              <li style="display: none;" class="message">${_("There are no files here, this folder is empty!")}</li>
	              % for n, file in enumerate(files):
	                %if n > 2 and file_count >= 4:
	                	<% hidden = collapsed %>
	                	<% more_files = True %>
                        <% have_hidden_files = True %>
	                	<% more_files_count += 1 %>
	                %endif
	                <%self:file file="${file}" hidden="${hidden}" />
	              % endfor
	        % else:
	              <li class="message">${_("There are no files here, this folder is empty!")}</li>
	        % endif
		</ul>
		<div class="spliter">&nbsp;</div>
          %if more_files:
            <% additional_class = '' if collapsed else 'hide' %>
			<li class="${additional_class} files_more click">
				<span class="green verysmall">
					${ungettext("Show the other %(count)s file", "Show the other %(count)s files", file_count - n ) % dict(count = more_files_count)}
				</span>
			</li>
	      %endif
		</div>
	</div>
</%def>

<%def name="sub_folder(folder, section_id, fid, collapsed)">
	<%
        more_files = False
        more_files_count = 0
        style = ''
        files = [file for file in folder if file.deleted is None]
        # show teacher files before the rest (python sort is stable)
        files.sort(lambda x, y: int(y.created.is_teacher) - int(x.created.is_teacher))
        file_count = len(files)
        is_open = file_count > 4
        if files:
            style = h.literal('style="display: none;"')
        folder_expanded = 'open' if is_open and not collapsed else ''
	%>
	<div class="folder_file_area subfolder click2show ${folder_expanded}" id="file_area-${section_id}-${fid}">
        <input class="folder_name" id="file_folder_name-${section_id}-${fid}" type="hidden" value="${folder.title}" />
        <h4 class="${is_open and 'click' or ''}">
          <span class="cont">
            ${folder.title}
            <span class="small">(${ungettext("%(count)s file", "%(count)s files", len(files)) % dict(count=file_count)})</span>
	            % if folder.can_write(c.user):
	              <a ${style} href="${folder.parent.url(action='delete_folder', folder=folder.title)}" id="delete_folder_button-${section_id}-${fid}" class="delete_folder_button">${_("(Delete)")}</a>
	            % endif
          </span>
        </h4>
		<ul class="folder">
	        %if files:
	              <li style="display: none;" class="message">${_("There are no files here, this folder is empty!")}</li>
	              % for n, file in enumerate(files):
                      <% file_hidden = (n >= 3 and is_open) %>
	                  <%self:file file="${file}" hidden="${file_hidden}"/>
	                  %if n >= 3 and is_open:
                        <% more_files = True %>
                      	<% more_files_count += 1 %>
	                  %endif
	              % endfor
	        %else:
	              <li class="message">${_("There are no files here, this folder is empty!")}</li>
	        %endif
		</ul>
		<div class="spliter">&nbsp;</div>
           %if more_files:
            <% additional_class = '' if collapsed else 'hide' %>
			<li class="${additional_class} files_more click">
	              <span class="green verysmall">
	              	${ungettext("Show the other %(count)s file", "Show the other %(count)s files", more_files_count ) % dict(count = more_files_count)}
	              </span>
	            </li>
	       %endif
	</div>
</%def>

<%def name="folder(folder, section_id, fid, collapsed)">
      %if folder.title == '':
          <%self:root_folder folder="${folder}" section_id="${section_id}" fid="${fid}" collapsed="${collapsed}" />
      %else:
          <%self:sub_folder  folder="${folder}" section_id="${section_id}" fid="${fid}" collapsed="${collapsed}" />
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
      ${h.input_area('reason', _("Please state the reason why the file '%s' is inappropriate:") % f.filename, cols=30)}
      %if not c.user:
        ${h.input_line('reporter_email', _('Your e-mail (optional)'))}
      %endif
      ${h.input_submit(_('Submit'))}
    </div>
  </form>
</%def>

<%def name="upload_control(obj, section_id=0)">
  <input type="hidden" id="file_upload_url-${section_id}"   value="${obj.url(action='upload_file')}" />
  <input type="hidden" id="create_folder_url-${section_id}" value="${obj.url(action='js_create_folder')}" />
  <input type="hidden" id="delete_folder_url-${section_id}" value="${obj.url(action='js_delete_folder')}" />
  <input type="hidden" class="id" value="${obj.id}" />
  <div id="file_upload_progress-${section_id}" class="file_upload_progress"></div>
  <% n = len(obj.folders) %>
  <div class="upload_control no_upload ${'' if obj.upload_status == obj.LIMIT_REACHED else 'hidden'}">
    <table>
    	<tr>
        	<td colspan="2" style="text-align: center;">${h.button_to(_('Increase limits'), obj.url(action='pay'))}</td>
    	</tr>
    </table>
  </div>
  <div class="upload_control single_upload ${'' if obj.upload_status == obj.CAN_UPLOAD_SINGLE_FOLDER else 'hidden'}">
    <div class="button">
    	<div class="inner">
      		<%self:folder_button folder="${obj.folders[0]}" section_id="${section_id}" fid="${0}" title="${_('Upload file')}" />
    	</div>
    </div>
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
</%def>

<%def name="file_browser(obj, section_id=0, collapsible=False, title=None, comment=None, controls=['upload', 'folder', 'title'], files_title='FILES', collapsed=True)">
<%prebase:normal_block class_="portletGroupFiles clickBlock ${collapsible and 'collapsible' or 'open'}" id="subject_files">
	<div class="section ${collapsible and '' or 'open'} ${('size' in controls) and 'size_indicated' or ''}" id="file_section-${section_id}">
	    <%
	       cls_head = cls_container = ''
	       if collapsible:
	           cls_head = 'clickAction'
	           cls_container = 'showBlock'
	    %>
		<div class="GroupFiles" >
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
						${free_space_indicator(obj)}
						<br />
						${free_space_text(obj)}
					</div>
				%endif
				%if 'unlimited' in controls:
					<span class="unlimited_size">${_('unlimited')}</span>
				%endif
	      </h2>
	    </div>

	    <div class="container ${cls_container}">
		%if 'size' in controls:
	        <input type="hidden" id="file_size_url-${section_id}" value="${obj.url(action='file_info')}" />
	        <input type="hidden" id="upload_status_url-${section_id}" value="${obj.url(action='upload_status')}" />
		%endif
		%if c.user:
		<div class="controls filesgroup_controls">
			%if 'upload' in controls:
				${upload_control(obj, section_id=section_id)}
			%endif
			%if 'folder' in controls:
				<div style="float: right; margin-right: 0px; margin-top:-3px;">
					<form action="${obj.url(action='create_folder')}">
						<div class="folder_controls">
							${h.input_line('folder', _('New folder:'), class_="new-folder-name", id="new_folder_input-%s"%section_id)}
							${h.input_submit(_('create'), id="new_folder_button-%s" % section_id, class_="new_folder_button dark add")}
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

		<div class="file-tbl-header" >
			<div class="file-tbl-header-row" >
		      	<div class="hfile-description">${_('Filename')}</div>
		      	<div class="file-owner" >${_('Posted by')}</div>
		      	<div class="file-date" >${_('Date')}</div>
		      	<div class="file-actions" >${_('Action')}</div>
		  	</div>
		</div>

		<div class="folder_file_area subfolder click2show" >
		    <h3 class="">
		      <span class="cont" >
				${files_title}
		      </span>
		    </h3>
		</div>

		<div class="folders_container">
			% for fid, folder in enumerate(obj.folders):
				<%self:folder folder="${folder}" section_id="${section_id}" fid="${fid}" collapsed="${collapsed}"/>
			% endfor
		</div>

		<%
		if h.check_crowds(['moderator'], context=obj):
			style = ''
			files = [file for file in obj.files
			         if (file.deleted is not None and
			             not file.isNullFile())]
			# show teacher files before the rest (python sort is stable)
			files.sort(lambda x, y: int(y.created.is_teacher) - int(x.created.is_teacher))
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
				          <%self:file file="${file}" />
				      %endfor
				%else:
				      <li class="message">${_("There are no deleted files.")}</li>
				%endif
			</ul>
		</div>
	</div>
</%prebase:normal_block>
</%def>
