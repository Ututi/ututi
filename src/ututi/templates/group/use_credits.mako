<%inherit file="/group/base.mako" />

<h2>${_("Use limits to purchase private files area!")}</h2>

<div>${_('You have %d credits') % c.group.private_files_credits}</div>
<div>${_('Your private file area is available until %s') % c.group.private_files_lock_date}</div>

% if c.group.private_files_credits > 10:
  ${h.button_to(_('Purchase 1 month for 10 credits'), url.current(months=1))}
% endif
% if c.group.private_files_credits > 20:
  ${h.button_to(_('Purchase 3 months for 20 credits'), url.current(months=3))}
% endif
% if c.group.private_files_credits > 30:
  ${h.button_to(_('Purchase 6 months for 30 credits'), url.current(months=6))}
% endif
