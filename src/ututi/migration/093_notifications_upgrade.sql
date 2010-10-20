CREATE TABLE notifications (
       id bigserial NOT NULL,
       content text,
       valid_until date NOT NULL,
       primary key (id));;

CREATE TABLE notifications_viewed (
       user_id int8 NOT NULL REFERENCES users(id),
       notification_id int8 NOT NULL REFERENCES notifications(id)
);;

