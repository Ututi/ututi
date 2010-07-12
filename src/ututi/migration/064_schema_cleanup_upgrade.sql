DROP TABLE deleted_invitations;
DROP TABLE deleted_requests;

ALTER TABLE payments DROP COLUMN raw_merchantid;
ALTER TABLE payments DROP COLUMN raw_transaction2;
ALTER TABLE payments DROP COLUMN raw_transaction;
ALTER TABLE payments DROP COLUMN raw_payment;
ALTER TABLE payments DROP COLUMN raw_user;
ALTER TABLE payments DROP COLUMN raw_payent_type;

ALTER TABLE user_medals ADD COLUMN
       awarded_on timestamp not null default (now() at time zone 'UTC');

ALTER TABLE forum_posts ALTER COLUMN category_id SET NOT NULL;

ALTER TABLE ONLY user_medals ADD CONSTRAINT user_medals_user_id_key UNIQUE (user_id, medal_type);
