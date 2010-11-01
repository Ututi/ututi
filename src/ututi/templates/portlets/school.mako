<%inherit file="/portlets/base.mako"/>

<%def name="user_logo_link(user, style=None)">
<div class="user-logo-link"
%if style is not None:
     style = ${style}
%endif
>
  <div class="user-logo">
    <a href="${url(controller="user", action="index", id=user.id)}"
       title="${user.fullname}">
      %if user.logo is not None:
      <img src="${url(controller='user', action='logo', id=user.id, width=45, height=45)}" alt="logo" />
      %else:
      ${h.image('/img/avatar-light-small.png', alt='logo')}
      %endif
    </a>
  </div>
  <div>
    <a href="${url(controller="user", action="index", id=user.id)}" title="${user.fullname}" class="link-to-user-profile">
      ${h.wraped_text(user.fullname, 10)|n}
    </a>
  </div>
</div>
</%def>

<%def name="school_members_portlet(title=None, school=None)">
  <%
     if school is None:
         school = c.location
  %>
  <%self:uportlet id="school_info_portlet" portlet_class="MyProfile first">

    <%def name="header()">
      ${title}
    </%def>
    <div class="members_list students_list">

      <%
         students_number = 8
         school_students = school.get_students(students_number)
      %>
      <div>
      <% count = 0 %>
      %for i, student in enumerate(school_students):
          %if i == 0 or i == students_number/2:
              <% count += 1 %>
              <div id="members_pack_${count}" class="members-pack">
              %if i == 0 and c.user is not None and (c.user.location is None or (c.user.location is not None and c.user.location in c.location.hierarchy(True))):
                  ${user_logo_link(c.user, "display:none")}
              %endif
          %endif
          ${user_logo_link(student)}
          %if i == students_number/2 - 1 or i == students_number-1:
              </div>
          %endif
      %endfor
      <br class="clear-left" />
      </div>
    </div>
    <ul class="uni-info universityMembersInfo">
     <li>
     %if (c.user is not None) and ((c.user.location is None) or ((c.user.location is not c.location) and (c.user.location in c.location.hierarchy(True)))):
       <form id="i_study_here_form" method="post" action="${url(controller='profile',action='set_location', location_id=school.id)}">
         ${h.input_submit(_("I study here"))}
       </form>
    %endif
     </li>
    <script type="text/javascript">
           $('#i_study_here_form').ajaxForm(function() {
              $('#i_study_here_form').hide() ;
              $('#members_pack_1 .user-logo-link:last').hide();
              $('#members_pack_1 .user-logo-link:first').fadeIn();
           });
   </script>
     <%
         students_number = school.students_number()
        %>
      <li class="studentsNumber">
        ${ungettext("<span class='bold'>%(count)s</span> student", "<span class='bold'>%(count)s</span> students", students_number) % dict(count=students_number)|n}
      </li>
    </ul>

  </%self:uportlet>
</%def>
