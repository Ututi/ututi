<%inherit file="/books/base.mako" />
<%namespace file="/books/add.mako" name="book_form" import="*" />
<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>

<%book_form:form action="${url(controller='books', action='update')}" title="${_('Edit book')}"/>
