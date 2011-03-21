alter table group_mailing_list_messages drop constraint reply_to;
alter table group_mailing_list_messages drop constraint thread;

alter table group_mailing_list_messages add column
      reply_to_message_machine_id int8 default null
      references group_mailing_list_messages(id) on delete cascade;

alter table group_mailing_list_messages add column
      thread_message_machine_id int8 default null
      references group_mailing_list_messages(id) on delete cascade;

alter table group_mailing_list_messages disable trigger all;

update group_mailing_list_messages gg
  set thread_message_machine_id = (select id from group_mailing_list_messages g
    where g.message_id = gg.thread_message_id and
          g.group_id = gg.thread_group_id);

update group_mailing_list_messages gg
  set reply_to_message_machine_id = (select id from group_mailing_list_messages g
    where g.message_id = gg.reply_to_message_id and
          g.group_id = gg.reply_to_group_id);

CREATE OR REPLACE FUNCTION set_thread_id() RETURNS trigger AS $$
    DECLARE
        lookup_id int8 := NULL;
        n_thread_group_id int8 := NULL;
        n_thread_message_id varchar(320) := NULL;
        n_thread_message_machine_id int8 := NULL;

        n_reply_to_message_id varchar(320) := NULL;
        n_reply_to_group_id int8 := NULL;

    BEGIN
        IF NEW.reply_to_message_machine_id is NULL THEN
          NEW.thread_message_id := NEW.message_id;
          NEW.thread_group_id := NEW.group_id;
          NEW.thread_message_machine_id := NEW.id;
        ELSE
          lookup_id := NEW.reply_to_message_machine_id;
          SELECT thread_message_id,
                 thread_group_id,
                 thread_message_machine_id,
                 message_id,
                 group_id
            INTO n_thread_message_id,
                 n_thread_group_id,
                 n_thread_message_machine_id,
                 n_reply_to_message_id,
                 n_reply_to_group_id
            FROM group_mailing_list_messages
            WHERE id = lookup_id;

          NEW.thread_message_id := n_thread_message_id;
          NEW.thread_group_id := n_thread_group_id;
          NEW.thread_message_machine_id := n_thread_message_machine_id;

          NEW.reply_to_message_id := n_reply_to_message_id;
          NEW.reply_to_group_id := n_reply_to_group_id;
        END IF;
        RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

alter table group_mailing_list_messages enable trigger all;
