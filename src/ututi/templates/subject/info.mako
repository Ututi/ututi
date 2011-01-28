<%inherit file="/subject/home_base.mako" />
<%namespace file="/sections/content_snippets.mako" import="tabs"/>

${tabs()}

%if c.subject.description:
  <%self:rounded_block id="subject_description">
    <div class="block-content">
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
    <ul class="subject-intro-message">
      <li>
        <span class="heading">${_('Enter a subject description,')}</span>
        ${_('so that others would find their way around more easily.')}
        ${h.button_to(_('Create a subject description'), c.subject.url(action='edit'))}
      </li>
      <li>
        <span class="heading">${_('Create wiki pages for a subject')}</span>
        %if c.user and c.user.is_teacher:
          ${_('You can store Your lecture notes here, and share them with Your students.'
              ' Encourage them to contribute and coauthor the materials with You!')}
        %else:
          ${_('Collecting course notes in Word? Writing things down on a computer during lectures? You can store your notes here, where they can be read and edited by your classmates.')}
        %endif
        ${h.button_to(_('Create a wiki document'), url(controller='subjectpage', action='add', id=c.subject.subject_id, tags=c.subject.location_path),
                  method='GET')}
      </li>
      <li>
      <span class="heading">${_('Upload course files')}</span>
        %if c.user and c.user.is_teacher:
          ${_('Upload Your slides, course notes, sample tasks and solutions here.'
              ' Large files are supported - all for Your convenience!')}
        %else:
          ${_('You may upload course notes, sample tasks and solutions, coursework examples. You can also upload <strong>very</strong> large files (do not abuse this feature though, the moderators will promptly delete any inappropriate material).')|n}
        %endif
        ${h.button_to(_('Upload file'), c.subject.url(action='files'), method='GET')}
      </li>
    </ul>
  </%self:rounded_block>
%endif
