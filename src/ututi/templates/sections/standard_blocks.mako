
<%def name="light_table(title, items, class_)">
<div class="portlet portletSmall portletGroupFiles mediumTopMargin">
  <div class="ctl"></div>
  <div class="ctr"></div>
  <div class="cbl"></div>
  <div class="cbr"></div>
  <div class="single-title">
    <div class="floatleft bigbutton2">
      <h2 class="portletTitle bold category-title">${title}</h2>
    </div>
    <div class="clear"></div>
  </div>
  <table class="${class_}" style="width: 100%">
    %if hasattr(caller, 'header'):
    <tr>
      ${caller.header(items)}
    </tr>
    %endif
    %for item in items:
    <tr>
      ${caller.row(item)}
    </tr>
    %endfor
    %if hasattr(caller, 'footer'):
      <tr class="last">
        ${caller.last_row(items)}
      </tr>
    %endif
  </table>
</div>
</%def>
