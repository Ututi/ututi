${_('The teacher %(teacher_name)s ( %(teacher_url)s ) sent a message to Your group:') % dict(teacher_name=teacher.fullname, teacher_url=teacher.url(qualified=True))}

${message}

${_('If You reply to this message, the teacher will not get Your replies.')}
