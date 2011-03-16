<%inherit file="/portlets/base.mako"/>

<%def name="item_box(items, with_titles=False)">
  <%
  per_row = 3 if with_titles else 4
  rows = [items[i:i + per_row] for i in range(0, len(items), per_row)]
  %>
  <div class="item-box ${'with-titles' if with_titles else ''}">
  %for row in rows:
    <div class="item-row clearfix">
      %for item in row:
      <div class="item">
        <a href="${item['url']}">
          <% logo_url = item['logo_url'] if with_titles else item['logo_small_url'] %>
          <img src="${logo_url}"
               class="item-logo"
               alt="${item['title']}"
               title="${item['title']}" />
          %if with_titles:
          <div class="item-title">
            ${item['title']}
          </div>
          %endif
        </a>
      </div>
      %endfor
    </div>
  %endfor
  </div>
</%def>

<%def name="users_online_portlet(count=12)">
  <% users = h.users_online(count) %>
  %if users:
  <%self:portlet id="users-online-portlet">
    <%def name="header()">
      ${_("People online:")}
    </%def>
    ${item_box(users)}
  </%self:portlet>
  %endif
</%def>

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

<%def name="share_portlet(object, title=None)">
  %if hasattr(object, 'share_info'):
  <% info = object.share_info %>
  <%self:portlet id="share-portlet">
    <%def name="header()">
      %if title is None:
        ${_("Tell a friend:")}
      %else:
        ${title}
      %endif
    </%def>
    <ul class="icon-list">
      <li class="icon-facebook"><a href="#share-facebook" id="facebook-share-link">${"Facebook"}</a></li>
      <li class="icon-email"><a href="#share-email" id="email-share-link">${"Email"}</a></li>
    </ul>

    <div id="email-share-dialog">
      <form action="${url(controller='profile', action='send_email_message_js')}" method="POST" class="new-style-form">
        <%
        subject = _("Here's what I've found in Ututi") + ': ' + info['title']
        message = "%(title)s\n\n%(description)s\n\n%(link)s" % \
          dict(title=info['title'], description=info['description'], link=info['link'])
        %>
        %if c.user is None:
        ${h.input_line('sender', _("Your email"))}
        %else:
        <input type="hidden" name="sender" value="${c.user.emails[0].email}" />
        %endif
        ${h.input_line('recipients', _("Recipients"),
                       help_text=_("Enter comma separated list of email addresses"))}
        ${h.input_line('subject', _("E-mail subject"), value=subject)}
        ${h.input_area('message', _("Message"), value=message)}
        ${h.input_submit(_("Send"), id='email-submit-button')}
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
              description: '${h.single_line(info['description'])}',
              picture: '${url("/img/site_logo_collapsed.gif", qualified=True)}'
            }
          );
          return false;
        });

        $('#email-share-dialog').dialog({
            title: '${_("Send email")}',
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
                             $('.error-message').remove();
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
  </%self:portlet>
  %endif
</%def>

<%def name="google_ads_portlet()">
  %if c.user is None:
  <%self:portlet id="google-ads-portlet">
    <script type="text/javascript">
      <!--
      google_ad_client = "pub-1809251984220343";
      google_ad_slot = "4000532165";
      google_ad_width = 160;
      google_ad_height = 250;
      //-->
    </script>
    <script type="text/javascript" src="http://pagead2.googlesyndication.com/pagead/show_ads.js"></script>
  </%self:portlet>
  %endif
</%def>

