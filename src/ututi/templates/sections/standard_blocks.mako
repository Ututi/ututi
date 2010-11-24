
<%def name="light_table(title, items, class_)">
<div class="portlet portletSmall portletGroupFiles mediumTopMargin ${class_}">
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
  <table style="width: 100%">
    %if hasattr(caller, 'header'):
    <tr>
      ${caller.header(items)}
    </tr>
    %endif
    %for item in items[:-1]:
    <tr>
      ${caller.row(item)}
    </tr>
    %endfor
    %if hasattr(caller, 'footer'):
    <tr>
      ${caller.row(items[-1])}
    </tr>
    <tr class="last">
      ${caller.footer(items)}
    </tr>
    %else:
    <tr class="last">
      ${caller.row(items[-1])}
    </tr>
    %endif
  </table>
</div>
</%def>
