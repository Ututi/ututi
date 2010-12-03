<%inherit file="/profile/home_base.mako" />

<%def name="phone_confirmed()">
<div id="phone_confirmed">
  <div class="wrapper">
    <div class="inner" style="height: 50px; font-weight: bold;">
      <br />
      ${_('Your phone has been confirmed. Thank you.')}
    </div>
  </div>
</div>
</%def>

<%def name="group_list()">
<div id="SearchResults">
  <% groups = c.user.groups %>
  %if groups:
  <%self:rounded_block class_='portletGroupFiles smallTopMargin'>
  <div class="GroupFiles GroupFilesGroups">
    <h2 class="portletTitle bold">${_('Groups')}</h2>
    <span class="group-but">
      ${h.button_to(_('create group'), url(controller='group', action='group_type'), onclick="_gaq.push(['_trackEvent', 'profile', 'groups', 'create_group']);")}
    </span>
  </div>
  %for n, group in enumerate(groups):
  <div class="GroupFilesContent-line${' GroupFilesContent-line-last' if n == len(groups) -1 else ''}">
    <div>
      <div class="profile">
        <div class="floatleft avatar-small">
          %if group.has_logo():
          ${h.image(url(controller='group', action='logo', id=group.group_id, width=35, height=35), alt='logo', class_='group-logo')|n}
          %else:
          <img class="group-logo" src="${url(controller='group', action='logo', id=group.group_id, width=36, height=35)}" alt="logo" />
          %endif
        </div>
        <div class="floatleft personal-data">
          <div class="anth3">
            <a class="orange bold anth3" ${h.trackEvent(Null, 'groups', 'title', 'profile')} href="${group.url()}">${group.title}</a>
            <% n_members = h.group_members(group.id) %>
            (${ungettext("%(count)s member", "%(count)s members", n_members) % dict(count=n_members)})</div>
          <div>
            <a class="verysmall grey" ${h.trackEvent(Null, 'groups', 'mailinglist', 'profile')} href="${url(controller='mailinglist', action='new_thread', id=group.group_id)}" title="${_('Mailing list address')}">
              ${group.group_id}@${c.mailing_list_host}
            </a>
          </div>
        </div>
        <div class="clear"></div>
      </div>
    </div>
    <div class="grupes-links">
      <ul class="grupes-links-list">
        %if group.mailinglist_enabled:
        <li>
          <a ${h.trackEvent(Null, 'groups', 'write_message', 'profile')} href="${url(controller='mailinglist', action='new_thread', id=group.group_id)}" title="${_('Mailing list address')}" class="green verysmall">
            ${_('Write message')}
          </a>
        </li>
        <li>
          <a ${h.trackEvent(Null, 'groups', 'messages_or_forum', 'profile')} href="${url(controller='mailinglist', action='index', id=group.group_id)}" class="green verysmall">
            ${_('Group messages')}
          </a>
        </li>
        %else:
        <li>
          <a  ${h.trackEvent(Null, 'groups', 'write_message', 'profile')} href="${url(controller='forum', action='new_thread', id=group.group_id, category_id=group.forum_categories[0].id)}" class="green verysmall">
            ${_('Write message')}
          </a>
        </li>
        <li>
          <a ${h.trackEvent(Null, 'groups', 'messages_or_forum', 'profile')} href="${url(controller='forum', action='categories', id=group.group_id)}" class="green verysmall">
            ${_('Group forum')}
          </a>
        </li>
        %endif

        %if group.wants_to_watch_subjects:
        <li class="dalykai">
          <a ${h.trackEvent(Null, 'groups', 'subjects', 'profile')} href="${url(controller='group', action='subjects', id=group.group_id)}" class="green verysmall">
            ${_('Group subjects')}
          </a>
        </li>
        %endif
        %if group.has_file_area:
        <li class="failai last">
          <a ${h.trackEvent(Null, 'groups', 'files', 'profile')} href="${url(controller='group', action='files', id=group.group_id)}" class="green verysmall">
            ${_('Group files')}
          </a>
        </li>
        %endif
      </ul>
    </div>
  </div>
  %endfor
</%self:rounded_block>
%elif not 'suggest_create_group' in c.user.hidden_blocks_list:
<%self:rounded_block id="user_location" class_="portletNewGroup">
<div class="floatleft usergrupeleft">
  <h2 class="portletTitle bold">${_('Create a group')}</h2>
  <p>${_("It's simple - you only need to know the email addresses of your classmates!")}</p>
  <p>${_("Use the group's mailing list!")}</p>
</div>
<div class="floatleft usergruperight">
  <form action="${url(controller='group', action='group_type')}" method="GET"
        style="float: none">
    <fieldset>
      <legend class="a11y">${_('Create group')}</legend>
      <label><button value="submit" class="btnMedium"><span>${_('create group')}</span></button>
      </label>
    </fieldset>
  </form>
  <div class="right_cross"><a id="hide_suggest_create_group" href="">${_('no, thanks')}</a></div>
</div>
<br class="clear-left" />
<script type="text/javascript">
  //<![CDATA[
      $('#hide_suggest_create_group').click(function() {
          $(this).closest('.portlet').hide();
          $.post('${url(controller='profile', action='js_hide_element')}',
                 {type: 'suggest_create_group'});
          return false;
      });
    //]]>
</script>

</%self:rounded_block>
%endif
</div>
</%def>

<%def name="subject_list(subjects)">
<div id="SearchResults">
%for n, subject in enumerate(subjects):
<div class="${'GroupFilesContent-line-dal' if n != len(subjects) - 1 else 'GroupFilesContent-line-dal-last'}">
  <ul class="grupes-links-list-dalykai">
    <li>
      <dl>
        <dt>
          <span class="bold">
            <a class="subject_title" href="${subject.url()}">${h.ellipsis(subject.title, 60)}</a>
          </span>
          <span class="verysmall">(${_('Subject rating:')} </span><span>${h.image('/images/details/stars%d.png' % subject.rating(), alt='', class_='subject_rating')}<span class="verysmall">)</span></span>
          %for index, tag in enumerate(subject.location.hierarchy(True)):
          <dd class="s-line"><a class="uni" href="${tag.url()}" title="${tag.title}">${tag.title_short}</a></dd>
          <dd class="s-line">|</dd>
          %endfor
          %if subject.lecturer:
          <dd class="s-line">${_('Lect.')} <span class="orange" >${subject.lecturer}</span></dd>
          %endif
        <dt></dt>
        <dd class="files"><span >${_('Files:')}</span> ${h.subject_file_count(subject.id)}</dd>
        <dd class="pages"><span >${_('Wiki pages:')}</span> ${h.subject_page_count(subject.id)}</dd>
        <%
           user_count = subject.user_count()
           group_count = subject.group_count()
           %>
        <dd class="watchedBy"><span >${_('The subject is watched by:')}</span>
          ${ungettext("<span class='orange'>%(count)s</span> user", "<span class='orange'>%(count)s</span> users", user_count) % dict(count=user_count)|n}
          ${_('and')}
          ${ungettext("<span class='orange'>%(count)s</span> group", "<span class='orange'>%(count)s</span> groups", group_count) % dict(count=group_count)|n}
        </dd>
      </dl>
    </li>
  </ul>
</div>
%endfor
</div>
</%def>


%if c.user.location is not None:
${self.location_updated()}
%else:
${self.location_nag(_('Tell us where you are studying'))}
%endif

%if c.user.phone_number is None and not 'suggest_enter_phone' in c.user.hidden_blocks_list:
${self.phone_nag()}
%elif not c.user.phone_confirmed:
${self.phone_confirmation_nag()}
%endif

${group_list()}
%if c.user.memberships:
<div>
  <p>
    <label>
      <input type="checkbox" name="show_group_subjects" id="show_group_subjects" value="true">
      ${_('Show subjects from my groups')}
    </label>
</span></p>
<script type="text/javascript">
  //<![CDATA[
    $('#show_group_subjects').click(function() {
        if ($(this).attr('checked')) {
            $('#subject_list').load("${url(controller='profile', action='js_all_subjects')}");
            // TODO: show a progress indicator as this takes a while.
        } else {
            $('#subject_list').load("${url(controller='profile', action='js_my_subjects')}");
        }
    });
  //]]>
</script>

</div>
%endif

<div id="subject_list">
  %if c.user.watched_subjects:
  <%self:rounded_block class_='portletGroupFiles'>
  <div class="GroupFiles GroupFilesDalykai">
    <h2 class="portletTitle bold">
      ${_('Subjects')}
      <span class="right_arrow verysmall normal normal-font">
        <a href="${url(controller='profile', action='notifications')}"> ${_('notification settings')}</a>
      </span>
    </h2>
    <span class="group-but">
      ${h.button_to(_('add subject'), url(controller='profile', action='watch_subjects'))}
    </span>
  </div>
  <div>
    ${subject_list(c.user.watched_subjects)}
  </div>
</%self:rounded_block>
%elif 'suggest_watch_subject' not in c.user.hidden_blocks_list:
${self.watch_subject_nag()}
%endif
</div>

% if c.fb_random_post:
<script type="text/javascript">
  //<![CDATA[

  $(document).ready(function() {
FB.ui(
   {
     method: 'stream.publish',
     message: '${c.fb_random_post}',
     attachment: {
       name: 'Ututi - your university online',
//       caption: 'The Facebook Connect JavaScript SDK',
       description: (
         '${_('Ututi is Your university online. Here You and Your class mates can create your group online, use the mailing list for communication and the file storage for sharing information.')}'
       ),
       href: '${url('/', qualified=True)}'
     },
     action_links: [
       { text: 'Labas rytas', href: 'ututi.lt' }
     ],
     user_message_prompt: '${_('Share your thoughts about Ututi')}'
   },
   function(response) {
   // We don't need any response messages
   }
 );
});
  //]]>
</script>
% endif
