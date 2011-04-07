<%inherit file="/profile/edit.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
</%def>

<div id="general-information-settings">
  <form method="post" action="${url(controller='profile', action='update_biography')}" name="edit_biography_form" enctype="multipart/form-data" class="new-style-form"> 
    <h1 class="page-title">${_('Your biography')}:</h1>

    <fieldset>
      <div class="formField">
        <label for="description">
          <span class="labelText">${_('Enter some facts from your biography')}</span>
        </label>
        <textarea class="line ckeditor" name="description" id="description" cols="70" rows="10"></textarea>
      </div>
      ${h.input_submit(_('Save'))}
    </fieldset>
  </form>
</div>
