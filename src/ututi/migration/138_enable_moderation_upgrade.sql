update groups set mailinglist_moderated = true;

alter table groups alter column mailinglist_moderated set default true;
