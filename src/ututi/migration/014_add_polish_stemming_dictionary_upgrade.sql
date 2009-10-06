CREATE TEXT SEARCH DICTIONARY polish (
    TEMPLATE = ispell,
    DictFile = system_pl,
    AffFile = system_pl
);

CREATE TEXT SEARCH CONFIGURATION public.pl ( COPY = pg_catalog.english );
ALTER TEXT SEARCH CONFIGURATION pl
    ALTER MAPPING FOR asciiword, asciihword, hword_asciipart,
                      word, hword, hword_part
    WITH polish, english, simple;
