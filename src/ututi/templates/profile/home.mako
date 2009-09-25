<%inherit file="/profile/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_("What's new?")}
  ${h.image('/images/details/icon_question.png',
            alt=_('This is a list of the subjects You are watching. By clicking on the cross next to any subject,\
 You will not get any messages of the changes in it. If Your group is watching this subject, it will not affect Your classmates.'),
            class_='tooltip')|n}
</h1>

<ul id="event_list">
% for event in c.events:
<li>
  ${event.render()|n} <span class="event_time">(${event.when()})</span>
</li>
% endfor
</ul>
