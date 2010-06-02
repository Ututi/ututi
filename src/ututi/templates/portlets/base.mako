##new style portlet
<%def name="uportlet(id, portlet_class='')">
<div id="${id}-header" class="module-top ${portlet_class}"><h2>${caller.header()}</h2></div>
<div id="${id}-content" class="portlet portletSmall portletModule ${portlet_class}">
  <div class="cbl"></div>
  <div class="cbr"></div>
  ${caller.body()}
</div>
</%def>

<%def name="portlet(id, portlet_class='')">
<div class="sidebar-block ${portlet_class}" id="${id}">
  <div class="rounded-header">
    <div class="rounded-right">
      <h3 id="${id + '_header'}">${caller.header()}</h3>
    </div>
  </div>
  <div class="content" id="${id + '_content'}">
    ${caller.body()}
    <br style="clear: both; line-height: 0; display: block;"/>
  </div>
</div>
</%def>

<%def name="action_portlet(id, portlet_class='', expanding=False, label=None)">
<div class="action-portlet ${portlet_class}" id="${id}">
  <div class="content click2show" id="${id + '_content'}">
    <div class="header ${expanding and 'click clickable' or ''}">
      ${caller.header()}
    </div>
    %if label is not None:
    <script type="text/javascript">
    //<![CDATA[
      $("#${id+'_content'} .click").click(function() {
        _gaq.push(['_trackEvent', 'action_portlets', 'open', '${label}']);
      });
    //]]>
    </script>
    %endif
    %if expanding:
      <div class="show body">
        ${caller.body()}
      </div>
    %endif
  </div>
</div>
</%def>

<%def name="border_portlet(id, portlet_class='')">
<div class="border-portlet ${portlet_class}" id="${id}">
  <div class="body">
    ${caller.body()}
  </div>
</div>
</%def>
