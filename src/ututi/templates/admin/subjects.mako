<%inherit file="/admin/base.mako" />

<%def name="title()">
  Subjects
</%def>

<h1>${_('Subjects')}</h1>

<div id="search-results-container">
  <h3 class="underline search-results-title">
    <span class="result-count">(${ungettext("found %(count)s subject", "found %(count)s subjects", c.subjects.item_count) % dict(count = c.subjects.item_count)})</span>
  </h3>
  <ul id="subject_list">
    %for subj in c.subjects:
     <li>
       <a href="${subj.url()}" class="subject-link">${subj.title}</a>
       (<a href="${subj.created.url()}" class="author-link">${subj.created.fullname}</a>)
     </li>
    %endfor
  </ul>
  <div id="pager">${c.subjects.pager(format='~3~') }</div>
</div>
