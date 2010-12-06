<%inherit file="/books/base.mako" />

<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>

<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="form_title(title)">
<h1>${title}</h1>
</%def>


<%def name="head_tags()">
${parent.head_tags()}
<%newlocationtag:head_tags />
</%def>

<%def name="book_logo_field()">
<form:error name="book_logo_upload" />
<label>
  <span class="labelText">${_('Book cover')}</span>
  <input type="file" name="logo" id="book_logo_upload" class="line"/>
</label>
</%def>

<%def name="selectbox(field_name, label, objects)">
<label>${label}: ${h.select(field_name, None, [("", "")] + [(obj.id, obj.name) for obj in objects])}</label>
<form:error name="${field_name}" />
</%def>

<%def name="form(action)">
${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}

<script language="javascript" type="text/javascript">//<![CDATA[
  function show_department(){
      department = $('select#department option:selected').attr('value')
      $('.department').hide();
      $('.science_type_field').hide();
      if(department != ""){
          $('#department_science_type_field_'+department).show();
          $('#department_'+department).show();
      }else{
          $('.science_type_field').hide();
      }

  }
//]]></script>

<form method="post" action="${action}"
     id="book_add_form" enctype="multipart/form-data" class="fullForm">
  <fieldset>
  <input type="hidden" name="id" value=""/>
  <div class="book-logo">
    ${self.book_logo_field()}
  </div>
  <div class="basic-book-info">
    ${h.input_line('title', _('Title'))}
    ${h.input_line('author', _('Author'))}
    ${h.input_area('description', _('Brief description of the book'))}<br />
    <label>${_('Book department')}: ${h.select('department', None, c.book_departments)}</label>
    <form:error name="department_id">
 </div>
  <div id="department_0" class="department">
    ${location_widget(2)}
    ${h.input_line('course', _('Course'))}
  </div>
  <div id="department_1" class="department">
    <%self:selectbox field_name = "school_grade" label="${_('School grade')}", objects="${c.school_grades}" />
  </div>
  <div id="department_science_type_field_0" class="science_type_field" style="display: none">
    <%self:selectbox field_name = "university_science_type" label="${_('Science type')}", objects="${c.university_science_types}" />
  </div>
  <div id="department_science_type_field_1" class="science_type_field" style="display: none;">
    <%self:selectbox field_name = "school_science_type" label="${_('Science type')}", objects="${c.school_science_types}" />
  </div>
  <div id="department_science_type_field_2" class="science_type_field" style="display: none;">
    <%self:selectbox field_name = "other_science_type" label="${_('Science type')}", objects="${c.other_science_types}" />
  </div>
  <form:error name="science_type" />
  <div class="book-transfer-info">
    ${h.input_line('price', _('Price'))}
    <p>
      <%self:selectbox field_name = "book_type" label="${_('Book type')}", objects="${c.book_types}" />
    </p>
    <p>
      <%self:selectbox field_name = "city" label="${_('City')}", objects="${c.cities}" />
    </p>
    <p>
    </p>
  </div>
  <br />

  <div class="owner-information">
    <div class="floatleft avatar">
      %if c.user.logo is not None:
      <img src="${url(controller='user', action='logo', id=c.user.id, width=70, height=70)}" alt="logo" />
      %else:
      ${h.image('/img/profile-avatar.png', alt='logo')|n}\
      %endif
    </div>
    <div class="floatleft owner-information-fields">
      <h2>${_('Enter your cotact information:')}</h2>
      ${h.input_line("owner_name", _("Name"), c.user.fullname)}
      ${h.input_line("owner_phone", _("Phone"), c.user_phone_number)}
      ${h.input_line("owner_email", _("E-mail"), (c.user.emails[0].email if c.user.emails[0] else ""))}
      ${h.input_submit(_('Save'))}
    </div>
  </div>
  </fieldset>
</form>
<script type="text/javascript">
  show_department();
  $('#department_id').change(show_department);
</script>
</%def>

<a class="back-link" href="${url(controller='books', action='index')}">${_('back to catalog')}</a>
<%self:form_title title="${_('New book')}" />
<%self:form action="${url(controller='books', action='create')}"/>
