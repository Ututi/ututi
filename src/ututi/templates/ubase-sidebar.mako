<%inherit file="/prebase.mako" />

<%def name="portlets_left()"></%def>
<%def name="portlets_right()"></%def>

<div id="layout-wrap" class="with-right-sidebar">
  <div id="left-sidebar">
    ${self.portlets_left()}
  </div>
  <div id="right-sidebar">
    ${self.portlets_right()}
  </div>
  <div id="main-content">
    ${self.flash_messages()}
    ${next.body()}
  </div>
</div>
