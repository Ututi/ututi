<%inherit file="/portlets/base.mako"/>

<%def name="user_subjects_portlet(user=None)">
  <%
     if user is None:
         user = c.user
  %>
  <%self:portlet id="subject_portlet" portlet_class="inactive">
    <%def name="header()">
      ${_('Watched subjects')}
    </%def>
    %if not user.watched_subjects:
      ${_('You are not watching any subjects.')}
    %else:
    <ul id="user-subjects" class="subjects-list">
      % for subject in user.watched_subjects[:5]:
      <li>
        <a href="${subject.url()}" title="${subject.title}">${h.ellipsis(subject.title, 35)}</a>
      </li>
      % endfor
    </ul>
    %endif

    ${h.link_to(_('More subjects'), url(controller='profile', action='search', obj_type='subject'), class_="more")}
    <span>
      ${h.button_to(_('Watch subjects'), url(controller='profile', action='subjects', id=user.id))}
      ${h.image('/images/details/icon_question.png',
                alt=_("Add watched subjects to your watched subjects' list and receive notifications about changes in these subjects"),
                class_='tooltip')|n}
    </span>

  </%self:portlet>
</%def>

<%def name="user_groups_portlet(user=None, title=None, full=True)">
  <%
     if user is None:
         user = c.user

     if title is None:
       title = _('My groups')
  %>
  <%self:portlet id="group_portlet" portlet_class="inactive">
    <%def name="header()">
      ${title}
    </%def>
    % if not user.memberships:
      ${_('You are not a member of any.')}
    %else:
    <ul>
      % for membership in user.memberships:
      <li>
        <div class="group-listing-item">
          %if membership.group.logo is not None:
            <img class="group-logo" src="${url(controller='group', action='logo', id=membership.group.group_id, width=25, height=25)}" alt="logo" />
          %else:
            ${h.image('/images/details/icon_group_25x25.png', alt='logo', class_='group-logo')|n}
          %endif
            <a href="${membership.group.url()}">${membership.group.title}</a>
            (${ungettext("%(count)s member", "%(count)s members", len(membership.group.members)) % dict(count = len(membership.group.members))})
            <br class="clear-left"/>
        </div>
      </li>
      % endfor
    </ul>
    %endif
    %if full:
    <div class="footer">
      ${h.link_to(_('More groups'), url(controller='profile', action='search', obj_type='group'), class_="more")}
      <span>
        ${h.button_to(_('Create group'), url(controller='group', action='add'))}
        ${h.image('/images/details/icon_question.png', alt=_('Create your group, invite your classmates and use the mailing list, upload private group files'), class_='tooltip')|n}
      </span>
    </div>

    %endif
  </%self:portlet>
</%def>

<%def name="user_support_portlet(user=None, title=None, full=True)">
  %if c.tpl_lang == 'lt':
    <%
       if user is None:
           user = c.user

       if title is None:
         title = _('Support us')
    %>
    <%self:uportlet id="support_portlet" portlet_class="orange">
      <%def name="header()">
        ${title}
      </%def>

      <p class="blark">
        ${h.literal(_('You like <a href="%(url)s">Ututi</a> and you want to contribute? Support us!') % dict(url=url('/')))}
      </p>
      <div style="margin-top: 10px;">
      ${h.button_to(_('Support now'), url(controller='profile', action='support'), class_="btnMedium", method="GET")}
      </div>
      <br class="clear-left" />
      <div class="click2show">
		<div class="right_arrow click"><a href="">${_("supporters")}</a></div>
        <ul id="supporter_list" class="show">
          %for supporter in c.ututi_supporters:
            <li>${h.link_to(supporter.fullname, supporter.url())}</li>
          %endfor
        </ul>
      </div>
    </%self:uportlet>
  %endif
</%def>


<%def name="user_information_portlet(user=None, full=True, title=None)">
  <%
     if user is None:
         user = c.user

     if title is None:
         title = _('My profile')
  %>
  <%self:uportlet id="user_information_portlet" portlet_class="MyProfile">
    <%def name="header()">
      ${title}
    </%def>
	<div class="profile">
		<div class="floatleft avatar">

            %if user.logo is not None:
              <img src="${url(controller='user', action='logo', id=user.id, width=70, height=70)}" alt="logo" />
            %else:
              ${h.image('/img/profile-avatar.png', alt='logo')|n}\
            %endif
		</div>
		<div class="floatleft personal-data">
			<div><h2>${user.fullname}</h2></div>
			<div><a href="mailto:${user.emails[0].email}">${user.emails[0].email}</a></div>
			<div class="medals" id="user-medals">
              %for medal in user.all_medals():
                ${medal.img_tag()}
              %endfor
            </div>
			<div>${_('Files uploaded:')}<span class="orange"> ${len(user.files())}</span></div>
		</div>
		<div class="clear"></div>
	</div>
##    <div class="profile">Šią savaitę dar gali atsisiųsti:<img src="img/icons/indicator.png" alt="" class="indicator"><span class="verysmall">75Mb</span>
##      <p class="img-button">
##        <form action="">
##          <fieldset>
##    	    <legend class="a11y">pridėti</legend>
##    	    <label><span><button value="submit" class="btn"><span>padidinti atsiuntimų kiekį</span></button></span></label>
##          </fieldset>
##        </form>
##      </p>
##    </div>
##    <div class="profile"><p>Nori daugiau?</p>
##      <div class="isplesk-button floatleft"><a href="">išplėsk profilį</a></div>
##      <p class="qu"><a href=""><img src="img/icons/question_sign.png" alt="" class="img-question-button"></a></p>
##	</div>
    %if user.site_url:
    <p class="user-link">
      <a href="${user.site_url}">${user.site_url}</a>
    </p>
    %endif
	<div class="right_arrow"><a href="${url(controller='profile', action='edit')}">${_('Edit your profile')}</a></div>

  </%self:uportlet>
</%def>

<%def name="user_create_subject_portlet(user=None)">
  <%
     if user is None:
         user = c.user
  %>
  <%self:action_portlet id="subject_create_portlet">
    <%def name="header()">
    <a class="blark" ${h.trackEvent(None, 'click', 'user_new_subject', 'action_portlets')} href="${url(controller='subject', action='add')}">${_('create new subject')}</a>
    ${h.image('/images/details/icon_question.png',
            alt=_("Store all the subject's files and notes in one place."),
             class_='tooltip', style='margin-top: 4px;')|n}

    </%def>
  </%self:action_portlet>
</%def>

<%def name="user_create_group_portlet(user=None)">
  <%
     if user is None:
         user = c.user
  %>
  <%self:action_portlet id="group_create_portlet">
    <%def name="header()">
    <a class="blark" ${h.trackEvent(None, 'click', 'user_new_group', 'action_portlets')} href="${url(controller='group', action='group_type')}">${_('create new group')}</a>
    ${h.image('/images/details/icon_question.png',
            alt=_("Communicate with your classmates, colleagues and friends, share files and news together!"),
             class_='tooltip', style='margin-top: 4px;')|n}

    </%def>
  </%self:action_portlet>
</%def>

<%def name="user_recommend_portlet(user=None)">
  <%
     if user is None:
         user = c.user
  %>
  <%self:action_portlet id="user_recommend_portlet" expanding="True" label="ututi_recommend">
    <%def name="header()" >
    ${_('recommend Ututi to your friends')}
    </%def>

    <div id="recommendation_status">
    </div>
    <form method="post"
          action="${url(controller='home', action='send_recommendations')}" id="ututi_recommendation_form">
      <div class="form-field">
        <input type="hidden" name="came_from" value="${request.url}" />
        <label class="textField" for="recommend_emails">${_('Enter the emails of your groupmates, separated by commas or new lines.')}
          <textarea name="recommend_emails" id="recommend_emails" rows="4"></textarea>
        </label>
      </div>

      <div class="form-field">
        <br />
        <button class="btn" id="recommendation_submit" type="submit" value="${_('Send invitation')}" ${h.trackEvent(None, 'action_portlets', 'send', 'ututi_recommend')}>
          <span>${_('Send invitation')}</span>
        </button>
      </div>
    </form>
    <br />
  <script type="text/javascript">
  //<![CDATA[
    $(document).ready(function() {
      $('#recommendation_submit').click(function() {
        $(this).parents('.form-field').addClass('loading');
        _gaq.push(['_trackEvent', 'action_portlets', 'send', 'ututi_recommend']);
        $.post("${url(controller='home', action='send_recommendations', js=1)}",
            $(this).parents('form').serialize(),
            function(data) {
              status = $('#recommendation_status').text('').append(data);
              $('#recommendation_submit').parents('.form-field').removeClass('loading');
              $('#recommend_emails').val('');
            });
        return false;
      });
    });
  //]]>
  </script>


  </%self:action_portlet>
</%def>

<%def name="blog_portlet()">
  <%def name="entry(entry)">
    <div class="teaser">
      ${entry.content|n}
    </div>
  </%def>
  %if c.blog_entries:
    <%self:uportlet id="blog_portlet" portlet_class="">
      <%def name="header()">
        ${_('Ututi news')}
        <div style="float: right;">
          <div class="blog_pager" id="blog_bk"></div>
          <div class="blog_pager" id="blog_fwd"></div>
        </div>
      </%def>
    <div id="entries">
      %for blog_entry in c.blog_entries:
      ${entry(blog_entry)}
      %endfor
    </div>

    ${h.javascript_link('/javascript/jquery.cycle.all.js')|n}
    <script type="text/javascript">
    //<![CDATA[
    $('#entries').cycle({
        'fx': 'scrollHorz',
        'next': '#blog_fwd',
        'prev': '#blog_bk',
        'timeout': 0,
      });
    //]]>
    </script>

    <div class="footer">
      <a class="more" href="${_('ututi_blog_url')}">${_('More news')}</a>
    </div>
    </%self:uportlet>
  %endif
</%def>
