/* A table for regions */
CREATE TABLE regions (id bigserial NOT NULL,
       title varchar(250) NOT NULL,
       country varchar(2) NOT NULL,
       PRIMARY KEY (id));;

INSERT INTO regions (country, title) VALUES
    ('pl', 'Dolnośląskie'),
    ('pl', 'Kujawsko-pomorskie'),
    ('pl', 'Lubelskie'),
    ('pl', 'Lubuskie'),
    ('pl', 'Łódzkie'),
    ('pl', 'Małopolskie'),
    ('pl', 'Mazowieckie'),
    ('pl', 'Opolskie'),
    ('pl', 'Podkarpackie'),
    ('pl', 'Podlaskie'),
    ('pl', 'Pomorskie'),
    ('pl', 'Śląskie'),
    ('pl', 'Świętokrzyskie'),
    ('pl', 'Warmińsko-mazurski'),
    ('pl', 'Wielkopolskie'),
    ('pl', 'Zachodniopomorskie');;

ALTER TABLE tags ADD COLUMN region_id int8 DEFAULT NULL references regions(id) ON DELETE RESTRICT;
