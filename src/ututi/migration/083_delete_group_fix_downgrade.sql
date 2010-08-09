ALTER TABLE outgoing_group_sms_messages DROP CONSTRAINT outgoing_group_sms_messages_group_id_fkey;
ALTER TABLE outgoing_group_sms_messages ADD FOREIGN KEY (sender_id) REFERENCES users(id);
ALTER TABLE outgoing_group_sms_messages DROP CONSTRAINT outgoing_group_sms_messages_sender_id_fkey;
ALTER TABLE outgoing_group_sms_messages ADD FOREIGN KEY (group_id) REFERENCES groups(id);

ALTER TABLE received_sms_messages DROP CONSTRAINT received_sms_messages_group_id_fkey;
ALTER TABLE received_sms_messages ADD FOREIGN KEY (sender_id) REFERENCES users(id);
ALTER TABLE received_sms_messages DROP CONSTRAINT received_sms_messages_sender_id_fkey;
ALTER TABLE received_sms_messages ADD FOREIGN KEY (group_id) REFERENCES groups(id);

ALTER TABLE sms_outbox DROP CONSTRAINT sms_outgoing_group_message_id_fkey;
ALTER TABLE sms_outbox ADD FOREIGN KEY (outgoing_group_message_id) REFERENCES outgoing_group_sms_messages(id);

