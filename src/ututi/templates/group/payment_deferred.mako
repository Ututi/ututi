<%inherit file="/group/base.mako" />

<h1>${_("Paying for the group is not possible at the moment")}</h1>
<br />
${_("At the moment payments for the group's file limit cannot be made.")}

<div style="text-align: right;">
  <a class="more" url="${c.group.url(action='files')}">${_("Back to the group's files")}</a>
</div>
