<%inherit file="/books/base.mako" />
<%namespace file="/books/add.mako" name="book_form" import="*" />
<%book_form:form_title title="${_('Edit book')}" />
<%book_form:form action="${url(controller='books', action='update')}"/>
