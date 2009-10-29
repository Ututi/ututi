<%def name="portlet(id, portlet_class='')">
<div class="sidebar-block ${portlet_class}" id="${id}">
  <div class="rounded-header">
    <div class="rounded-right">
      <h3 id="${id + '_header'}">${caller.header()}</h3>
    </div>
  </div>
  <div class="content" id="${id + '_content'}">
    ${caller.body()}
    <br style="clear: both; height: 1px;"/>
  </div>
</div>
</%def>

<%def name="action_portlet(id, portlet_class='', expanding=False)">
<div class="action-portlet ${portlet_class}" id="${id}">
  <div class="content click2show" id="${id + '_content'}">
    <div class="header ${expanding and 'click clickable' or ''}">
      ${caller.header()}
    </div>
    %if expanding:
      <div class="show body">
        ${caller.body()}
      </div>
    %endif
  </div>
</div>
</%def>
