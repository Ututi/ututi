<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/widgets/vote.mako" import="voting_bar, voting_widget" />

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

