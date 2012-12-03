<%inherit file="/profile/home_base.mako" />

<%def name="css()">
${parent.css()}
.steps .step {
  padding: 20px 0 10px 0;
  border-bottom: 1px solid #eeeeee;
}
.steps .step.complete {
  opacity: 0.75;
}
.steps .heading {
  position: relative;
}
.steps .step .heading .number {
  position: absolute;
  left: 0px;
}
.steps .step .heading .title {
  position: absolute;
  left: 30px;
  top: 2px;
  font-weight: bold;
}
.steps .step .content {
  margin: 30px 0 0 30px;
}
.alternative-link {
  font-size: 11px;
  margin-top: 5px;
}
.steps .step .side-box {
  float: right;
  border-color: #eee;
}
.steps .step .side-box .title {
  border-bottom: none;
}
.steps .step .side-box .content {
  margin: 0; /* reset content margin */
}
</%def>

<%def name="pagetitle()">
%if hasattr(c, 'welcome'):
  ${_("Welcome to VUtuti")}
%else:
  ${_("Get started")}
%endif
</%def>

%if hasattr(c, 'welcome'):
<div id="welcome-message">
  ${h.literal(_('Welcome to <strong>%(university)s</strong> private social network '
  'created on <a href="%(url)s">VUtuti platform</a>. '
  'Here students and teachers can create groups online, use the mailinglist for '
  'communication and the file storage for sharing information.' % dict(university=c.user.location.title, url=url('/features'))))}
</div>
%endif

${next.body()}
