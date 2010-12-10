<%inherit file="/books/base.mako" />
<%namespace file="/books/add.mako" name="book_form" import="*" />

${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
<script language="javascript" type="text/javascript">//<![CDATA[
function show_department(){
    if($('input.department_selection:checked').first()){
        department = $('input.department_selection:checked').first().attr('value');
    }
    $('.department-field-block').hide();
    if(department){
        $('.'+department+'-field-block').show();
    }
}

function toggle_file_upload(){
    if($('#delete_logo:checked').val() != null){
        $('.book-logo').hide();
    }else{
        $('.book-logo').show();
    }
}
//]]></script>

<form method="post" action="${url(controller='books', action='update', id=c.book.id)}"
      id="book_add_form" enctype="multipart/form-data" class="fullForm">
  <fieldset>
    <div class="portlet book-form-block">
      <div class="ctl"></div>
      <div class="ctr"></div>

      <div class="inner">
      	<div class="main-book-fields-block">
          <h1 class="book-form-title">${_('Edit book')}</h1>
          <div class="basic-book-info">
            ${h.input_line('title', _('Book title'))}
            ${h.input_line('author', _('Author'))}
          </div>
	      <div class="book-logo">
		    <label>
		      <span class="labelText">${_('Image')}</span>
		      <input type="file" name="logo" id="book_logo_upload" class="line"/>
		    </label>
		    <form:error name="book_logo_upload" />
	      </div>
	      <div>
            ${h.input_line('price', _('Price'))}
            <form:error name="price" />
          </div>
	</div>
	<div class="book-logo-block">
	  <a class="back-link" href="${url(controller='books', action='my_books')}">${_('Back to my books')}</a><br />

	  %if c.book.logo is not None:
	    <img class="book_image" src="${url(controller='books', action='logo', id=c.book.id, width=100, height=130)}" alt="${_('Book cover')}" /><br />
	    <div class="detele-logo-field">
	      <input type="checkbox" name="delete_logo" id="delete_logo" value="True"/> ${_('Delete image')}
	    </div>
	  %else:
	    <img class="book_image" src="${url('/images/books/default_book_icon.png')}" alt="${_('Book cover')}" />
	  %endif
	</div>
        <div>
        %for department in c.book_departments:
        <label class="department-field-select-block">
          ${h.radio("department", department[0], class_="department_selection")}
          ${department[1]}
        </label>
        %endfor
        </div>
        <form:error name="department" />
        <div>
          <div class="school-field-block department-field-block book-form-field-block odd-field-block">
            <%book_form:selectbox field_name = "school_grade" label="${_('School grade')}", objects="${c.school_grades}" />
          </div>
          <div class="university-field-block department-field-block science_type_field book-form-field-block" style="display: none">
            <%book_form:selectbox field_name = "university_science_type" label="${_('Science type')}", objects="${c.university_science_types}" />
          </div>
          <div class="school-field-block department-field-block book-form-field-block" style="display: none;">
            <%book_form:selectbox field_name = "school_science_type" label="${_('Discipline')}", objects="${c.school_science_types}" />
          </div>
          <form:error name="science_type" />
          <form:error name="university_science_type" />
          <form:error name="school_type" />
        </div>
        <div class="school-field-block university-field-block department-field-block book-form-field-block odd-field-block">
          <%book_form:selectbox field_name = "book_type" label="${_('Type')}", objects="${c.book_types}" />
        </div>
        <div class="school-field-block university-field-block other-field-block department-field-block book-form-field-block">
        <%book_form:selectbox field_name = "city" label="${_('City')}", objects="${c.cities}" />
        </div>
        <div class="comment-field-block school-field-block university-field-block other-field-block department-field-block">
          ${h.input_area('description', _('Comment'))}
        </div>
      </div>
      <input type="hidden" name="id" value=""/>
    </div>
    <div class="rounded-block book-form-block">
      <div class="cbl"></div>
      <div class="cbr"></div>
      <div class="inner">
        <h1 class="book-form-title">${_('Owner information')}</h1>
        <div class="owner-information">
          ${h.input_line("owner_name", _("Full name"))}
          ${h.input_line("owner_email", _("Email"))}
          ${h.input_line("owner_phone", _("Phone number"))}
          <div class="submit-button">${h.input_submit(_('Save'))}</div>
        </div>
      </div>
    </div>
  </fieldset>
</form>
<script type="text/javascript">
  show_department();
  toggle_file_upload()
  $("input[name='department']").change(show_department);
  $('#delete_logo').change(toggle_file_upload);
</script>
