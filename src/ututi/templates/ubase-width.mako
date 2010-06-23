<%inherit file="/prebase.mako" />

<div id="mainContent">
   ${self.flash_messages()}
   ${next.body()}
</div>
