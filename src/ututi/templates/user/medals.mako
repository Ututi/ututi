<%inherit file="/base.mako" />
<%namespace file="/portlets/user.mako" import="*"/>

<%def name="portlets()">
  ${profile_portlet(user=c.user_info)}
  ${user_statistics_portlet(user=c.user_info)}
  ${user_medals(user=c.user_info)}
</%def>

<h1 style="font-weight: bold">${c.user_info.fullname}</h1>

${h.link_to(_('Back to profile'), c.user_info.url(action='index'))}

% if c.user_info.medals:
  <h1>${_('Current medals')}</h1>

  <table>
  % for medal in c.user_info.medals:
    <tr>
      <td>
        ${h.button_to(_('Take away'),
                      c.user_info.url(action='take_away_medal', medal_id=medal.id))}
      </td>
      <td>
        ${medal.img_tag()}
      </td>
      <td>
        ${medal.title()}
      </td>
    </tr>
  % endfor
  </table>
% endif

<h1 style="clear: left; margin-top: 1em">${_('Award a medal')}</h1>

<table>
% for medal in c.available_medals:
  % if medal.medal_type not in [m.medal_type for m in c.user_info.medals]:
  <tr>
    <td>
      ${h.button_to(_('Award'),
          c.user_info.url(action='award_medal', medal_type=medal.medal_type))}
    </td>
    <td>
      ${medal.img_tag()}
    </td>
    <td>
      ${medal.title()}
    </td>
  </tr>
  % endif
% endfor
</table>
