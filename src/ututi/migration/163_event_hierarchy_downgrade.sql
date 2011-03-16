CREATE OR REPLACE FUNCTION private_message_event_trigger() RETURNS trigger AS $$
    DECLARE
      pid int8 := NULL;
    BEGIN
      pid := get_private_message_event_parent(NEW);
      INSERT INTO events (recipient_id, author_id, event_type, private_message_id, parent_id)
             VALUES (NEW.recipient_id, NEW.sender_id, 'private_message_sent', NEW.id, pid);
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

UPDATE events
  SET parent_id = (SELECT get_private_message_event_parent(pm.*)
      FROM private_messages pm
      WHERE pm.id = events.private_message_id)
  WHERE events.event_type = 'private_message_sent';

CREATE OR REPLACE FUNCTION group_mailing_list_message_event_trigger() RETURNS trigger AS $$
    DECLARE
      pid int8 := NULL;
    BEGIN
      IF NEW.in_moderation_queue THEN
        INSERT INTO events (object_id, author_id, event_type, message_id)
               VALUES (NEW.group_id, NEW.author_id, 'moderated_post_created', NEW.id);
      ELSE
        pid := get_group_mailing_list_message_event_parent(NEW);
        INSERT INTO events (object_id, author_id, event_type, message_id, parent_id)
               VALUES (NEW.group_id, NEW.author_id, 'mailinglist_post_created', NEW.id, pid);
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

UPDATE events
  SET parent_id = (SELECT get_group_mailing_list_message_event_parent(msg.*)
      FROM group_mailing_list_messages msg
      WHERE msg.id = events.message_id)
  WHERE events.event_type = 'mailinglist_post_created';

CREATE OR REPLACE FUNCTION group_forum_message_event_trigger() RETURNS trigger AS $$
    DECLARE
      pid int8 := NULL;
    BEGIN
      IF NEW.category_id > 2 THEN   -- group forum
        pid := get_group_forum_post_event_parent(NEW);
        INSERT INTO events (object_id, author_id, event_type, post_id, parent_id)
               VALUES (
                  (SELECT group_id FROM forum_categories
                   WHERE forum_categories.id = NEW.category_id),
                  cast(current_setting('ututi.active_user') as int8),
                  'forum_post_created', NEW.id, pid);
      END IF;
      RETURN NEW;
    END
$$ LANGUAGE plpgsql;;

UPDATE events
  SET parent_id = (SELECT get_group_forum_post_event_parent(msg.*)
      FROM forum_posts msg
      WHERE msg.id = events.post_id)
  WHERE events.event_type = 'forum_post_created';



-- alter table users drop column net_worth;
-- drop table admins;
diff --git a/src/ututi/model/defaults.sql b/src/ututi/model/defaults.sql
index ddf4368..9104e09 100644
--- a/src/ututi/model/defaults.sql
+++ b/src/ututi/model/defaults.sql
@@ -1020,6 +1020,7 @@ $$ LANGUAGE plpgsql;;
 
 CREATE FUNCTION group_mailing_list_message_event_trigger() RETURNS trigger AS $$
     DECLARE
+      evt events;
       pid int8 := NULL;
     BEGIN
       IF NEW.in_moderation_queue THEN
@@ -1027,8 +1028,10 @@ CREATE FUNCTION group_mailing_list_message_event_trigger() RETURNS trigger AS $$
                VALUES (NEW.group_id, NEW.author_id, 'moderated_post_created', NEW.id);
       ELSE
         pid := get_group_mailing_list_message_event_parent(NEW);
-        INSERT INTO events (object_id, author_id, event_type, message_id, parent_id)
-               VALUES (NEW.group_id, NEW.author_id, 'mailinglist_post_created', NEW.id, pid);
+        INSERT INTO events (object_id, author_id, event_type, message_id)
+               VALUES (NEW.group_id, NEW.author_id, 'mailinglist_post_created', NEW.id)
+               RETURNING * INTO evt;
+        UPDATE events SET parent_id = evt.id WHERE parent_id = pid OR id = pid;
       END IF;
       RETURN NEW;
     END
@@ -1054,16 +1057,19 @@ $$ LANGUAGE plpgsql;;
 
 CREATE FUNCTION group_forum_message_event_trigger() RETURNS trigger AS $$
     DECLARE
+      evt events;
       pid int8 := NULL;
     BEGIN
       IF NEW.category_id > 2 THEN   -- group forum
         pid := get_group_forum_post_event_parent(NEW);
-        INSERT INTO events (object_id, author_id, event_type, post_id, parent_id)
+        INSERT INTO events (object_id, author_id, event_type, post_id)
                VALUES (
                   (SELECT group_id FROM forum_categories
                    WHERE forum_categories.id = NEW.category_id),
                   cast(current_setting('ututi.active_user') as int8),
-                  'forum_post_created', NEW.id, pid);
+                  'forum_post_created', NEW.id)
+               RETURNING * INTO evt;
+        UPDATE events SET parent_id = evt.id WHERE parent_id = pid OR id = pid;
       END IF;
       RETURN NEW;
     END
@@ -1139,11 +1145,14 @@ $$ LANGUAGE plpgsql;;
 
 CREATE FUNCTION private_message_event_trigger() RETURNS trigger AS $$
     DECLARE
+      evt events;
       pid int8 := NULL;
     BEGIN
       pid := get_private_message_event_parent(NEW);
-      INSERT INTO events (recipient_id, author_id, event_type, private_message_id, parent_id)
-             VALUES (NEW.recipient_id, NEW.sender_id, 'private_message_sent', NEW.id, pid);
+      INSERT INTO events (recipient_id, author_id, event_type, private_message_id)
+             VALUES (NEW.recipient_id, NEW.sender_id, 'private_message_sent', NEW.id)
+             RETURNING * INTO evt;
+      UPDATE events SET parent_id = evt.id WHERE parent_id = pid OR id = pid;
       RETURN NEW;
     END
 $$ LANGUAGE plpgsql;;
