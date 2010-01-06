<%inherit file="/group/pay/en.mako" />

<h1>${_("Make your group's file space unlimited")}</h1>
<br />
${_("The amount of group's private files is limited to %(limit)s. This is so because Ututi "
"encourages users to store their files in publicly accessible subjects where they can "
"be shared with all the users. But if You want to keep more than %(limit)s of files, "
"You can do this.") % dict(limit = h.file_size(c.group_file_limit))}

<div class="orange_emph">
  ${_('By paying Your group will be able to store an <em>unlimited amount of files</em>:')|n}
</div>

%for period, amount, form in c.payments:
<div style="margin: 5px; float: left;">
  <form action="${form.action}" method="POST">
    %for key, val in form.fields:
      <input type="hidden" name="${key}" value="${val}" />
    %endfor
    <span class="btn-large">
      <input type="submit" value="${_('%d Lt') % (int(amount) / 100) }" />
    </span>
    <span class="larger">
      - ${period}
    </span>
  </form>
</div>
%endfor
<br class="clear-left" />
<div style="text-align: right;">
  <a class="more" url="${c.group.url(action='files')}">${_("Back to the group's files")}</a>
</div>
