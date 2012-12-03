${_(u"A new teacher has registered:")}

${teacher.fullname} (${teacher.email.email})

%if teacher.location is not None:
${', '.join(teacher.location.hierarchy())}
%endif

${teacher.teacher_position}

${_(u"Ututi")}
