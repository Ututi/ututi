<%inherit file="/group/base.mako" />

<%def name="group_menu()">
</%def>

<%def name="pay_text()">
  <div class="back-link">
    <a class="back-link" href="${c.group.url(action='files')}">
      ${_("Go to the group's files")}</a>
  </div>

  <h1>${_("Make your group's file space unlimited")}</h1>
  <div class="static-content">
  ${_("The amount of group's private files is limited to %(limit)s. This is so because Ututi "
  "encourages users to store their files in publicly accessible subjects where they can "
  "be shared with all the users. But if You want to keep more than %(limit)s of files, "
  "You can do this.") % dict(limit = h.file_size(c.group.group_file_limit()))}
  </div>
  <div class="static-content">
    ${_('By paying Your group will be able to store an <strong>unlimited amount of files</strong>:')|n}
  </div>

  %for period, amount, form in c.group.filearea_payments():
  <div style="margin: 5px; float: left;">
    <form action="${form.action}" method="POST">
      %for key, val in form.fields:
        <input type="hidden" name="${key}" value="${val}" />
      %endfor
        ${h.input_submit(_('%d Lt') % (int(amount) / 100), class_='btnLarge')}
      <span class="larger">
        - ${period}
      </span>
    </form>
  </div>
  %endfor
  <br class="clear-left" />

</%def>

${next.body()}
