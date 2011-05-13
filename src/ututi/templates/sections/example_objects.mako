<%inherit file="/base.mako" />
<%namespace file="/sections/standard_objects.mako" import="subject_listitem, group_listitem" />

<h3>A subject list item (e.g. in the user's home):</h3>
${subject_listitem(c.subject, 0)}

<h3>A group list item (e.g. in the user's home):</h3>
${group_listitem(c.group, 0)}
