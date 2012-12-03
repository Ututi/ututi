<%inherit file="/group/base.mako" />

<%def name="group_menu()">
</%def>

<div class="back-link">
  <a class="back-link" href="${c.group.url(action='files')}">
    ${_("Go to the group's files")}</a>
</div>

<h1>${_("Make your group's file space unlimited")}</h1>
<div class="static-content">
  ${_("The amount of group's private files is limited to %(limit)s. This is so because VUtuti "
  "encourages users to store their files in publicly accessible subjects where they can "
  "be shared with all the users. But if You want to keep more than %(limit)s of files, "
  "You can do this.") % dict(limit = h.file_size(c.group.group_file_limit()))}
</div>
<div class="static-content">
  ${_('There are no ways to pay for additional group space at the moment.')|n}
</div>

<br class="clear-left" />
