<%inherit file="/books/base.mako" />
<%namespace name="books" file="/books/add.mako" />

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
<div class="book-info">
  %if c.book.logo is not None:
  <img class="book-cover" src="${url(controller='books', action='logo', id=c.book.id, width=150, height=200)}" alt="${_('Book cover')}" />
  %else:
  <img class="book-cover" src="${url('/images/books/default_book_icon.png')}" width=150 alt="${_('Book cover')}" />
  %endif
  <h1 class="title">${c.book.title}</h1>
  ${book_attribute(_('Author'), c.book.author)}
  <div class="book-attribute">
    <span class="book-attribute-label">${_('Book type')}:</span>
    <span class="book-attribute-value">
      ${h.link_to(c.book.department.title,
                 url(controller="books",
                     action="catalog",
                     books_department=c.book.department.name))}
      %if c.book.department.name != 'other':
         &gt; ${h.link_to(c.book.type.name,
                          url(controller="books",
                          action="catalog",
                          books_department = c.book.department.name,
                          books_type_name = c.book.type.url_name))}
         &gt; ${h.link_to(c.book.science_type.name,
                          url(controller="books",
                          action="catalog",
                          books_department = c.book.department.name,
                          books_type_name = c.book.type.url_name,
                          science_type_id = c.book.science_type.id))}
      %endif
    </span>
  </div>
  %if c.book.department.name == 'school':
      ${book_attribute(_('School grade'), c.book.school_grade.name)}
  %endif
  ${book_attribute(_('City'), c.book.city.name)}

  <div class="book-attribute book-attribute-price">
      <span class="book-price-label">${_('Price')}:</span>
      <span class="book-price">
        ${c.book.price}
      </span>
  </div>

  <div class="books-description">${c.book.description}</div>

  <div class="owner-information">
    <p>${_("Owner information")}</p>
    <div class="profile">
      <img src="${c.book.created.url(action='logo', width=70, height=70)}" alt="logo" class="floatleft" />
      <div><h3>${c.book.created.fullname}</h3></div>
      <div><a href="mailto:${c.book.created.emails[0].email}">${c.book.created.emails[0].email}</a></div>
      %if c.book.created.phone_number is not None and c.book.created.phone_number != "":
      <div class="user-phone-number">
        ${_('Phone')}: ${c.book.created.phone_number}
      </div>
      %endif
      <div class="medals" id="user-medals">
        %for medal in c.book.created.all_medals():
        ${medal.img_tag()}
        %endfor
      </div>
      <div class="clear"></div>
    </div>
    <div id="private-message-container">
      <form action="${url(controller='books', action='private_message')}">
        <input type="hidden" name="book_id" value="${c.book.id}" />
        ${h.input_area("message", _("Write to owner:"))}
        <div style="margin-top: 5px;">${h.input_submit(_("Send message"))}</div>
      </form>
    </div>
  </div>

</div>
