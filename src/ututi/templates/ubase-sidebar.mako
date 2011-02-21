<%inherit file="/prebase.mako" />

<%def name="portlets()">
</%def>

<div id="aside">
  ${self.portlets()}
</div>
<div id="mainContent">
  ${self.flash_messages()}
  ${next.body()}
</div>
