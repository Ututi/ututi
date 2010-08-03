<%inherit file="/group/base.mako" />
<%namespace name="files" file="/sections/files.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="head_tags()">
   ${parent.head_tags()}
   <%files:head_tags />
</%def>

%if c.group.paid:
  <%files:file_browser obj="${c.group}" title="${_('Group files')}" controls="['upload', 'folder', 'unlimited']"/>
%else:
  <%files:file_browser obj="${c.group}" comment="${_('You can keep up to %s of private group files here (e.g. pictures)') % h.file_size(c.group.available_size)}" controls="['upload', 'folder', 'size']"/>
%endif

% for n, subject in enumerate(c.group.watched_subjects):
  <%files:file_browser obj="${subject}" section_id="${n + 1}" collapsible="True"/>
% endfor
<br/>
%if c.group.is_admin(c.user):
<a class="btn" href="${c.group.url(action='subjects', list='open')}">
  <span>${_('Add more subjects')}</span>
</a>
%endif

%if request.GET.get('just_paid'):
  <div id="got-space-dialog" style="display: none">
      <div style="font-size: 14px; color: #666; font-weight: bold"
          >${_("Congratulations! You have increased the group's private file limit.")}</div>

      %if c.group.private_files_lock_date:
        <div style="padding-top: 1em; padding-bottom: 1em">
          ${_("You can now store up to 5&nbsp;GB in your group's private area until <strong>%s</strong>.") % c.group.private_files_lock_date.date().isoformat() |n}
          ${_('Have fun using Ututi groups!')}
        </div>
      %endif

      <div style="padding-left: 120px">
        ${h.image('/images/happy_cat.png', alt=_('Happy cat'))}
      </div>
  </div>

  <script>
    $(document).ready(function() {
        var dlg = $('#got-space-dialog').dialog({
            title: '${_('Thanks!')}',
            width: 500
        });
        dlg.dialog("open");
        return false;
    });
  </script>
%endif
