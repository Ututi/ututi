<%inherit file="/uprebase.mako" />

<div id="mainContent">
   ${self.flash_messages()}
   ${next.body()}
</div>
