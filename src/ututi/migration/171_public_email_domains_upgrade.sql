/* a table for storing public email domains */
create table public_email_domains (
       id bigserial not null,
       domain varchar(320) default null,
       primary key (id),
       unique(domain));;

create index public_email_domains_domain_idx on public_email_domains(domain);
