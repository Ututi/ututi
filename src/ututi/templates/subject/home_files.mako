<%inherit file="/subject/base.mako" />
<%namespace name="files" file="/sections/files.mako" />

<%def name="upload_files_nag()">
<%self:rounded_block class_='subject-intro-block' id="subject-intro-block-files">
  <h2 style="margin-top: 5px">${_('Upload study material')}</h2>
  <p>${_('You may upload course notes, solutions, examples, and everything else that does not violate copyright.')}</p>

  <h2>${_('Why is Ututi file storage superior to others?')}</h2>
  <ul class="subject-intro-message">
    <li>
      ${_('Ututi files are associated with a specific course at a specific university, so they are much easier to find.')}
    </li>
    <li>
    ${_('Files may be uploaded and downloaded by anyone, so they are easier to share between all students taking a given course.')}
    </li>
    <li>
    ${_('You can upload <strong>very large</strong> files, so you do not need to worry about available space or delete old files to upload new ones.')|n}
    </li>

    ${h.button_to(_('Upload files'), "", id='upload-files-button')}
  </ul>
</%self:rounded_block>
</%def>

%if not c.subject.n_files(False):
  ${upload_files_nag()}
%endif

<div id="file-browser" ${"style='display: none'" if not c.subject.n_files(False) else ''}>
  <%files:file_browser obj="${c.subject}" title="${_('Subject files')}" controls="['upload', 'folder']" />
</div>

<script>
  //<![CDATA[
    $('#upload-files-button').click(function() {
      $('#subject-intro-block').hide();
      $('#subject-intro-block-files').hide();
      $('#file-browser').show("slow");
      $('#subject-tabs').show();
      %if not c.subject.n_pages():
        $('#page-intro').show();
      %endif
      return false;
    });
  //]]>
</script>
