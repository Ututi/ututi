<%inherit file="/profile/base.mako" />
<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>

<%def name="head_tags()">
${parent.head_tags()}
<%newlocationtag:head_tags />
</%def>

<%def name="location_updated()">
  <div id="user_location">
    <div class="wrapper">
      <div class="inner" style="height: 50px; font-weight: bold;">
        <br />
        ${_('Your university information has been updated. Thank you.')}
      </div>
    </div>
  </div>
</%def>

%if c.user.location is not None:
<div class="my-faculty"><a href="${c.user.location.url()}">${_('Go to my department')}</a></div>
%else:
  <%self:rounded_block id="user_location" class_="portletSetLocation">
  <div class="inner">
    <h2 class="portletTitle bold">${_('Tell us where you are studying')}</h2>
    <form method="post" action="${url(controller='profile', action='update_location')}" id="update-location-form"
          style="float: none">
      ${location_widget(2, add_new=(c.tpl_lang=='pl'), live_search=True, label_class="label")}
      ${h.input_submit(_('save'), id='user-location-submit')}
    </form>
  </div>
  </%self:rounded_block>
  <script type="text/javascript">
  //<![CDATA[

  $('#user-location-submit').click(function() {
    $('#user_location').addClass('loading');
    $.post('${url(controller='profile', action='js_update_location')}',
      $(this).parents('form').serialize(),
      function(data, status) {
        if (status == 'success') {
          $('#user_location .inner').replaceWith(data);
        }
        $('#user_location').removeClass('loading');
      });
    return false;
  });
  //]]>
  </script>
%endif

%if c.user.phone_number is None:
  <%self:rounded_block id="user_phone" class_="portletConfirmPhone">
  <div class="inner">
    <h2 class="portletTitle bold">${_("What's your phone number?")}</h2>
    <p class="explanation">
      ${_("We need your phone number so that you could send and receive SMS messages from the group. Don't worry, we will never send advertisements.")}
    </p>
    <form method="post" action="${url(controller='profile', action='update_phone_number')}" id="update-phone-number-form"
          style="float: none; padding-top: 5px">
      <div class="floatleft">
        ${h.input_line('phone_number', _('Mobile phone number: '))}
      </div>
      <div class="floatleft" style="padding-left: 3px; margin-top: -1px">
        ${h.input_submit(_('save'), id='user-phone-submit')}
      </div>
      <div class="clear"></div>
    </form>
  </div>
  </%self:rounded_block>
  <script type="text/javascript">
  //<![CDATA[

  $('#user-phone-submit').click(function() {
    $('#user_phone').addClass('loading');
    $.post('${url(controller='profile', action='js_update_phone')}',
      $(this).parents('form').serialize(),
      function(data, status) {
        if (status == 'success') {
          $('#user_phone').replaceWith(data);
        }
        $('#user_phone').removeClass('loading');
      });
    return false;
  });
  //]]>
  </script>
%endif

<%def name="phone_updated()">
  <%self:rounded_block id="user_phone_confirm" class_="portletConfirmPhone">
  <div class="inner">
    <h2 class="portletTitle bold">${_("Please confirm your phone number")}</h2>
    <p class="explanation">
      ${_("Enter the confirmation code that you received by SMS to prove that this number belongs to you.")}
    </p>
    <form method="post" action="${url(controller='profile', action='confirm_phone_number')}" id="confirm-phone-number-form"
          style="float: none; padding-top: 5px ">
      <div class="floatleft">
        ${h.input_line('phone_confirmation_key', _('Confirmation code: '))}
      </div>
      <div class="floatleft" style="padding-left: 3px; margin-top: -1px">
        ${h.input_submit(_('save'), id='confirmation-code-submit')}
      </div>
      <div class="clear"></div>
    </form>
  </div>
  </%self:rounded_block>
  <script type="text/javascript">
  //<![CDATA[

  $('#confirmation-code-submit').click(function() {
    $('#user_phone_confirm').addClass('loading');
    $.post('${url(controller='profile', action='js_confirm_phone')}',
    $('form#confirm-phone-number-form').serialize(),
      function(data, status) {
        if (status == 'success') {
          $('#user_phone_confirm .inner').replaceWith(data);
          $('#confirm-phone-flash-message').hide();
        }
        $('#user_phone_confirm').removeClass('loading');
      });
    return false;
  });
  //]]>
  </script>
</%def>

%if c.user.phone_number is not None and not c.user.phone_confirmed:
  ${phone_updated()}
%endif

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

<div id="SearchResults">
%if c.user.memberships:
<%self:rounded_block class_='portletGroupFiles smallTopMargin'>
  <div class="GroupFiles GroupFilesGroups">
    <h2 class="portletTitle bold">${_('Groups')}</h2>
    <span class="group-but">
      ${h.button_to(_('create group'), url(controller='group', action='group_type'))}
    </span>
  </div>
    <%
       count = len(c.user.memberships)
    %>
    %for n, membership in enumerate(c.user.memberships):
    <%
       group = membership.group
    %>
  <div class="GroupFilesContent-line${' GroupFilesContent-line-last' if n == count -1 else ''}">
    <div>
      <div class="profile">
        <div class="floatleft avatar-small">
                    %if group.logo is not None:
                      <img class="group-logo" src="${url(controller='group', action='logo', id=group.group_id, width=36, height=35)}" alt="logo" />
                    %else:
                      ${h.image('/img/avatar-small.png', alt='logo', class_='group-logo')|n}
                    %endif
        </div>
        <div class="floatleft personal-data">
          <div class="anth3">
                    <a class="orange bold anth3" href="${group.url()}">${group.title}</a>
                    (${ungettext("%(count)s member", "%(count)s members", len(group.members)) % dict(count = len(group.members))})</div>
          <div>
                    <a class="verysmall grey" href="${url(controller='mailinglist', action='new_thread', id=group.group_id)}" title="${_('Mailing list address')}">
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
                <a href="${url(controller='mailinglist', action='new_thread', id=group.group_id)}" title="${_('Mailing list address')}" class="green verysmall">
                  ${_('Write message')}
                </a>
              </li>
        <li>
                <a href="${url(controller='mailinglist', action='index', id=group.group_id)}" class="green verysmall">
                  ${_('Group messages')}
                </a>
              </li>
              %else:
        <li>
        <a href="${url(controller='forum', action='new_thread', id=group.group_id, category_id=group.forum_categories[0].id)}" class="green verysmall">
                  ${_('Write message')}
                </a>
              </li>
        <li>
                <a href="${url(controller='forum', action='categories', id=group.group_id)}" class="green verysmall">
                  ${_('Group forum')}
                </a>
              </li>
              %endif

              %if group.wants_to_watch_subjects:
        <li class="dalykai">
                <a href="${url(controller='group', action='subjects', id=group.group_id)}" class="green verysmall">
                  ${_('Group subjects')}
                </a>
              </li>
              %endif
              %if group.has_file_area:
        <li class="failai last">
                <a href="${url(controller='group', action='files', id=group.group_id)}" class="green verysmall">
                  ${_('Group files')}
                </a>
              </li>
              %endif
      </ul>
    </div>
  </div>
    %endfor
</%self:rounded_block>
%elif not c.user.hide_suggest_create_group:
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
               {type: 'hide_suggest_create_group'});
        return false;
    });
  //]]>
  </script>

</%self:rounded_block>
%endif

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
${subjects_block(c.user.watched_subjects)}
</div>
</div>
<%def name="subjects_block(subjects)">
%if subjects:
<%self:rounded_block class_='portletGroupFiles'>
  <div class="GroupFiles GroupFilesDalykai">
    <h2 class="portletTitle bold">
      ${_('Subjects')}
      <span class="right_arrow verysmall normal normal-font">
        <a href="${url(controller='profile', action='subjects')}"> ${_('notification settings')}</a>
      </span>
    </h2>
    <span class="group-but">
      ${h.button_to(_('add subject'), url(controller='profile', action='watch_subjects'))}
    </span>
  </div>
  <div>
    ${subject_list(subjects)}
  </div>
</%self:rounded_block>
%elif not c.user.hide_suggest_watch_subject:
<%self:rounded_block id="user_location" class_="portletNewDalykas">
  <div class="floatleft usergrupeleft">
    <h2 class="portletTitle bold">${_('Watch subjects you are studying!')}</h2>
    <ul id="prosList">
      <li>${_('Find materials shared by others')}</li>
      <li>${_('Get notifications about changes')}</li>
    </ul>
  </div>
  <div class="floatleft usergruperight">
    <form action="${url(controller='profile', action='subjects')}" method="GET"
          style="float: none">
      <fieldset>
        <legend class="a11y">${_('Watch subject')}</legend>
        <label><button value="submit" class="btnMedium"><span>${_('watch subjects')}</span></button>
        </label>
      </fieldset>
    </form>
    <div class="right_cross"><a id="hide_suggest_watch_subject" href="">${_('no, thanks')}</a></div>
  </div>
  <br class="clear-left" />
  <script type="text/javascript">
  //<![CDATA[
    $('#hide_suggest_watch_subject').click(function() {
        $(this).closest('.portlet').hide();
        $.post('${url(controller='profile', action='js_hide_element')}',
               {type: 'hide_suggest_watch_subject'});
        return false;
    });
  //]]>
  </script>

</%self:rounded_block>
%endif
</%def>

<%def name="subject_list(subjects)">
  <%
     count = len(subjects)
  %>
  %for n, subject in enumerate(subjects):
  <div class="${'GroupFilesContent-line-dal' if n != count - 1 else 'GroupFilesContent-line-dal-last'}">
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
      <dd class="files"><span >${_('Files:')}</span> ${len(subject.files)}</dd>
      <dd class="pages"><span >${_('Wiki pages:')}</span> ${len(subject.pages)}</dd>
      <dd class="watchedBy"><span >${_('The subject is watched by:')}</span>
            ${ungettext("<span class='orange'>%(count)s</span> user", "<span class='orange'>%(count)s</span> users", subject.user_count()) % dict(count = subject.user_count())|n}
            ${_('and')}
            ${ungettext("<span class='orange'>%(count)s</span> group", "<span class='orange'>%(count)s</span> groups", subject.group_count()) % dict(count = subject.group_count())|n}
          </dd>
    </dl>
    </li>
  </ul>
##  <div class="cross"><img src="img/icons/cross_big.png" alt=""></div>
  </div>
  %endfor
</%def>
