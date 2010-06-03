<%inherit file="/uprebase.mako" />

<%def name="portlets()">
</%def>

<div id="mainContent">
  ${self.flash_messages()}
  ${next.body()}
</div><div id="aside">
  ${self.portlets()}
</div>
