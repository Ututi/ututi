alter table sms drop column sent;
alter table sms drop column status;
alter table sms add column delivered timestamp default null;
alter table sms add column sending_status int default null;
alter table sms add column delivery_status int default null;
