<%def name="title_box(title, class_='', id=None, style=None)">
  <div class="title-box ${class_}"
       %if id is not None:
         id="${id}"
       %endif

       %if style is not None:
         style="${style}"
       %endif
  >
    <div class="title">
      ${title}
    </div>
    <div class="content">
      ${caller.body()}
    </div>
  </div>
</%def>

<%def name="rounded_block(class_='', id=None, style=None)">
<div class="rounded-block ${class_}"
     %if id is not None:
       id="${id}"
     %endif

     %if style is not None:
       style="${style}"
     %endif
>
  <div class="ctl"></div>
  <div class="ctr"></div>
  <div class="cbl"></div>
  <div class="cbr"></div>

  ${caller.body()}
</div>
</%def>

<%def name="light_table(title, items, class_='')">
<%self:rounded_block class_="light-table ${class_}">
  <div class="single-title">
    <div class="floatleft">
      <h2 class="portletTitle bold category-title">${title}</h2>
    </div>
    <div class="clear"></div>
  </div>
  <table style="width: 100%" class="content">
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
</%self:rounded_block>
</%def>

<%def name="item_list(title, items, class_='')">
<% if hasattr(caller, 'footer'): class_ += ' with-footer' %>
<%self:rounded_block class_="item-list ${class_}">
  <div class="large-header with-shade underline">
    <h2 class="portletTitle bold category-title">
      ${title}
      %if hasattr(caller, 'header_link'):
      <span class="header-link">
        ${caller.header_link()}
      </span>
      %endif
    </h2>
    %if hasattr(caller, 'header_button'):
    <span class="header-button">
      ${caller.header_button()}
    </span>
    %endif
    <div class="clear"></div>
  </div>

  %if items:
    %for item in items[:-1]:
    <div class="row">
      ${caller.row(item)}
    </div>
    %endfor
    <div class="row last">
      ${caller.row(items[-1])}
    </div>
  %elif hasattr(caller, 'empty_rows'):
    <div class="empty">
      ${caller.empty_rows()}
    </div>
  %endif

  %if hasattr(caller, 'footer'):
  <div class="footer">
    ${caller.footer()}
  </div>
  %endif
</%self:rounded_block>
</%def>
