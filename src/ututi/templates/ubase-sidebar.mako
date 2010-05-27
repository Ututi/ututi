<%inherit file="/ubase.mako" />

<%def name="portlets()">
</%def>

<div id="mainContent">
  ${next.body()}
</div><div id="aside">
  ${self.portlets()}
</div>
