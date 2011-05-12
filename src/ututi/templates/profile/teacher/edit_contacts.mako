<%inherit file="/profile/teacher/edit_base.mako" />
<%namespace name="contacts" file="/profile/edit_contacts.mako" />

<%def name="pagetitle()">${_("Contacts")}</%def>

${contacts.form()}

