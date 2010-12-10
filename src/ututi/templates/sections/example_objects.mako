<%inherit file="/ubase-width.mako" />
<%namespace file="/sections/standard_objects.mako" import="subject_listitem" />

<h3>A subject list item (e.g. in the user's home):</h3>
${subject_listitem(c.subject, 0)}
