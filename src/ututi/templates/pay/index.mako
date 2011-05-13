<%inherit file="/base.mako" />

<%def name="head_tags()">
${parent.head_tags()}
</%def>

<h1>Payment testing page</h1>

<p>
${h.button_to("Dummy pay %s %s" % (c.amount, c.currency), c.accepturl)}
</p>

<p>
  ${h.link_to("Go back", c.cancelurl)}
</p>

<p>
${h.link_to("Process payment",
            c.callbackurl)}
</p>
