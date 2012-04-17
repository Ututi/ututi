<%inherit file="/prebase.mako" />

<%def name="portlets()"></%def>
<%def name="portlets_secondary()"></%def>

<div id="layout-wrap" class="clearfix">
  <div id="main-content">
    <div class="content-inner">
      ${self.flash_messages()}
      ${next.body()}
    </div>
  </div>
</div>
