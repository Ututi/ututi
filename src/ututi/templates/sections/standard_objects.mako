<%namespace file="/sections/standard_buttons.mako" import="close_button" />

<%def name="subject_listitem(subject, n)">
  <div class="subject-description ${'with-top-line' if n else ''}">
    %if c.user is not None and c.user.watches(subject):
    ${close_button(url(controller='profile', action='unwatch_subject', subject_id=subject.id), class_='unwatch-button')}
    %endif
    <div>
      <dt>
        <a class="subject_title" href="${subject.url()}">${h.ellipsis(subject.title, 60)}</a>
      </dt>
      <dd class="rating">
        ( ${_('Subject rating:')} ${h.image('/images/details/stars%d.png' % subject.rating(), alt='', class_='subject_rating')} )
      </dd>
    </div>
    <div style="margin-top: 5px">
      <dd class="location-tags">
        %for index, tag in enumerate(subject.location.hierarchy(True)):
        <a href="${tag.url()}" title="${tag.title}">${tag.title_short}</a>
        |
        %endfor
      </dd>
      %if subject.lecturer:
      <dd class="lecturer">
        ${_('Lect.')} <span class="orange" >${subject.lecturer}</span>
      </dd>
      %endif
    </div>
    <div style="margin-top: 5px">
      <dd class="files">
        ${_('Files:')} ${h.subject_file_count(subject.id)}
      </dd>
      <dd class="pages">
        ${_('Wiki pages:')} ${h.subject_page_count(subject.id)}
      </dd>
      <dd class="watch-count">
        <%
           user_count = subject.user_count()
           group_count = subject.group_count()
           %>
        ${_('The subject is watched by:')}
        ${ungettext("<span class='orange'>%(count)s</span> user",
        "<span class='orange'>%(count)s</span> users",
        user_count) % dict(count=user_count)|n}
        ${_('and')}
        ${ungettext("<span class='orange'>%(count)s</span> group",
        "<span class='orange'>%(count)s</span> groups", 
        group_count) % dict(count=group_count)|n}
      </dd>
    </div>
  </div>
</%def>
