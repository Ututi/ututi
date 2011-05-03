<%inherit file="/portlets/base.mako"/>
<%namespace file="/elements.mako" import="item_box" />
<%namespace file="/widgets/facebook.mako" import="init_facebook" />

<%def name="about_ututi_portlet()">
  <%self:portlet id="about-ututi-portlet">
    <%def name="header()">
      ${_("About Ututi:")}
    </%def>
    <p>
    ${_("Ututi lets you create a social network for your university. "
        "Here you will find online groups, teacher profiles and course pages. "
        "Ututi is a tool to share information and build your online academic community.")}
    </p>
    <a href="${url(controller='home', action='features')}">${_("Learn more...")}</a>
  </%self:portlet>
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

    ${init_facebook()}
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

<%def name="about_portlet(user=None)">
  <% if user is None: user = c.user %>
  <%self:portlet id="about-portlet">
    <p>${h.literal(_('This is the verified network for <strong>%s</strong>.\
      Only %s students and teachers can join this network.') % (user.location.title, user.location.title_short))}</p>
  </%self:portlet>
</%def>

<%def name="contacts_portlet()">
  <%self:portlet id="about-portlet">
    <%def name="header()">
         ${_("Contact information:")}
    </%def>
    <p><strong>UAB "Ututi"</strong></p>
    <p>Upės str. 5, Vilnius<br />Lithuania</p>
    <p>Email: <a href="mailto:info@ututi.com">info@ututi.com</a><br />
       Mobile phone: +370 683 79238</p>
    <p>Company number: 302495065<br />
       VAT number: LT10000510316</p>
  </%self:portlet>
</%def>
