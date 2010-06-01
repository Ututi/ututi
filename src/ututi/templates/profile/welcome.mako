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

