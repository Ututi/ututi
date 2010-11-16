<%inherit file="/books/base.mako" />

<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>

<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="title()">
${_('New book')}
</%def>


<a class="back-link" href="${url(controller='books', action='index')}">${_('back to catalog')}</a>
<h1>${_('New book')}</h1>


<%def name="head_tags()">
<%newlocationtag:head_tags />
</%def>

<%def name="book_logo_field()">
<form:error name="book_logo_upload" />
<label>
  <span class="labelText">${_('Book cover')}</span>
  <input type="file" name="logo" id="book_logo_upload" class="line"/>
</label>
</%def>

<%def name="selectbox(field_name, label, objects, hidden=False)">
%if objects:
    <label>${label}:
      %if hidden == True:
      ${h.select(field_name, None, h.list_for_select(objects, blank_value="blank"), style="display: none;")}
      %else:
      ${h.select(field_name, None, h.list_for_select(objects, blank_value="blank"))}
      %endif
    </label>
%endif
</%def>

<%def name="form(action)">
${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}

<script type="text/javascript">
  science_types = new Array(3);
  science_types[0] = '${h.select("science_type_id", None, h.list_for_select(c.university_science_types)).replace("\n", "")}';
  science_types[1] = '${h.select("science_type_id", None, h.list_for_select(c.school_science_types)).replace("\n", "")}';
  science_types[2] = '${h.select("science_type_id", None, h.list_for_select(c.other_science_types)).replace("\n", "")}';

  function show_department(){
    department_id = $('select#department_id_select option:selected').attr('value')
    $('.department').hide();
    $('#department_'+department_id).show();
    $('#science_type_id').replaceWith(science_types[department_id]);
  }
</script>

<form method="post" action="${action}"
     id="book_add_form" enctype="multipart/form-data" class="fullForm">
  <fieldset>
  <div class="book-logo">
    ${self.book_logo_field()}
  </div>
  <div class="basic-book-info">
    ${h.input_line('title', _('Title'))}
    ${h.input_line('author', _('Author'))}
    ${h.input_area('description', _('Brief description of the book'))}<br />

    ${h.book_departments_select(_('Book department'), c.book_departments, "show_department()")}
  </div>
  <div id="department_0" class="department">
    ${location_widget(2)}
    ${h.input_line('course', _('Course'))}
  </div>
  <div id="department_1", class="department">
    <%self:selectbox field_name = "school_grade_id" label="${_('School grade')}", objects="${c.school_grades}" />
  </div>
  <div>
    <%self:selectbox field_name = "science_type_id" label="${_('Science type')}", objects="${c.all_science_types}" />
  </div>
  <div class="book-transfer-info">
    ${h.input_line('price', _('Price'))}
    <input type="checkbox" name="show_phone" value="True" checked="checked" /> ${_('Show my phone number')}
    <p>
      <%self:selectbox field_name = "type_id" label="${_('Book type')}", objects="${c.book_types}" />
    </p>
    <p>
      <%self:selectbox field_name = "city_id" label="${_('City')}", objects="${c.cities}" />
    </p>
    <p>
    </p>
  </div>
  <br />
  <div>
    ${h.input_submit(_('Save'))}
  </div>
  </fieldset>
</form>
<script type="text/javascript">
  show_department();
</script>
</%def>

<%self:form action="${url(controller='books', action='create')}"/>
