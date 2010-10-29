def event_types_grouped(types):
    """Return a list of distinct event types."""
    groups = {
        'group_started_watching_subject': 'group_watched_subjects',
        'group_stopped_watching_subject': 'group_watched_subjects',
        'subject_modified': 'subjects',
        'subject_created': 'subjects',
        'member_joined': 'group_members',
        'member_left': 'group_members',
        'page_modified': 'page_events',
        'page_created': 'page_events'}

    collected = {}
    #init the groups
    for group in groups.values():
        collected[group] = dict(
            id='grp_%s' % group,
            children=[])
    #put the events into groups
    for evt in types:
        group = groups.get(evt, None)
        if group is not None:
            collected[group]['children'].append(evt)
        else:
            collected[evt] = evt
    return collected
