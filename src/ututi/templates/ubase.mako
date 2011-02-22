<%inherit file="/prebase.mako" />

<div id="layout-wrap">
  ${self.flash_messages()}
  ${next.body()}
</div>

