<%inherit file="/ubase-width.mako" />

<%def name="title()">
  Statistics
</%def>

<h1>${_('Statistics')}</h1>

<div class="stats">
  <h2>${_('Most popular subjects by users')}</h2>

  <ul id="subject_list">
    %for n, subj in enumerate(c.subjects):  
     <li>
       <a href="${subj.url()}" class="subject-link">${subj.title}</a>
       (${c.most_watched_by_user[n].count}  ${_('watchers')})
     </li>
    %endfor
  </ul>
</div>

<div class="stats">
  <h2>${_('Most popular subjects by groups')}</h2>

  <ul id="subject_list">
    %for n, subj in enumerate(c.group_subjects):  
     <li>
       <a href="${subj.url()}" class="subject-link">${subj.title}</a>
       (${c.most_watched_by_group[n].count} ${_('watchers')})
     </li>
    %endfor
  </ul>
</div>
