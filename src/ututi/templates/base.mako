<%inherit file="/prebase.mako" />

<%def name="portlets()"></%def>
<%def name="portlets_secondary()"></%def>

<%

# get sidebar contents

first_sidebar_content = capture(self.portlets)
second_sidebar_content = capture(self.portlets_secondary)

first_sidebar = bool(first_sidebar_content.strip())
second_sidebar = bool(second_sidebar_content.strip())

# count sidebars and pick CSS classes

if first_sidebar and second_sidebar:
  layout = 'two-sidebars'
elif first_sidebar:
  layout = 'one-sidebar'
else:
  layout = ''

%>

<div id="layout-wrap" class="${layout} clearfix">
  <div id="main-content">
    <div class="content-inner">
      ${self.flash_messages()}
      ${next.body()}
    </div>
  </div>
  %if first_sidebar:
  <div id="first-sidebar">
    <div class="sidebar-inner">
      ${h.literal(first_sidebar_content)}
    </div>
  </div>
  ## for current layout second sidebar is only possible
  ## if first one is present
  %if second_sidebar:
  <div id="second-sidebar">
    <div class="sidebar-inner">
      ${h.literal(second_sidebar_content)}
    </div>
  </div>
  %endif
  %endif
</div>

<%def name="form(filler)">
  ${filler(capture(caller.body))}
</%def>
