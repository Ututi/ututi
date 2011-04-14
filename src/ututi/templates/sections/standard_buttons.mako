<%def name="close_button(target_url, class_=None, id=None)">
<a 
  href="${target_url}"
  %if id is not None:
  id="${id}"
  %endif
  %if class_ is not None:
  class="${class_}"
  %endif
>
  <img src="${url('/img/icons.com/close.png')}" />
</a>
</%def>

<%def name="watch_button(target_url, class_=None, id=None)">
<% if class_ is None: class_ = '' %>
${h.button_to(_("Watch"), target_url, class_='btn ' + class_, id=id)}
</%def>

<%def name="teach_button(target_url, class_=None, id=None)">
<% if class_ is None: class_ = '' %>
${h.button_to(_("I teach this"), target_url, class_='btnMedium btnTeacher ' + class_, id=id)}
</%def>
