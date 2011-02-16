<%inherit file="/registration/base.mako" />

<%def name="css()">
  ${parent.css()}
  #photo-preview {
    float: left;
    margin-right: 40px;
  }
  #photo-preview img {
    padding: 5px;
    border: 1px solid #666666;
  }
  #skip-link {
    float: right;
    margin-top: 30px;
  }
  #add-photo-form {
  }
</%def>

<%def name="pagetitle()">${_("Add your photo")}</%def>

<div id="photo-preview">
  <img src="${url(controller='registration', action='logo', id=c.registration.id, size=140)}" />
</div>

<form id="add-photo-form"
      action="${c.registration.url(action='add_photo')}"
      enctype="multipart/form-data"
      method="POST">

  <p>
    ${_("Select an image file on your computer:")}
  </p>

  <input type="file" name="photo" />
  <form:error name="photo" />

  <p id="file-status">
    ${_("You have not chosen any picture yet")}
  </p>

  ${h.input_submit(_("Next"))}
  <a id="skip-link" href="${c.registration.url(action='invite_friends')}">
    ${_("Skip")}
  </a>
</form>
