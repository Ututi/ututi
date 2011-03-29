create table email_domains (
       id bigserial not null,
       domain_name varchar(320) default null,
       location_id int8 default null references tags(id) on delete cascade,
       primary key (id),
       unique(domain_name));;

create index email_domains_domain_name_idx on email_domains(domain_name);
