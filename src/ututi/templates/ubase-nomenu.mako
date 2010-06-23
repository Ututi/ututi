<%inherit file="/prebase.mako" />
<%def name="anonymous_menu()"></%def>
<%def name="body_class()">
  noMenu
</%def>
${self.flash_messages()}
${next.body()}
