alter table group_mailing_list_messages disable trigger all;
alter table group_mailing_list_messages add column new_original text null;
update group_mailing_list_messages set new_original = text(original);
alter table group_mailing_list_messages drop column original;
alter table group_mailing_list_messages rename new_original to original;
alter table group_mailing_list_messages enable trigger all;
