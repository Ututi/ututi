<%inherit file="/base.mako" />

<%def name="head_tags()">
${parent.head_tags()}
</%def>

<h1>Payment testing page</h1>

${h.button_to("Dummy pay", c.accepturl)}

${h.link_to("Process payment", c.callbackurl)}

${h.link_to("Go back", c.cancelurl)}
