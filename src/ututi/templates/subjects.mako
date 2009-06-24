<%inherit file="/base.mako" />

<%def name="title()">
  Subjects
</%def>

<h1>${_('Subjects')}</h1>

%if c.subjects:
    <ol id="subject_list">
    %for subj in c.subjects:
         <li>
          %if subj.text_id:
            <a href="${h.url_for(controller='subject', action='subject_home', id=subj.text_id)}" class="subject-link">${subj.title}</a>
          %else:
            <a href="${h.url_for(controller='subject', action='subject_home', id=subj.id)}" class="subject-link">${subj.title}</a>
          %endif
         </li>
    %endfor
    </ul>
%endif
