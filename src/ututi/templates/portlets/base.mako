<%def name="portlet(id, portlet_class='')">
<div class="sidebar-block ${portlet_class}" id="${id}">
  <div class="rounded-header">
    <div class="rounded-right">
      <h3 id="${id + '_header'}">${caller.header()}</h3>
    </div>
  </div>
  <div class="content" id="${id + '_content'}">
    ${caller.body()}
  </div>
</div>
</%def>
