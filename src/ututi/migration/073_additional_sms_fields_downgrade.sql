alter table sms add column sent timestamp default null;
alter table sms add column status int default null;
alter table sms drop column delivered;
alter table sms drop column sending_status;
alter table sms drop column delivery_status;
