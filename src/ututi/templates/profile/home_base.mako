<%inherit file="/ubase-two-sidebars.mako" />
<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/elements.mako" import="tabs" />
<%namespace file="/portlets/sections.mako" import="user_sidebar, user_right_sidebar"/>
<%namespace file="/widgets/facebook.mako" import="init_facebook" />

<%def name="portlets()">
${user_sidebar()}
</%def>

<%def name="portlets_right()">
${user_right_sidebar()}
</%def>

<%def name="head_tags()">
${parent.head_tags()}
<%newlocationtag:head_tags />
</%def>

%if hasattr(self, 'pagetitle'):
  <h1 class="page-title with-bottom-line">${self.pagetitle()}</h1>
%endif

<%def name="phone_confirmed()">
<div id="phone_confirmed">
  <div class="wrapper">
    <div class="inner" style="height: 50px; font-weight: bold;">
      <br />
      ${_('Your phone has been confirmed. Thank you.')}
    </div>
  </div>
</div>
</%def>

<%def name="location_nag(message)">
<%self:rounded_block id="user_location" class_="portletSetLocation">
<div class="inner">
  <h2 class="portletTitle bold">${message}</h2>
  <form method="post" action="${url(controller='profile', action='update_location')}" id="update-location-form"
        style="float: none">
    ${location_widget(2, add_new=(c.tpl_lang=='pl'), label_class="label")}
    ${h.input_submit(_('save'), id='user-location-submit')}
    <div id="location-error" class="error-container" style="display: none"><span class="error-message">${_('Please enter a university.')}</span></div>
  </form>
</div>
</%self:rounded_block>

<script type="text/javascript">
  //<![CDATA[

  $('#user-location-submit').click(function() {
    if (!($('#location-0-0').val())) {
      $('#location-error').show();
      return false;
    }
    $('#user_location').addClass('loading');
    $.post('${url(controller='profile', action='js_update_location')}',
      $(this).parents('form').serialize(),
      function(data, status) {
        if (status == 'success') {
          $('#user_location').replaceWith(data);
        }
        $('#user_location').removeClass('loading');
      });
    return false;
  });
  //]]>
</script>
</%def>

<%def name="location_updated()">
<div class="my-faculty"><a href="${c.user.location.url()}">${_('Go to my department')}</a></div>
</%def>

<%def name="phone_nag()">

<%self:rounded_block id="user_phone" class_="portletConfirmPhone">
<div class="inner">
  <h2 class="portletTitle bold">${_("What's your phone number?")}</h2>
  <p class="explanation">
    ${_("We need your phone number so that you could send and receive SMS messages from the group. Don't worry, we will never send advertisements.")}
  </p>
  <form method="post" action="${url(controller='profile', action='update_phone_number')}" id="update-phone-number-form"
        style="float: none; padding-top: 5px">
    <div class="floatleft">
      ${h.input_line('phone_number', _('Mobile phone number: '))}
      <div id="phone-error" style="display: none; padding-left: 135px" class="error-container"><span class="error-message">${_('Please enter a phone number.')}</span></div>
      <div id="user-phone-invalid" style="display: none; padding-left: 135px" class="error-container">
        <span class="error-message">
          ${_('The entered phone number is invalid.')}
          <br />
          ${_('(use the format +37067812345)')}
        </span>
      </div>
    </div>
    <div class="floatleft" style="padding-left: 3px; margin-top: -1px">
      ${h.input_submit(_('save'), id='user-phone-submit')}
    </div>
    <div class="right_cross"><a id="hide_suggest_enter_phone" href="">${_('no, thanks')}</a></div>
    <div class="clear"></div>
  </form>
</div>
</%self:rounded_block>

<script type="text/javascript">
  //<![CDATA[
    $('#hide_suggest_enter_phone').click(function() {
        $(this).closest('.rounded-block').hide();
        $.post('${url(controller='profile', action='js_hide_element')}',
               {type: 'suggest_enter_phone'});
        return false;
    });

  $('#user-phone-submit').click(function() {
    $('#user-phone-invalid').hide();
    $('#phone-error').hide();

    if (!($('#phone_number').val())) {
      $('#phone-error').show();
      return false;
    }
    $('#user_phone').addClass('loading');
    $.post('${url(controller='profile', action='js_update_phone')}',
      $(this).parents('form').serialize(),
      function(data, status) {
        if ((status == 'success') && (data != '')) {
          $('#user_phone').replaceWith(data);
        } else {
          $('#user-phone-invalid').show();
        }
        $('#user_phone').removeClass('loading');
      });
    return false;
  });
  //]]>
</script>
</%def>

<%def name="phone_confirmation_nag()">
<%self:rounded_block id="user_phone_confirm" class_="portletConfirmPhone">
<div class="inner">
  <h2 class="portletTitle bold">${_("Please confirm your phone number")}</h2>
  <p class="explanation">
    ${_("Enter the confirmation code that you received by SMS to prove that this number belongs to you.")}
  </p>
  <form method="post" action="${url(controller='profile', action='confirm_phone_number')}" id="confirm-phone-number-form"
        style="float: none; padding-top: 5px ">
    <div class="floatleft">
      ${h.input_line('phone_confirmation_key', _('Confirmation code: '))}
      <div id="phone-confirmation-code-missing" style="display: none; padding-left: 115px" class="error-container"><span class="error-message">${_('Please enter a confirmation key.')}</span></div>
      <div id="phone-confirmation-code-invalid" style="display: none; padding-left: 115px" class="error-container"><span class="error-message">${_('Invalid confirmation key.')}</span></div>
    </div>
    <div class="floatleft" style="padding-left: 3px; margin-top: -1px">
      ${h.input_submit(_('save'), id='confirmation-code-submit')}
    </div>
    <div class="clear"></div>
  </form>
</div>
</%self:rounded_block>
<script type="text/javascript">
  //<![CDATA[

  $('#confirmation-code-submit').click(function() {
    $('#phone-confirmation-code-invalid').hide();
    if (!($('#phone_confirmation_key').val())) {
      $('#phone-confirmation-code-missing').show();
      return false;
    }
    $('#phone-confirmation-code-missing').hide();
    $('#user_phone_confirm').addClass('loading');
    $.post('${url(controller='profile', action='js_confirm_phone')}',
      $('form#confirm-phone-number-form').serialize(),
      function(data, status) {
        if ((status == 'success') && (data != '')) {
          $('#user_phone_confirm div.inner').html(data);
          $('#confirm-phone-flash-message').hide();
          //$('#user_phone_confirm').hide();
        } else {
          $('#phone-confirmation-code-invalid').show();
        }
        $('#user_phone_confirm').removeClass('loading');
      });
    return false;
  });
  //]]>
</script>
</%def>

<%def name="watch_subject_nag()">
<%self:rounded_block id="user_location" class_="portletNewDalykas">
<div class="floatleft usergrupeleft">
  <h2 class="portletTitle bold">${_('Watch subjects you are studying!')}</h2>
  <ul id="prosList">
    <li>${_('Find materials shared by others')}</li>
    <li>${_('Get notifications about changes')}</li>
  </ul>
</div>
<div class="floatleft usergruperight">
  <form action="${url(controller='profile', action='watch_subjects')}" method="GET"
        style="float: none">
    <fieldset>
      <legend class="a11y">${_('Watch subject')}</legend>
      <label><button value="submit" class="btnMedium"><span>${_('watch subjects')}</span></button>
      </label>
    </fieldset>
  </form>
  <div class="right_cross"><a id="hide_suggest_watch_subject" href="">${_('no, thanks')}</a></div>
</div>
<br class="clear-left" />
<script type="text/javascript">
  //<![CDATA[
    $('#hide_suggest_watch_subject').click(function() {
        $(this).closest('.rounded-block').hide();
        $.post('${url(controller='profile', action='js_hide_element')}',
               {type: 'suggest_watch_subject'});
        return false;
    });
  //]]>
</script>

</%self:rounded_block>
</%def>

<%def name="create_group_nag()">
<%self:rounded_block id="user_location" class_="portletNewGroup">
<div class="floatleft usergrupeleft">
  <h2 class="portletTitle bold">${_('Create a group')}</h2>
  <p>${_("It's simple - you only need to know the email addresses of your classmates!")}</p>
  <p>${_("Use the group's mailing list!")}</p>
</div>
<div class="floatleft usergruperight">
  <form action="${url(controller='group', action='create')}" method="GET"
        style="float: none">
    <fieldset>
      <legend class="a11y">${_('Create group')}</legend>
      <label><button value="submit" class="btnMedium"><span>${_('create group')}</span></button>
      </label>
    </fieldset>
  </form>
  <div class="right_cross"><a id="hide_suggest_create_group" href="">${_('no, thanks')}</a></div>
</div>
<br class="clear-left" />
<script type="text/javascript">
  //<![CDATA[
      $('#hide_suggest_create_group').click(function() {
          $(this).closest('.rounded-block').hide();
          $.post('${url(controller='profile', action='js_hide_element')}',
                 {type: 'suggest_create_group'});
          return false;
      });
    //]]>
</script>
</%self:rounded_block>
</%def>

<%def name="homepage_nags_and_stuff()">

  %if not c.user.groups and 'suggest_create_group' not in c.user.hidden_blocks_list:
  ${self.create_group_nag()}
  %endif

  %if c.user.location is None:
  ${self.location_nag(_('Tell us where you are studying'))}
  %endif

  %if c.user.phone_number is None and not 'suggest_enter_phone' in c.user.hidden_blocks_list:
  ${self.phone_nag()}
  %elif not c.user.phone_confirmed and c.user.phone_number is not None:
  ${self.phone_confirmation_nag()}
  %endif

  %if c.fb_random_post:
  ${init_facebook()}
  <script type="text/javascript">
      //<![CDATA[
      $(document).ready(function() {
          FB.ui({
              method: 'stream.publish',
              message: '${c.fb_random_post}',
              attachment: {
                  name: 'Ututi - your university online',
                  description: (
                      '${_("Ututi is Your university online. "
                           "Here You and Your class mates can create your group online, "
                           "use the mailing list for communication and the file storage for sharing information.")}'
                  ),
                  href: '${url('/', qualified=True)}'
               },
               action_links: [ { text: 'Labas rytas', href: 'ututi.lt' } ],
               user_message_prompt: '${_('Share your thoughts about Ututi')}'
             },
             function(response) { }
         );
      });
      //]]>
  </script>
  %endif
</%def>

${next.body()}
