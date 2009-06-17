<%def name="title()">
${_('student information online')}
</%def>

<%def name="head_tags()">
</%def>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <link rel="stylesheet" href="style.css" type="text/css" media="screen" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    ${self.head_tags()}
    <title>
      ${_('UTUTI')} - ${self.title()}
    </title>
  </head>

  <body>
    <div id="container">
      <div id="header">
        <div id="personal-box" class="rounded-block">
          <div class="rounding rounded-header">
            <div class="rounded-right"></div>
          </div>
          <div class="content">
            forma
          </div>
          <div class="rounding rounded-footer">
            <div class="rounded-right"></div>
          </div>
        </div>

        <a href="#" title="home" id="ulogo">
          <img src="logo.png" alt="logo"/>
        </a>

        <div id="content-top">
          <div></div>
        </div>
      </div>

      <div id="content">
        <div id="sidebar">
          <div class="sidebar-block">
            <div class="rounded-header">
              <div class="rounded-right">
                <h3><a href="#">antraštė</a></h3>
              </div>
            </div>
            <div class="content">
              content
            </div>
          </div>
        </div>

        <div class="inside" id="page-content">
          ${self.body()}
        </div>

      </div>

      <div id="footer">
        <div id="content-bottom">
          <div></div>
        </div>

        Copyright <a href="#">UAB „Nous“</a>
        <div id="footer-links">
          <a href="#">aaaaa</a> |
          <a href="#">aaasdfasdaa</a> |
          <a href="#">aaa dasfaa</a>
        </div>

      </div>
    </div>

  </body>
</html>
