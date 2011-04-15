<%inherit file="/group/create_base.mako" />
<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace name="b" file="/sections/standard_blocks.mako" import="title_box"/>

<%def name="css()">
  ${parent.css()}
  #about-groups,
  #found-groups {
    width: 300px;
    float: right;
  }
</%def>

<div class="clearfix">

  <%b:title_box title="${_('About groups')}" id="about-groups">
    <ul class="feature-list">
      <li class="discussions">
        <strong>${_("Discussions")}</strong>
        - ${_("a place to discuss study matters and your student life.")}
      </li>
      <li class="email">
        <strong>${_("Email address")}</strong>
        - ${_("each group has an email address. If someone writes to this address, all groupmates will receive the email.")}
      </li>
      <li class="private-file">
        <strong>${_("Private group files")}</strong>
        - ${_("each group has a private file storage area for files that you don't want to share with outsiders.")}
      </li>
      <li class="subject">
        <strong>${_("Subject notifications")}</strong>
        - ${_("receive notifications from subjects that your group is following.")}
      </li>
    </ul>
  </%b:title_box>

  <%b:title_box title="${_('Recommended groups')}" id="found-groups" style="display: none">
    <div class="ajax-content search-results-container"></div>
    <script type="text/javascript">
    //<![CDATA[
      $(document).ready(function() {
        $('select#year, input.structure-complete').change(function() {
          var parameters = {
            'location-0': $('#location-0-0').val(),
            'location-1': $('#location-0-1').val(),
            'year': $('#year').val()
          };
          $('#found-groups .ajax-content').load('${url(controller="group", action="js_group_search")}', parameters);
          $('#about-groups').hide();
          $('#found-groups').show();
        });
      });
    //]]>
    </script>
  </%b:title_box>

  ${self.path_steps(1)}

  <form method="post" action="${url(controller='group', action='create')}" enctype="multipart/form-data" class="block-errors">
    <fieldset>
      ${self.location_field()}
      ${self.year_field()}
      ${self.group_title_field()}
      ${self.group_id()}
      ${self.logo_field()}
      ${self.description_field()}
      ${h.input_submit(_('Continue'), id="continue-button")}
    </fieldset>
  </form>

</div>
