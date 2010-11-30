create table teacher_tought_subjects (
       user_id int8 references users(id) not null,
       subject_id int8 not null references subjects(id) on delete cascade,
       primary key (user_id, subject_id));;
