CREATE TEXT SEARCH CONFIGURATION public.universal ( COPY = pg_catalog.english );;
ALTER TEXT SEARCH CONFIGURATION universal
    ALTER MAPPING FOR asciiword, asciihword, hword_asciipart,
                      word, hword, hword_part
    WITH lithuanian, polish, english, simple;;
