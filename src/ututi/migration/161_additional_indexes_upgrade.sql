create index user_location_idx on users (location_id);
create index group_mailing_list_messages_reply_to_idx on group_mailing_list_messages (reply_to_group_id, reply_to_message_id);
create index group_mailing_list_messages_thread_idx on group_mailing_list_messages (thread_group_id, thread_message_id);
