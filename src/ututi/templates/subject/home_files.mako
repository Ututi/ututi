<%inherit file="/subject/base.mako" />
<%namespace name="files" file="/sections/files.mako" />

<div id="file-browser">
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
