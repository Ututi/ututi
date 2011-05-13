<%inherit file="/base.mako" />

<%def name="body_class()">registration</%def>
<%def name="pagetitle()">${_("Registration")}</%def>

<%def name="css()">
  ${parent.css()}
  #registration-page-container {
    width: 845px !important;
    margin: auto;
  }
  button.next {
    margin-top: 20px;
  }
  ul#registration-steps {
    width: 845px !important;
    height: 40px !important;
    background-image: url('/img/registration_steps_bg.png');
    background-repeat: no-repeat;
    list-style: none;
    margin-bottom: 20px;
  }
  ul.step-1 { background-position: center    0px; }
  ul.step-2 { background-position: center  -50px; }
  ul.step-3 { background-position: center -100px; }
  ul.step-4 { background-position: center -150px; }
  ul#registration-steps li {
    width: 211px !important;
    height: 35px !important;
    overflow: hidden;
    float: left;
    margin-top: 5px;
    text-align: center;
  }
  ul#registration-steps li.active {
    color: white;
    font-weight: bold;
  }
  ul#registration-steps li span.step-number {
    display: block;
    font-weight: bold;
  }
  ul#registration-steps li span.step-title {
    display: block;
    font-size: 10px;
  }
</%def>

<div id="registration-page-container">

  %if hasattr(c, 'steps') and hasattr(c, 'active_step') and c.active_step:
  <%
  active_num = 0
  for n, (id, title) in enumerate(c.steps, 1):
    if id == c.active_step: active_num = n
  %>
  <ul id="registration-steps" class="step-${active_num}">
    %for n, (id, title) in enumerate(c.steps, 1):
      %if id == c.active_step:
      <li class="active">
      %else:
      <li>
      %endif
        <span class="step-number">${_("Step %(step_num)s") % dict(step_num=n)}</span>
        <span class="step-title">${title}</span>
      </li>
    %endfor
  </ul>
  %endif

  <h1 class="page-title registration underline">${self.pagetitle()}</h1>

  ${next.body()}

</div>
