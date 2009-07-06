<%inherit file="/base.mako" />

<%def name="title()">
${_('New group')}
</%def>

<h1>${_('New group')}</h1>

<form method="post" action="${h.url_for(controller='group', action='new_group')}"
     id="group_add_form" enctype="multipart/form-data">
  <div class="form-field">
    <label for="id">${_('Address')}</label>
    <input type="text" id="id" name="id" class="line"/>@${c.mailing_list_host}
  </div>
  <div class="form-field">
    <label for="title">${_('Title')}</label>
    <input type="text" id="title" name="title" class="line"/>
  </div>
  <div class="form-field">
    <label for="description">${_('Description')}</label>
    <textarea class="line" name="description" id="description" cols="25" rows="5"></textarea>
  </div>
  <div class="form-field">
    <label for="year">${_("Year")}</label>
    <select name="year" id="year">
      %for year in c.years:
        %if year == c.current_year:
          <option value="${year}" selected="selected">${year}</option>
        %else:
          <option value="${year}">${year}</option>
        %endif
      %endfor
    </select>
  </div>
  <div>
    <span class="btn">
      <input type="submit" value="${_('Save')}"/>
    </span>
  </div>
</form>
