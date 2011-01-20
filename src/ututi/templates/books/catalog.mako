<%inherit file="/books/base.mako" />
<%namespace file="/books/index.mako" name="books" import="book_information"/>

<%def name="science_list()">
<div class="science_types_list">
  %for science_type in c.current_science_types:
  <div class="science_type filter-list-item">
    ${h.link_to(science_type.name,
    url(controller = "books",
    action="catalog",
    books_department= c.books_department,
    science_type_id = science_type.id, **c.url_params))}

    <div class="books-number">
      <% cnt = len(science_type.get_books(type=c.books_type)) %>
      ${ungettext('%d book', '%d books', cnt) % cnt}
    </div>
  </div>
  %endfor
</div>
</%def>

<%def name="school_grades_list()">
<div class="department_members_list">
  %for school_grade in c.school_grades:
  <div class="school_grade filter-list-item">
    ${h.link_to(school_grade.name,
          url(controller = "books",
              action="catalog",
              books_department= c.books_department,
              school_grade_id = school_grade.id, **c.url_params))}
    <div class="books-number">
      <% cnt = len(school_grade.get_books(type=c.books_type)) %>
      ${ungettext('%d book', '%d books', cnt) % cnt}
    </div>
  </div>
  %endfor
</div>
</%def>

%if c.books_department:
<div class="book-breadcrumbs">
  ${_('Catalog')}: ${h.link_to(c.books_department_title,
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

<div class="ordering">
  %if c.books_department == "school":
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

  <div class="books-header books-catalog-header">
    %if c.books_department or c.current_science_types:
    <span class="title">${_('Order by')}:</span>
    %endif

    <a href="#" class="order-criteria" onclick="show_department_list();return false;">${_('School grades')}</a>

    %if c.current_science_types:
    <a href="#" class="order-criteria" onclick="show_science_types();return false;">${_('Disciplines')}</a>
    %endif
  </div>
  <div>
    ${school_grades_list()}
  </div>
  <div>
    ${science_list()}
  </div>
  %elif c.books_department == "university":
  <div class="books-header books-catalog-header">
    <span class="title">${_('Science types')}:</span>
  </div>
  <div>
    ${science_list()}
  </div>
  %endif
</div>

<div class="books-header">
  <h2>${_('All books')}</h2>
  <div id="city_select_dropdown">
    <label>
      <span class="a11y">${_('City')}</span>
      <form id="cities-select" action="${url(controller='books', action='catalog')}">
        ${h.select('city', [c.selected_city_id], c.filter_cities)}
      </form>
    </label>
    <script language="javascript" type="text/javascript">//<![CDATA[
        $('#city').change(function(){
            $('form#cities-select').submit();
          });
      //]]></script>
    <span class="a11y">${h.input_submit(_('Filter'))}</span>
  </div>
  <br style="clear: both;"/>
</div>

%if c.books_department=="school":
<script language="javascript" type="text/javascript">//<![CDATA[
    %if c.science_type:
    show_science_types();
    %else:
    show_department_list();
    %endif
//]]></script>
%endif


<div>
  %for book in c.books:
  <%books:book_information book="${book}" />
  %endfor
  <div id="pager">${c.books.pager(format='~3~') }</div>
</div>
