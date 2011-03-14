alter table group_mailing_list_messages add constraint reply_to
foreign key (reply_to_message_id, reply_to_group_id) references group_mailing_list_messages(message_id, group_id);

alter table group_mailing_list_messages add constraint thread
foreign key (thread_message_id, thread_group_id) references group_mailing_list_messages(message_id, group_id);

alter table group_mailing_list_messages drop column reply_to_message_machine_id;

alter table group_mailing_list_messages drop column thread_message_machine_id;
