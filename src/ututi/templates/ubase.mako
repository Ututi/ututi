<%inherit file="/base.mako" />

<div id="layout-wrap" class="clearfix">
  <div id="main-content">
    <div class="content-inner">
      ${self.flash_messages()}
      ${next.body()}
    </div>
  </div>
</div>
