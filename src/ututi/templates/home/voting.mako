<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/widgets/vote.mako" import="voting_bar, voting_widget" />
<%namespace file="/portlets/base.mako" import="uportlet" name="p"/>

<%def name="css()">
.feature_block {
  padding-left: 70px;
  background-position: left top;
  background-repeat: no-repeat;
  color: #333;
  margin-top: 10px;
}
</%def>

<%def name="portlets()">
  <%p:uportlet id="share_portlet">
    <%def name="header()">
    ${_('Recommend to a friend')}
    </%def>
    <iframe src="http://www.facebook.com/plugins/like.php?href=www.ututi.lt%2Fvoting&amp;layout=box_count&amp;show_faces=false&amp;width=120&amp;action=recommend&amp;colorscheme=light&amp;height=65" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:120px; height:65px;" allowTransparency="true"></iframe>
    %if c.user and c.user.location is not None:
    <div style="margin-top: 10px; border-top: 1px solid #ddd; padding-top: 5px;">
      <%
         count = 500 - c.user.location.vote_count
      %>
      ${ungettext('Your university needs <strong>%(count)d more vote</strong>.', 'Your university needs <strong>%(count)d more votes.</strong>', count) % dict(count=count)|n}
    </div>
    %endif
  </%p:uportlet>
  <%p:uportlet id="features_portlet" portlet_class="orange">
    <%def name="header()">
    ${_('About the new Ututi')}
    </%def>
    <div class="feature_block" style="background-image: url('/images/details/icon_feature_network.png');">
      <strong>${_('Social network for Your university')}</strong>
      <p>
        ${_('Communicate in the virtual space of Your university, join groups, exchange information.')}
      </p>
    </div>
    <div class="feature_block" style="background-image: url('/images/details/icon_feature_teacher.png');">
      <strong>${_('Teacher profiles')}</strong>
      <p>
        ${_('Teachers will have their profiles on Ututi, will be able to upload course materials and '
            'easily communicate with their students.')}
      </p>
    </div>
    <div class="feature_block" style="background-image: url('/images/details/icon_feature_communication.png');">
      <strong>${_('Discussions')}</strong>
      <p>
        ${_('Discuss not only within groups, but also comment on subjects and uploaded files.')}
      </p>
    </div>
    <div class="right_arrow"><a href="${url(controller='home', action='new_ututi')}">${_('find out more')}</a></div>
  </%p:uportlet>
</%def>

<h2>${_('Vote for your university!')}</h2>
<br/>
<h3>${_('Ututi is growing!')}</h3>
<div>
${_("After two years of development and service here in Lithuania , Ututi is growing and changing."
    " This March we are planning to release a new version, that will be not only a study material"
    " exchange platform. Ututi will become Your university's social network and will connect not"
    " only students but also teachers.")}
</div>
${h.link_to(h.image('/img/transition.png', 'transition'), url(controller='home', action='dotcom'))}
<div>
${_("Going in this new direction, we have decided to transition only the universities that have"
    " an active community. If You want Your university to be a part of the new Ututi this March,"
    " vote here. Only univerisites with 500 votes or more will be transfered.")}
</div>

%if not c.user.has_voted and c.user.location is not None:
<div style="margin: 20px 0; width: 500px;">
<%
   votes = c.user.location.vote_count
%>
${voting_widget(votes)}
<br class="clear-both"/>
<h3>${c.user.location.title}</h3>
</div>
%endif

<h2>${_('Voting results')}</h2>

<%self:rounded_block>
<div style="padding-left: 20px;">
%for uni in c.universities:
<div class="university_block" style="width:270px; margin: 10px 0;">
  %if uni['has_logo']:
    <div class="logo">
      <img src="${url(controller='structure', action='logo', id=uni['id'], width=26, height=26)}" alt="logo" />
    </div>
  %elif uni['parent_has_logo']:
    <div class="logo">
      <img src="${url(controller='structure', action='logo', id=uni['parent_id'], width=26, height=26)}" alt="logo" />
    </div>
  %endif

  <div class="title">
    <a style="font-weight: bold;" href="${uni['url']}" title="${uni['title']}">${h.ellipsis(uni['title'], 40)}</a>
  </div>
  <div class="stats" style="margin-left: 0; margin-top: 5px;">
    ${voting_bar(uni['vote_count'], large=false)}
  </div>
</div>
%endfor
<br style="clear: left;"/>
</div>
</%self:rounded_block>
