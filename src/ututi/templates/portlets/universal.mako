<%inherit file="/portlets/base.mako"/>

<%def name="quick_file_upload_portlet(targets, label=None)">
%if len(targets) > 0:
  <%self:action_portlet id="file_upload_portlet" expanding="True" label='${label}'>
    <%def name="header()">
      <span class="blark">${_('upload a file to..')}</span>
    </%def>
    <div id="completed">
    </div>
    <script type="text/javascript">
    //<![CDATA[
    $(document).ready(function(){

      function setUpUpload(i, btn) {
        var button = $(btn);
        var upload_url = $(btn).siblings('input').val();
        var list = $('#completed');
        new AjaxUpload(button,{
          action: upload_url,
          name: 'attachment',
          data: {folder: ''},
          onSubmit : function(file, ext, iframe){
              %if label is not None:
                _gaq.push(['_trackEvent', 'action_portlets', 'upload_file', '${label}']);
              %endif
              iframe['progress_indicator'] = $(document.createElement('div'));
              $(list).append(iframe['progress_indicator']);
              iframe['progress_indicator'].text(file);
              iframe['progress_ticker'] = $(document.createElement('span'));
              iframe['progress_ticker'].appendTo(iframe['progress_indicator']).text(' Uploading');
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
              iframe['progress_indicator'].replaceWith($('<div></div>').append($(response).children('a')));
              window.clearInterval(iframe['interval']);
          }
      });
    };
     $('.upload .target').each(setUpUpload);
    });
    //]]>
    </script>
    <%
       n = len(targets)
    %>
    <div class="comment">${_('Quickly upload files to your groups and subjects.')}</div>
    %for obj in targets:
    <div class="upload target_item">
      <input type="hidden" name="upload_url" value="${obj.url(action='upload_file_short')}"/>
      <div class="target">${h.ellipsis(obj.title, 35)}</div>
    </div>
    %endfor
  </%self:action_portlet>
%endif
</%def>

<%def name="share_portlet(object)">
  %if c.user is not None and hasattr(object, 'share_info'):
  <%
    info = object.share_info
  %>
  <%self:uportlet id="share-portlet">
    <%def name="header()">
      ${_("Share with your friends")}
    </%def>
    <p>
      ${_("Found it interesting? Share with your friends!")}
    </p>
    <ul id="share-portlet-action-list">
      <li id="facebook-share"><a href="#share-via-facebook" id="facebook-share-link">${"Via facebook"}</a></li>
      <li id="email-share"><a href="#share-via-email" id="email-share-link">${"Via e-mail"}</a></li>
    </ul>

    <div id="email-share-dialog">
      <form action="${url(controller='profile', action='send_email_message_js')}" method="POST" class="new-style-form">
        <%
        subject = _("Here's what I've found in Ututi") + ': ' + info['title']
        message = "\n\n---\n\n%(title)s\n\n%(description)s\n\n%(link)s" % \
          dict(title=info['title'], description=info['description'], link=info['link'])
        %>
        ${h.input_line('recipients', _("Recipients"),
                       help_text=_("Enter comma separated list of email addresses"))}
        ${h.input_line('subject', _("E-mail subject"), value=subject)}
        ${h.input_area('message', _("Message"), value=message)}
        ## Prevent floating left
        <div>
          ${h.input_submit(_("Send"), class_='btnMedium', id='email-submit-button')}
        </div>
      </form>
      <p id="feedback-message">${_("Your email was successfully sent.")}</p>
    </div>

    <script type="text/javascript">
      //<![CDATA[
      $(document).ready(function() {
        $("#facebook-share-link").click(function() {
          FB.ui(
            {
              method: 'feed',
              name: '${info['title']}',
              link: '${info['link']}',
              %if 'caption' in info:
              caption: '${info['caption']}',
              %endif
              message: "${_("Here's what I've found in Ututi")}" + '!',
              description: '${info['description']}',
              picture: '${url("/img/site_logo_collapsed.gif", qualified=True)}'
            }
          );
          return false;
        });

        $('#email-share-dialog').dialog({
            title: '${_("Send via email")}',
            width: 350,
            autoOpen: false
        });

        $("#email-share-link").click(function() {
          $('#email-share-dialog').dialog('open');
          return false;
        });

        $('#email-submit-button').click(function(){
            var form = $(this).closest('form');
            var action_url = form.attr('action');

            $.post(action_url,
                   form.serialize(),
                   function(data, status) {
                       if (data.success != true) {
                           // remove older error messages
                           $('.error-message').remove();
                           for (var key in data.errors) {
                               var error = data.errors[key];
                               $('#'+key).parent().after($('<div class="error-message">'+error+'</div>'));
                           }
                       }
                       else {
                           // show feedback to user
                           $('#email-share-dialog').addClass('email-sent').delay(1000).queue(function() {
                             // close and clean up
                             $(this).dialog('close');
                             $(this).removeClass('email-sent');
                             $(this).find('#recipients').val('');
                             $(this).dequeue();
                           });
                       }
                   },
                   "json");

            return false;
        });

      });
      //]]>
    </script>
  </%self:uportlet>
  %endif
</%def>
