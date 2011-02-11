<%inherit file="/registration/base.mako" />

<%def name="pagetitle()">${_("Add your photo")}</%def>

<div id="photo-preview">
</div>

<form id="add-photo-form"
      action="${url(controller='registration', action='add_photo', hash=c.registration.hash)}"
      enctype="multipart/form-data"
      method="POST">

  <p>
    ${_("Select an image file on your computer:")}
  </p>

  <input type="file" name="photo" class="line" />
  <form:error name="photo" />

  <p id="file-status">
    ${_("You have not chosen any picture yet")}
  </p>

  <a id="skip-link" href="${url(controller='registration', action='invite_friends', hash=c.registration.hash)}">
    ${_("Skip")}
  </a>
  ${h.input_submit(_("Next"))}
</form>
