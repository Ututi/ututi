<%inherit file="/prebase.mako" />

<%def name="portlets()"></%def>
<%def name="portlets_right()"></%def>

<%

# get sidebar contents

left_sidebar = capture(self.portlets)
right_sidebar = capture(self.portlets_right)

# pick CSS classes
# (note that currently we dont support standalone righthand sidebar)

if left_sidebar and right_sidebar:
  classes = 'with-left-sidebar with-right-sidebar'
elif left_sidebar:
  classes = 'with-left-sidebar'
else:
  classes = ''

%>

<div id="layout-wrap" class="${classes} clearfix">
  <div id="main-content">
    <div class="content-inner">
      ${self.flash_messages()}
      ${next.body()}
    </div>
  </div>
  %if left_sidebar:
  <div id="left-sidebar">
    <div class="sidebar-inner">
      ${self.portlets()}
    </div>
  </div>
  %endif
  %if right_sidebar:
  <div id="right-sidebar">
    <div class="sidebar-inner">
      ${self.portlets_right()}
    </div>
  </div>
  %endif
</div>
