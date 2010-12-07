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
  <img src="${url('/img/icons/bigX_15x15.png')}" />
</a>
</%def>
