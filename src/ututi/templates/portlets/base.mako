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
<div class="portlet ${portlet_class}" id="${id}">
  <div class="portlet-inner clearfix">
    %if hasattr(caller, 'header'):
      <div class="header">
        ${caller.header()}
      </div>
    %endif
      <div class="content">
        ${caller.body()}
      </div>
    %if hasattr(caller, 'footer'):
      <div class="footer">
        ${caller.footer()}
      </div>
    %endif
  </div>
</div>
</%def>

<%def name="action_portlet(id, portlet_class='', expanding=False, show_body=None, label=None)">
<%
if show_body is None:
   show_body = expanding
%>
<div class="action-portlet ${portlet_class}" id="${id}">
  <div class="content ${'click2show' if expanding else ''}" id="${id + '_content'}">
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
    %if show_body:
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
