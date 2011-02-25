<%inherit file="/prebase.mako" />

<%def name="portlets()"></%def>
<%def name="portlets_right()"></%def>

<div id="layout-wrap" class="with-left-sidebar with-right-sidebar clearfix">
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
  <div id="right-sidebar">
    <div class="sidebar-inner">
      ${self.portlets_right()}
    </div>
  </div>
</div>
