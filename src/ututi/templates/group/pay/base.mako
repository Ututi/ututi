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
  "You can do this.") % dict(limit = h.file_size(c.group_file_limit))}
  </div>
  <div class="static-content">
    ${_('By paying Your group will be able to store an <strong>unlimited amount of files</strong>:')|n}
  </div>

  %for period, amount, form in c.filearea_payments:
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

  <div class="static-content">
    ${_('You can also pay for group space by SMS.')}
    ${_('First, get some credits by sending an SMS "<strong>TXT&nbsp;%(sms_code2)s&nbsp;%(group_id)s</strong>" (2 Lt) or "<strong>TXT&nbsp;%(sms_code10)s&nbsp;%(group_id)s</strong>" (10 Lt) to the number 1337.') % dict(group_id=c.group.group_id, sms_code2=c.pylons_config.get('fortumo.group_space_small.code', 'UFILES2'), sms_code10=c.pylons_config.get('fortumo.group_space_large.code', 'UFILES10')) |n}
    ## TODO: pay by bank
    ${_('1 month costs 10 credits, 3 months cost 20 credits, 6 months cost 30 credits.') |n}
  </div>

  <div>${_('You have <strong>%d</strong> credits.') % c.group.private_files_credits |n}</div>

  %if c.group.private_files_lock_date:
    <div>${_('Your private file area is available until <strong>%s</strong>.') % c.group.private_files_lock_date.date().isoformat() |n}</div>
  %endif

  %if h.check_crowds(['admin']):
    %if c.group.private_files_credits < 10:
      ${_('You need more credits to buy group space.')}
    %endif
    %if c.group.private_files_credits >= 10:
      ${h.button_to(_('Purchase 1 month for 10 credits'), url.current(months=1))}
    %endif
    %if c.group.private_files_credits >= 20:
      ${h.button_to(_('Purchase 3 months for 20 credits'), url.current(months=3))}
    %endif
    %if c.group.private_files_credits >= 30:
      ${h.button_to(_('Purchase 6 months for 30 credits'), url.current(months=6))}
    %endif
  %else:
    <div>${_('Only admins can spend credits to purchase space. Ask your group admin once there are enough credits in your account.')}</div>
  %endif

  %if c.testing:
    <div style="padding-top: 1em">
      ${h.button_to(_('Gimme 5 credits!'), url.current(give=5))}
    </div>
  %endif

</%def>

${next.body()}
