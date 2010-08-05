create table group_coupons (
       id varchar(20) not null,
       created timestamp not null default (now() at time zone 'UTC'),
       valid_until timestamp not null,
       action varchar(40) not null,
       credit_count int default null,
       day_count int default null,
       primary key (id));;

create table coupon_usage (
       coupon_id varchar(20) not null references group_coupons(id),
       group_id int8 default null references groups(id),
       user_id int8 not null references users(id),
       primary key (coupon_id, user_id));;
