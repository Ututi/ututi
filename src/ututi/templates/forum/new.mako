<%inherit file="/forum/thread.mako" />

<%def name="title()">
${_('New topic')}
</%def>

<h1>${_('New topic')}</h1>

<form method="post" action="${url(controller='groupforum', action='post', id=c.group.group_id)}"
     id="group_add_form" enctype="multipart/form-data">
  <div class="form-field">
    <label for="subject">${_('Subject')}</label>
    <input type="text" id="subject" name="subject" class="line"/>
  </div>
  <div class="form-field">
    <label for="message">${_('Message')}</label>
    <textarea class="line" name="message" id="message" cols="80" rows="25"></textarea>
  </div>
  <div>
    <span class="btn">
      <input type="submit" value="${_('Post')}"/>
    </span>
  </div>
</form>
