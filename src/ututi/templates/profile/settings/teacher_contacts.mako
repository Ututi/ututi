<%inherit file="/profile/settings/teacher_base.mako" />
<%namespace name="contacts" file="/profile/settings/contacts.mako" />

<%def name="pagetitle()">${_("Contacts")}</%def>

${contacts.form()}

