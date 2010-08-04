create table group_coupons (
       id varchar(20) not null,
       created timestamp not null default (now() at time zone 'UTC'),
       valid_until timestamp not null,
       action varchar(40) not null,
       credit_count int default null,
       day_count int default null,
       primary key (id));;

alter table groups add column coupon_id varchar(250) null references group_coupons(id) on delete set null;
