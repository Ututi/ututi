${_(u"A user wants to become a teacher:")}

${user.fullname} (${user.emails[0].email})

%if user.location is not None:
${', '.join(user.location.hierarchy())}
%endif

${url(controller='admin', action='teachers', user_id=user.id, qualified=True)}

${_(u"Ututi")}
