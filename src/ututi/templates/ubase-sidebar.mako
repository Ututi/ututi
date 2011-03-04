<%inherit file="/base.mako" />

<%def name="portlets()"></%def>

<div id="layout-wrap" class="with-left-sidebar clearfix">
  <div id="main-content">
    <div class="content-inner">
      ${self.flash_messages()}
      ${next.body()}
    </div>
  </div>
  <div id="left-sidebar">
    <div class="sidebar-inner">
      ${self.portlets()}
    </div>
  </div>
</div>
