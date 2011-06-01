CREATE TABLE themes (
       id bigserial not null,
       header_background_color varchar(6) default null,
       header_color varchar(6) default null,
       header_logo bytea default null,
       primary key (id));;
