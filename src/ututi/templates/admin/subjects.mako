<%inherit file="/base.mako" />

<%def name="title()">
  Subjects
</%def>

<h1>${_('Subjects')}</h1>

%if c.subjects:
    <ol id="subject_list">
    %for subj in c.subjects:
         <li>
           <a href="${subj.url()}" class="subject-link">${subj.title}</a>
           (<a href="${subj.created.url()}" class="author-link">${subj.created.fullname}</a>)
         </li>
    %endfor
    </ul>
%endif
