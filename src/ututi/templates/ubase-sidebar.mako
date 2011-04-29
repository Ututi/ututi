<%inherit file="/prebase.mako" />

<%def name="portlets()">
</%def>

<div id="mainContent">
  ${self.flash_messages()}
  ${next.body()}
</div><div id="aside">
  %if c.lang == 'pl':
  <!-- Ututi.com hardcoded banner -->
  <a href="http://ututi.com" style="display: block; margin-bottom: 15px; outline: none">
    <img src="/img/go_ututi_com_pl.png" alt="Go to Ututi.com" />
  </a>
  %endif
  ${self.portlets()}
</div>
