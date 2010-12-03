
<%def name="light_table(title, items, class_)">
<div class="portlet portletSmall portletGroupFiles mediumTopMargin ${class_}">
  <div class="ctl"></div>
  <div class="ctr"></div>
  <div class="cbl"></div>
  <div class="cbr"></div>
  <div class="single-title">
    <div class="floatleft">
      <h2 class="portletTitle bold category-title">${title}</h2>
    </div>
    <div class="clear"></div>
  </div>
  <table style="width: 100%">
    %if items:
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
    %elif hasattr(caller, 'empty_rows'):
      ${caller.empty_rows()}
    %endif
  </table>
</div>
</%def>

<%def name="item_list(title, items, class_)">
<div class="rounded_block ${class_}">
  <div class="ctl"></div>
  <div class="ctr"></div>
  <div class="cbl"></div>
  <div class="cbr"></div>
  <div class="large_header">
    <h2 class="portletTitle bold category-title">
      ${title}
      %if hasattr(caller, 'header_link'):
      <span class="header_link">
        ${caller.header_link()}
      </span>
      %endif
    </h2>
    %if hasattr(caller, 'header_button'):
    <span class="header_button">
      ${caller.header_button()}
    </span>
    %endif
    <div class="clear"></div>
  </div>
  <div>
    %if items:
      %for item in items[:-1]:
        <div class="row">
          ${caller.row(item)}
        </div>
      %endfor
      %if hasattr(caller, 'last_row'):
        <div class="row last">
          ${caller.last_row(items[-1])}
        </div>
      %else:
        <div class="row">
          ${caller.row(items[-1])}
        </div>
      %endif
    %elif hasattr(caller, 'empty_rows'):
      <div class="empty">
        ${caller.empty_rows()}
      </div>
    %endif
  </div>
</div>
</%def>
