<%inherit file="/base.mako" />

<%def name="title()">
  Subjects
</%def>

<h1>${_('Subjects')}</h1>

%if c.subjects:
    <ol id="subject_list">
    %for subj in c.subjects:
         <li>
           <a href="${h.url_for(controller='subject', action='subject_home', id=subj.id)}" class="subject-link">${subj.title}</a>
         </li>
    %endfor
    </ul>
%endif
