${message}

-- 
% if title:
${_("This message was posted on the '%(title)s' forum.") % dict(title=title)}
% endif
${_("You can find the thread online here:")}
${thread_url}

${_(u"The Ututi team")}
