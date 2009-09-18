<%inherit file="/portlets/base.mako"/>
<%namespace file="/sections/content_snippets.mako" import="*"/>

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
      <h4>${subject.title}</h4>
      <div class="small">
        ${_('Lecturer')}: ${subject.lecturer}
      </div>
      % if subject.tags:
      <hr />
      <div class="item-tags">
        %for tag in subject.tags:
          ${tag_link(tag)}
        %endfor
      </div>
      % endif
    </div>
    <br />

    %if c.user:
      <a id="subject_edit_link"
         class="more"
         href="${url(controller='subject', action='edit', id=subject.subject_id, tags=c.subject.location_path)}">${_('Edit')}</a>

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
        <div class="tooltip">
          <span class="content">${_('By watching a subject, you will be informed about all the changes in it.')}</span>
        </div>
      </span>
    %endif
  </%self:portlet>
</%def>
