<%inherit file="/portlets/base.mako"/>

<%def name="subject_info_portlet(subject=None)">
  <%
     if subject is None:
         subject = c.subject
  %>

  <%self:portlet id="subject_info_portlet">
    <%def name="header()">
      ${_('Subject information')}
    </%def>
    <div class="structured_info">
      <h4>${_('Description')}</h4>
      <div class="small">
        ${subject.description}
      </div>
      <h4>${_('Lecturer')}</h4>
      <div class="small">
        ${subject.lecturer}
      </div>
    </div>
    <br/>
    %if subject.can_write(c.user):
      <a id="subject_edit_link"
         class="more"
         href="${url(controller='subject', action='edit', id=subject.subject_id, tags=c.subject.location_path)}">${_('Edit')}</a>
    %endif

    %if c.user:
      <%
         cls = ''
         text = _('Watch subject')
         if c.user.watches(subject):
             cls = 'inactive'
             text = _('Stop watching the subject')

      %>
      <span>
        <a class="btn ${cls}" href="${url(controller='subject', action='watch', id=subject.subject_id, tags=subject.location_path)}">
          <span>${text}</span>
        </a>
      </span>
    %endif
  </%self:portlet>
</%def>
