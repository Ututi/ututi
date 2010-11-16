<%inherit file="/books/base.mako" />

<%def name = "book_attribute(label, value, **attrs)">
<%
   if not attrs.has_key('is_value_none'):
       attrs['is_value_none'] = value == None
   endif

   if not attrs.has_key('none_value_text'):
       attrs['none_value_text'] = '-'
   endif

   if not attrs.has_key('class_'):
       attrs['class_'] = ''
   endif
%>
<div class="book-attribute ${attrs['class_']}">
  <span class="book-attribute-label">${label}:</span>
  <span class="book-attribute-value">
    %if value:
    ${value}
    %else:
    ${attrs['none_value_text']}
    %endif
  </span>
</div>
</%def>

${h.link_to(_('Back to catalog'), url(controller="books", action="index"), class_="back-link")}
<h2 class="title">${c.book.title}</h2>
<div class="book-cover">
  <img src="${url(controller='books', action='logo', id=c.book.id, width=150, height=200)}" alt="${_('Book cover')}" />
</div>
<div class="books-description">${c.book.description|n}</div>
${book_attribute(_('Author'), c.book.author)}
${book_attribute(_('Book department'),_(c.book.departments[c.book.department_id]))}
${book_attribute(_('Book type'), c.book.type.name)}
%if c.book.department_id == c.book.department['university']:
  ${_('School')}:
  %if c.book.location.parent:
    ${location.parent.title_short}
  %endif
  ${location.title} ${c.book.course}
%elif c.book.department_id == c.book.department['school']:
  ${_('School grade')}: ${c.book.school_grade.name}
%endif
${book_attribute(_('Science type'), c.book.science_type.name)}
${book_attribute(_('City'), c.book.city.name)}
${book_attribute(_('Price'), '%.2f' % c.book.price + " " + _('national_currency'), class_="book-price", none_value_text = _('free'), is_value_none = c.book.price == 0)}
<div class="owner-information">
  %if c.book.owner.phone_number and c.book.show_phone:
  ${book_attribute(_('Phone'), c.book.owner.phone_number)}
  %endif
</div>
