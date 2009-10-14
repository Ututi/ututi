${_(u"We have received a request to confirm the ownership of this email by %(fullname)s on the Ututi system. If \
this email belongs to You, confirm it by clicking on this link:") % dict(fullname=fullname)}

%if html:
<a href="${link}">${_(u'Confirm email')}</a>
%else:
${link}
%endif

${_('Ututi team')}
