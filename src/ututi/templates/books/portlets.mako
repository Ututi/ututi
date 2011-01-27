<%inherit file="/portlets/base.mako"/>

<%def name="book_types(book_types, books_department)">
%if book_types is not None and book_types != "":
<ul class="book_types">
  %for book_type in book_types:
    <li>${h.link_to(book_type.name,
                    url(controller="books",
                        action="catalog",
                        books_type_name=book_type.url_name,
                        books_department=books_department)
          )}
    </li>
  %endfor
</ul>
%endif
</%def>

<%def name="books_menu(selected_books_department=None)">
  <%self:action_portlet id="button-to-all-books">
    <%def name="header()">
    <a class="blark" href="${url(controller='books', action='catalog')}">${_('All Books')}</a>
    </%def>
  </%self:action_portlet>
  <%self:action_portlet id="button-to-school-books" show_body="${c.books_department == 'school'}">
    <%def name="header()">
      <a class="blark" href="${url(controller='books', action='catalog', books_department='school')}">${_('Books for school')}</a>
    </%def>
    <%self:book_types book_types="${c.book_types}" books_department="school" />
  </%self:action_portlet>
  <%self:action_portlet id="button-to-university-books" show_body="${c.books_department == 'university'}">
    <%def name="header()">
      <a class="blark" href="${url(controller='books', action='catalog', books_department='university')}">${_('Books for students')}</a>
    </%def>
    <%self:book_types book_types="${c.book_types}" books_department="university" />
  </%self:action_portlet>
  <%self:action_portlet id="button-to-other-books">
    <%def name="header()">
      <a class="blark" href="${url(controller='books', action='catalog', books_department='other')}">${_('Other')}</a>
    </%def>
  </%self:action_portlet>

 %if selected_books_department:
 <script type="text/javascript">
   //<![CDATA[
   $(document).ready(function(){
     $('#button-to-'+'${selected_books_department}'+'-books_content .click').click();
   });
   //]]>
 </script>
 %endif

 <div id="search_portlet">
   <div id="search_portlet_content" class="content">
     <form action="${url(controller='books', action='search')}">
       <fieldset>
         <legend class="a11y">${_('Search')}</legend>
         <label class="textField">
           <span class="a11y">${_('Search text')}</span>
           <input type="text" name="text" />
           <span class="edge"></span>
         </label>
         ${h.input_submit(_('search_'))}
       </fieldset>
     </form>
   </div>
 </div>
 %if c.lang in ['lt']:
 <div id="banner_portlet" style="padding-top: 15px;">
   <div class="title">${_('Our friends')}</div>
   <a href="http://www.facebook.com/w2wvilnius"><img src="${url('/images/books/wok2walk.jpg')}" /></a>
   <a href="http://www.skalvija.lt"><img src="${url('/images/books/skalvija.jpg')}" /></a>
 </div>
 %endif
</%def>
