<%inherit file="/profile/base.mako" />
<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>

<%def name="head_tags()">
${parent.head_tags()}
<%newlocationtag:head_tags />
</%def>

<%def name="location_updated()">
  <div id="user_location">
    <div class="wrapper">
      <div class="inner" style="height: 50px; font-weight: bold;">
        <br />
        ${_('Your university information has been updated. Thank You.')}
      </div>
    </div>
  </div>

</%def>

%if c.user.location is None:
<%self:rounded_block id="user_location" class_="portletSetLocation">
<div class="inner">
  <h2 class="portletTitle bold">${_('Tell us where you are studying')}</h2>
  <form method="post" action="${url(controller='profile', action='update_location')}" id="update-location-form">
    ${location_widget(2, add_new=(c.tpl_lang=='pl'), live_search=True, label_class="label")}
    ${h.input_submit(_('save'), id='user-location-submit')}
  </form>
</div>
</%self:rounded_block>
  <script type="text/javascript">
  //<![CDATA[

  $('#user-location-submit').click(function() {
    $('#user_location').addClass('loading');
    $.post('${url(controller='profile', action='js_update_location')}',
      $(this).parents('form').serialize(),
      function(data, status) {
        if (status == 'success') {
          $('#user_location .inner').replaceWith(data);
        }
        $('#user_location').removeClass('loading');
      });
    return false;
  });
  //]]>
  </script>
%endif

%if not c.user.hide_suggest_create_group:
<%self:rounded_block id="user_location" class_="portletNewGroup">
  <div class="floatleft usergrupeleft">
    <h2 class="portletTitleBold">${_('Create a group')}</h2>
    <p>${_("It's simple - you only need to know the email addresses of your group mates!")}</p>
    <p>${_("Use the group's mailing list!")}</p>
  </div>
  <div class="floatleft usergruperight">
    <form action="${url(controller='group', action='group_type')}" method="GET">
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
        $(this).closest('.portlet').hide();
        $.post('${url(controller='profile', action='js_hide_element')}',
               {type: 'hide_suggest_create_group'});
        return false;
    });
  //]]>
  </script>

</%self:rounded_block>
%endif

%if not c.user.hide_suggest_watch_subject:
<%self:rounded_block id="user_location" class_="portletNewDalykas">
  <div class="floatleft usergrupeleft">
    <h2 class="portletTitle bold">${_('Tell us what you are studying')}</h2>
    <ul>
      <li>${_('Find materials shared by others')}</li>
      <li>${_('Get notifications about changes')}</li>
    </ul>
  </div>
  <div class="floatleft usergruperight">
    <form action="${url(controller='profile', action='subjects')}" method="GET">
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
        $(this).closest('.portlet').hide();
        $.post('${url(controller='profile', action='js_hide_element')}',
               {type: 'hide_suggest_watch_subject'});
        return false;
    });
  //]]>
  </script>

</%self:rounded_block>
%endif
