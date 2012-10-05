<%inherit file="/subject/base.mako" />
<%namespace name="files" file="/sections/files.mako" />

<%def name="css()">
table.wiki-notes {
  width: 100%;
  border-collapse: collapse;
}
table.wiki-notes th.title {
  width: 60%;
}
table.wiki-notes th.author,
table.wiki-notes th.date {
  width: 20%;
}
table.wiki-notes th,
table.wiki-notes td {
  text-align: left;
}
table.wiki-notes th.date,
table.wiki-notes td.date {
  text-align: right;
  padding-top: 5px;
  padding-bottom: 5px;
}
table.wiki-notes th {
  border-bottom: 1px solid #ffaf37;
}
table.wiki-notes th.title {
  padding-left: 10px;
}
table.wiki-notes td.title {
  background: url('${url("/img/icons.com/wiki_medium_grey.png")}') no-repeat 10px center;
  padding-left: 25px;
}
table.wiki-notes td.title.deleted {
  text-decoration: line-through;
}
#new-note-button {
  margin-bottom: 15px;
}
</%def>

<%
if h.check_crowds(['moderator']):
  pages = c.subject.pages
else:
  pages = [page for page in c.subject.pages if not page.isDeleted()]
%>

%if len(pages):
  %if c.user:
    ${h.button_to(_('Create new Wiki note'),
                  url(controller='subjectpage', action='add', id=c.subject.subject_id, tags=c.subject.location_path),
                  id='new-note-button',
                  class_='dark add',
                  method='GET')}
  %endif
  ## show teacher notes before the rest (python sort is stable)
  <% pages = sorted(pages, lambda x, y: int(y.original_version.created.is_teacher) - \
                                        int(x.original_version.created.is_teacher)) %>
  <table class="wiki-notes">
    <tr>
      <th class="title">${_("Wiki note")}</th>
      <th class="author">${_("Created (edited) by")}</th>
      <th class="date">${_("Date")}</th>
    </tr>
    %for page in pages:
    <tr>
      <td class="title${' deleted' if page.isDeleted() else ''}"><a href="${page.url()}" title="${page.title}">${page.title}</a></td>
      <td class="author"><a href="${page.last_version.created.url()}">${page.last_version.created.fullname}</a></td>
      <td class="date">${h.when(page.last_version.created_on)}</td>
    </tr>
    %endfor
  </table>
%else:
  <p class="notice">${_("No Wiki notes in this subject.")}</p>
  <div class="feature-box icon-note">
    <div class="title">
      ${_("About Wiki notes:")}
    </div>
    <div class="clearfix">
      <div class="feature icon-edit-note">
        <strong>${_("Shared notes")}</strong>
        - ${_("Create wiki notes collaborating with your groupmates. Everyone who follows the subject can edit it's wiki notes.")}
      </div>
      <div class="feature icon-class-note">
        ${h.literal(_("<strong>Take notes during lecture</strong> on your laptop and upload it directly to Ututi."))}
      </div>
    </div>
    <div class="action-button">
      ${h.button_to(_('Create new Wiki note'),
                    url(controller='subjectpage', action='add', id=c.subject.subject_id, tags=c.subject.location_path),
                    method='GET',
                    class_='add')}
    </div>
  </div>
%endif
