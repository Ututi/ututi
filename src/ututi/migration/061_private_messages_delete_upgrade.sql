alter table private_messages add column hidden_by_sender boolean default false;
alter table private_messages add column hidden_by_recipient boolean default false;
