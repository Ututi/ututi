<%inherit file="/subject/home.mako" />

%if c.subject.description:
  <%self:rounded_block id="subject_description">
    <div class="content">
      ${h.html_cleanup(c.subject.description)}
    </div>
    %if c.user:
      <div class="right_arrow1"><a href="${c.subject.url(action='edit')}">${_('Edit')}</a></div>
    %endif
  </%self:rounded_block>
%else:
  <%self:rounded_block class_='subject-intro-block' id="subject-intro-block">
    %if c.user:
      <div class="right_arrow1" style="float: right" ><a href="${c.subject.url(action='edit')}">${_('Edit')}</a></div>
    %endif
    <h2 style="margin-top: 5px">${_('What is a subject page?')}</h2>
    <p>${_('A subject page is a place for all information related to a particular course.')}</p>

    <h2 style="margin-bottom: 5px">${_('Where do I start?')}</h2>
    <ul class="subject-intro-message" style="margin-top: 5px">
      <li>
        <span class="heading">${_('Enter a subject description,')}</span>
        ${_('so that others would find their way around more easily.')}
        ${h.button_to(_('Create a subject description'), c.subject.url(action='edit'))}
      </li>

    </ul>
  </%self:rounded_block>
%endif
