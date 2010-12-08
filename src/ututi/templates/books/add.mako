<%inherit file="/books/base.mako" />

<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>

<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="head_tags()">
${parent.head_tags()}
<%newlocationtag:head_tags />
</%def>

<%def name="book_logo_field()">
<form:error name="book_logo_upload" />
<label>
  <span class="labelText">${_('Image')}</span>
  <input type="file" name="logo" id="book_logo_upload" class="line"/>
</label>
</%def>

<%def name="selectbox(field_name, label, objects)">
<label>
  ${label}<br />
  ${h.select(field_name, None, [("", "")] + [(obj.id, obj.name) for obj in objects])}
</label>
<form:error name="${field_name}" />
</%def>

<%def name="form(action, title)">
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
//]]></script>

<form method="post" action="${action}"
      id="book_add_form" enctype="multipart/form-data" class="fullForm">
  <fieldset>
    <div class="portlet book-form-block">
      <div class="ctl"></div>
      <div class="ctr"></div>

      <div class="inner">
        <h1 class="book-form-title">${title}</h1>
        <div class="basic-book-info">
          ${h.input_line('title', _('Book title'), class_="wide")}
          ${h.input_line('author', _('Author'))}
        </div>
        <input type="hidden" name="id" value=""/>
        <div class="book-logo">
          ${self.book_logo_field()}
        </div>
        <div>
          <div>
            ${h.input_line('price', _('Price'))}
          </div>
        </div>
        <div>
        %for department in c.book_departments:
        <label class="department-field-select-block">
          ${h.radio("department", department[0], class_="department_selection")}
          ${department[1]}
        </label>
        %endfor
        </div>
        <form:error name="department_id" />
        <div>
          <div class="school-field-block department-field-block book-form-field-block odd-field-block">
            <%self:selectbox field_name = "school_grade" label="${_('School grade')}", objects="${c.school_grades}" />
          </div>
          <div class="university-field-block department-field-block science_type_field book-form-field-block" style="display: none">
            <%self:selectbox field_name = "university_science_type" label="${_('Science type')}", objects="${c.university_science_types}" />
          </div>
          <div class="school-field-block department-field-block book-form-field-block" style="display: none;">
            <%self:selectbox field_name = "school_science_type" label="${_('Discipline')}", objects="${c.school_science_types}" />
          </div>
          <form:error name="science_type" />
        </div>
        <div class="school-field-block university-field-block department-field-block book-form-field-block odd-field-block">
          <%self:selectbox field_name = "book_type" label="${_('Type')}", objects="${c.book_types}" />
        </div>
        <div class="school-field-block university-field-block other-field-block department-field-block book-form-field-block">
        <%self:selectbox field_name = "city" label="${_('City')}", objects="${c.cities}" />
        </div>
        <div class="comment-field-block school-field-block university-field-block other-field-block department-field-block">
          ${h.input_area('description', _('Comment'))}
        </div>
      </div>
    </div>
    <div class="rounded-block book-form-block">
      <div class="cbl"></div>
      <div class="cbr"></div>


      <div class="inner">
        <h1 class="book-form-title">${_('Owner information')}</h1>
        <div class="owner-information">
          ${h.input_line("owner_name", _("Full name"), c.user.fullname)}
          ${h.input_line("owner_email", _("Email"), (c.user.emails[0].email if c.user.emails[0] else ""))}
          ${h.input_line("owner_phone", _("Phone number"), c.user_phone_number)}
          <div class="submit-button">${h.input_submit(_('Save'))}</div>
        </div>
      </div>
    </div>
  </fieldset>
</form>
<script type="text/javascript">
  show_department();
  $("input[name='department']").change(show_department);
</script>
</%def>
<%self:form action="${url(controller='books', action='create')}" title="${_('New book')}"/>
