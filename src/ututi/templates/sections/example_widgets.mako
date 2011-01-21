<%inherit file="/ubase-width.mako" />
<%namespace file="/widgets/dropdown.mako" name="d" import="dropdown, head_tags, js" />

<%def name="head_tags()">
  ${d.head_tags()}
  ${d.js()}
</%def>

${d.dropdown('ex', 'The widget',
  [('abc', 'abc ajdsfljadsf fasd asdf asdf a x'),
   ('cda', 'cdaasdf ad adsfasdf'),
   ('dfg', 'dfg'),
   ('aaa', 'aaa asdf adsf saf asdf a')])}
