-- alter table users drop column net_worth;
-- drop table admins;
diff --git a/src/ututi/model/defaults.sql b/src/ututi/model/defaults.sql
index ac723a3..82fa414 100644
--- a/src/ututi/model/defaults.sql
+++ b/src/ututi/model/defaults.sql
@@ -1257,3 +1257,19 @@ CREATE TABLE notifications_viewed (
        notification_id int8 NOT NULL REFERENCES notifications(id)
 );;
 
+/* Books */
+
+CREATE TABLE books (
+       id bigserial NOT NULL,
+       title varchar(100) NOT NULL,
+       description text,
+       author varchar(100),
+       year date,
+       publisher varchar(100),
+       pages_number int,
+       location varchar(100),
+       price float NOT NULL,
+       user_id int8 NOT NULL REFERENCES users(id),
+       show_phone boolean DEFAULT TRUE,
+       PRIMARY KEY (id)
+);;
