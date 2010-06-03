<%inherit file="/uprebase.mako" />
<%namespace file="/sections/messages.mako" import="*"/>

${self.flash_messages()}
${next.body()}
