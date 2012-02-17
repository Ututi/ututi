/* Language - specific configuration for full text search */

CREATE TEXT SEARCH DICTIONARY lithuanian (
    TEMPLATE = ispell,
    DictFile = system_lt_lt,
    AffFile = system_lt_lt
);;

CREATE TEXT SEARCH DICTIONARY polish (
    TEMPLATE = ispell,
    DictFile = system_pl,
    AffFile = system_pl
);;

CREATE TEXT SEARCH DICTIONARY english (
    TEMPLATE = ispell,
    DictFile = system_en_gb,
    AffFile = system_en_gb
);;

CREATE TEXT SEARCH CONFIGURATION public.lt ( COPY = pg_catalog.english );;
ALTER TEXT SEARCH CONFIGURATION lt
    ALTER MAPPING FOR asciiword, asciihword, hword_asciipart,
                      word, hword, hword_part
    WITH lithuanian, english, simple;;

CREATE TEXT SEARCH CONFIGURATION public.pl ( COPY = pg_catalog.english );;
ALTER TEXT SEARCH CONFIGURATION pl
    ALTER MAPPING FOR asciiword, asciihword, hword_asciipart,
                      word, hword, hword_part
    WITH polish, english, simple;;

CREATE TEXT SEARCH CONFIGURATION public.universal ( COPY = pg_catalog.english );;
ALTER TEXT SEARCH CONFIGURATION universal
    ALTER MAPPING FOR asciiword, asciihword, hword_asciipart,
                      word, hword, hword_part
    WITH lithuanian, polish, english, simple;;
