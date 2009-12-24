<%inherit file="/group/home.mako" />

${_('By paying for the group, you will get an unlimited file area for 6 months.')}

<form action="${c.paymentform.action}" method="POST">
  %for key, val in c.paymentform.fields:
  <input type="hidden" name="${key}" value="${val}" />
  %endfor
  <span class="btn-large">
    <input type="submit" value="${_('Pay for group extension.')}" />
  </span>
</form>
