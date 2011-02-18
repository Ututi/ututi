<%inherit file="/ubase-width.mako" />
<%namespace file="/widgets/dropdown.mako" name="d" import="dropdown, head_tags, js" />
<%namespace file="/widgets/vote.mako" name="v" import="voting_widget" />

<%def name="head_tags()">
  ${d.head_tags()}
</%def>

${d.dropdown('ex', 'The widget',
  [('abc', 'abc ajdsfljadsf fasd asdf asdf a x'),
   ('cda', 'cdaasdf ad adsfasdf'),
   ('dfg', 'dfg'),
   ('aaa', 'aaa asdf adsf saf asdf a')])}

%for votes in range(0, 501, 50):
${v.voting_widget(votes)}
%endfor
