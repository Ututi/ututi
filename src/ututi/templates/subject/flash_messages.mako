<%def name="watch_subject(subject)">
  ${h.literal(_("%(subject_link)s has been added to your watched subject list.") % dict(
    subject_link=h.link_to(subject.title, url=subject.url())
    ))}
</%def>

<%def name="unwatch_subject(subject)">
  ${h.literal(_("%(subject_link)s has been removed from your watched subject list.") % dict(
    subject_link=h.link_to(subject.title, url=subject.url())
    ))}
</%def>

<%def name="teach_subject(subject)">
  ${h.literal(_("%(subject_link)s has been added to your taught courses list.") % dict(
    subject_link=h.link_to(subject.title, url=subject.url())
    ))}
</%def>

<%def name="unteach_subject(subject)">
  ${h.literal(_("%(subject_link)s has been removed from your taught courses list.") % dict(
    subject_link=h.link_to(subject.title, url=subject.url())
    ))}
</%def>
