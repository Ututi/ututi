insert into events(created, event_type, author_id, recipient_id, private_message_id)
 select ci.created_on, 'private_message_sent', msg.sender_id, msg.recipient_id, msg.id from private_messages msg
   inner join content_items ci on ci.id = msg.id
   left outer join events evt on evt.private_message_id = msg.id where evt.id is null;

UPDATE events
  SET parent_id = (SELECT get_private_message_event_parent(pm.*)
      FROM private_messages pm
      WHERE pm.id = events.private_message_id)
  WHERE events.event_type = 'private_message_sent';

