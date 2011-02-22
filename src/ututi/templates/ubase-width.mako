<%inherit file="/prebase.mako" />

<div id="layout-wrap">
  <div id="main-content">
     ${self.flash_messages()}
     ${next.body()}
  </div>
</div>
