<%inherit file="/books/base.mako" />
<%namespace file="/books/add.mako" name="book_form" import="*" />
<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%book_form:form_title title="${_('Edit book')}" />
##<%book_form:form action="${url(controller='books', action='update')}"/>

<%def name="form(action)">
${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}

<script language="javascript" type="text/javascript">//<![CDATA[
  function show_department(){
      department_id = $('select#department_id option:selected').attr('value')
      $('.department').hide();
      $('.science_type_field').hide();
      if(department_id != ""){
          $('#department_science_type_field_'+department_id).show();
          $('#department_'+department_id).show();
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
    ${book_form.book_logo_field()}
    <label
       %if c.book is None or c.book == "" or c.book.logo is None or c.book.logo == "":
        style="display:none"
      %endif
     >
      <input type="checkbox" name="delete_logo" value="1"/> ${_('Delete logo')}
    </label>
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
    <label>${_('School grade')}: ${h.select("school_grade", None, [(o.id, o.name) for o in c.school_grades])}</label>
 </div>
  <div class="science_type_field">
    <label>${_('Science types')}: ${h.select("science_type", None, [(o.id, o.name) for o in  c.current_science_types])}</label>
  </div>
  <div id="department_science_type_field_0" class="science_type_field" style="display: none">
    <label>${_('Science types')}: ${h.select("university_science_type", None, [(o.id, o.name) for o in  c.university_science_types])}</label>
  </div>
  <div id="department_science_type_field_1" class="science_type_field" style="display: none;">
    <label>${_('Science types')}: ${h.select("school_science_type", None, [(o.id, o.name) for o in  c.school_science_types])}</label>
  </div>
  <div id="department_science_type_field_2" class="science_type_field" style="display: none;">
    <label>${_('Science types')}: ${h.select("other_science_type", None, [(o.id, o.name) for o in  c.other_science_types])}</label>
  </div>
  <form:error name="science_type" />
  <div class="book-transfer-info">
    ${h.input_line('price', _('Price'))}
    <p>
      <label>${_('Book type')}: ${h.select("book_type", None, [(o.id, o.name) for o in c.book_types])}</label>
    </p>
    <p>
      <label>${_('City')}: ${h.select("city", None, [(o.id, o.name) for o in c.cities])}</label>
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
      ${h.input_line("owner_name", _("Name"))}
      ${h.input_line("owner_phone", _("Phone"))}
      ${h.input_line("owner_email", _("E-mail"))}
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

<%self:form action="${url(controller='books', action='update')}" />
