<%inherit file="/books/base.mako" />
<%namespace file="/books/index.mako" name="books" import="book_information"/>

<%def name="science_list()">
<div class="science_types_list">
  %for science_type in c.current_science_types:
  <div class="science_type">
  ${h.link_to(science_type.name,
              url(controller = "books",
                  action="catalog",
                  books_department= c.books_department,
                  science_type_id = science_type.id, **c.url_params))}
  </div>
  %endfor
</div>
</%def>

<%def name="school_grades_list()">
<div class="department_members_list">
  %for school_grade in c.school_grades:
  <div class="school_grade">
    ${h.link_to(school_grade.name,
          url(controller = "books",
              action="catalog",
              books_department= c.books_department,
              school_grade_id = school_grade.id, **c.url_params))}
  </div>
  %endfor
</div>
</%def>

<%def name="locations_list()">
<div class="department_members_list">
  %for location in c.locations:
  <div class="location">
    ${h.link_to(location.title,
          url(controller = "books",
              action="catalog",
              books_department= c.books_department,
              location_id = location.id, **c.url_params))}
  </div>
  %endfor
</div>
</%def>

%if c.books_department:
<div class="book-breadcrumbs">
  ${_('Catalog')}: ${h.link_to(_(c.books_department.capitalize()),
                 url(controller="books",
                     action="catalog",
                     books_department=c.books_department))}
  %if c.books_type is not None and c.books_type != "":
  > ${h.link_to(c.books_type.name,
                url(controller="books",
                    action="catalog",
                    books_department = c.books_department,
                    **c.url_params))}
  %endif
</div>
%endif

<script language="javascript" type="text/javascript">
//<![CDATA[
    function show_department_list(){
        $('.science_type').hide();
        $('.department_members_list').show();
    }

    function show_science_types(){
        $('.department_members_list').hide();
        $('.science_type').show();
    }
//]]>
</script>
<div id="search_results_header">
  <h2>${_('All books')}</h2>
  <div id="city_select_dropdown">
    <label>
      <span class="a11y">${_('City')}</span>
      <form id="cities-select" action="${url(controller='books', action='catalog')}">
        ${h.select('city', [c.selected_city_id], c.filter_cities)}
      </form>
      <script language="javascript" type="text/javascript">//<![CDATA[
        $('#city').change(function(){
            $('form#cities-select').submit();
          });
      //]]></script>

    </label>
  </div>
  <br style="clear: both;"/>
</div>

<div class="ordering">
  <div class="order-books-by">
    %if c.books_department or c.current_science_types:
    ${_('Order by')}:
    %endif
    %if c.books_department == "university":
    <a href="#" onclick="show_department_list()">${_('Universities')}</a>
    %elif c.books_department == "school":
    <a href="#" onclick="show_department_list()">${_('School grades')}</a>
    %endif
    %if c.current_science_types:
    <a href="#" onclick="show_science_types()">${_('Science types')}</a>
    %endif
  </div>
  <div>
    %if c.books_department == "university":
    ${locations_list()}
    %elif c.books_department == "school":
    ${school_grades_list()}
    %endif
  </div>
  <div>
    ${science_list()}
  </div>
</div>
<script language="javascript" type="text/javascript">//<![CDATA[
    %if c.science_type or (c.locations and c.school_grades):
    show_science_types();
    %else:
    show_department_list();
    %endif
//]]></script>


<div>
  %for book in c.books:
  <%books:book_information book="${book}" />
  %endfor
  <div id="pager">${c.books.pager(format='~3~') }</div>
</div>
