<%inherit file="/portlets/base.mako"/>

<%def name="school_members_portlet(school=None)">
  <%
     if school is None:
         school = c.location
  %>
  <%self:uportlet id="school_info_portlet" portlet_class="MyProfile first">

    <%def name="header()">
      ${_("School's members")}
    </%def>
    <div class="members_list students_list">

%if c.user is not None and c.user.location is not None:
      <div class="user-logo-link" style="display:none">
        <div class="user-logo">
          <a href="${url(controller="user", action="index", id=c.user.id)}" title="${c.user.fullname}">
            %if c.user.logo is not None:
            <img src="${url(controller='user', action='logo', id=c.user.id, width=45, height=45)}" alt="logo" />
            %else:
            ${h.image('/img/avatar-light-small.png', alt='logo')}
            %endif
          </a>
        </div>
      </div>
%endif
      <%
         school_students = school.get_students(8)
         %>
      %for student in school_students:
      <div class="user-logo-link">
        <div class="user-logo">
          <a href="${url(controller="user", action="index", id=student.id)}" title="${student.fullname}">
            %if student.logo is not None:
            <img src="${url(controller='user', action='logo', id=student.id, width=45, height=45)}" alt="logo" />
            %else:
            ${h.image('/img/avatar-light-small.png', alt='logo')}
            %endif
          </a>
        </div>
      </div>
      %endfor
      <br class="clear-left" />
    </div>
    <ul class="uni-info universityMembersInfo">
     <li>
     %if c.user is not None and c.user.location is None:
     <form id="i_study_here_form" method="post" action="${url(controller='profile',action='set_location', location_id=school.id)}">
       ${h.input_submit(_("I study here"))}
     </form>
    %endif
    <script type="text/javascript">
           $('#i_study_here_form').ajaxForm(function() {
              $('#i_study_here_form').hide() ;
              $('.user-logo-link:last').hide();
              $('.user-logo-link:first').fadeIn();
           });
   </script>
     </li>
     <%
         students_number = school.students_number()
        %>
      <li class="studentsNumber">
        ${ungettext("<span class='bold'>%(count)s</span> student", "<span class='bold'>%(count)s</span> students", students_number) % dict(count=students_number)|n}
      </li>
    </ul>

  </%self:uportlet>
</%def>
