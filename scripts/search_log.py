#!/usr/bin/env python
from collections import defaultdict
import sys

def process_queries(file_name):
    log = open(file_name)

    lines = log.readlines()
    lines = [line for line in lines
             if 'ututi.lib.search' in line]
    lines = lines[500:]

    lines = [line[line.find('/'):] for line in lines]

    lines = [line.split('\t') for line in lines
             if len(line.split('\t')) == 5]

    structured_lines = []

    for url, text, tags, object_type, count in lines:
        structured_lines.append({'url': url.strip(),
                                 'text': text.strip(),
                                 'tags': tags.strip(),
                                 'type': object_type.strip(),
                                 'count': count.strip()})
    return structured_lines


def filter_full_lines(lines):
    full_lines = []
    query = ''
    for line in lines:
        if line['text'] and query != line['text']:
            full_lines.append(line)
            query = line['text']
    return full_lines


def display_query_summary(lines):
    #queries = defaultdict(int)
    queries = {}
    for line in lines:
        queries.setdefault(line['text'], {'count': 0, 'results': 0})
        queries[line['text']]['count'] += 1
        queries[line['text']]['results'] += int(line['count'])
    for n, x in enumerate(reversed(sorted((query_info['count'], query_text, query_info)
                                          for query_text, query_info  in queries.items()))):
        print n, x[0], x[1], float(x[2]['results']) / float(x[2]['count'])


def main():
    log_file = 'release.log'
    if len(sys.argv) > 1:
        log_file = sys.argv[1]
    structured_lines = process_queries(log_file)
    full_lines = filter_full_lines(structured_lines)
    display_query_summary(full_lines)


if __name__ == '__main__':
    main()
