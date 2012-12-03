<%inherit file="/base.mako" />

<%def name="body_class()">no_sidebar</%def>

<%def name="portlets()">
</%def>

<%def name="joinlink()">
%if c.user is None:
<div class="join_link">
  ${_('Found out enough?')}
  <br />
  <a class="btn-large" href="${url(controller='home', action='register')}">
    <span>
      ${_('Join VUtuti!')}
    </span>
  </a>
</div>
%endif
</%def>

<div id="tour_navigation">
  <a href="#" id="tour_prev">${_('Previous')}</a>
  <span id="pager" ></span>
  <a href="#" id="tour_next">${_('Next')}</a>
</div>
<div id="tour_slides">
  <div class="tour_slide">
    <a name="1" class="anchor">1</a>
    <div class="image">
      ${h.image('/images/tour/%s/1.png' % c.lang, alt='logo')|n}
    </div>
    <div class="text">
      <h2>${_('VUtuti - your university on the web')}</h2>
      <p>
        ${_('Your academic groups and subjects containing '
        'related materials: files, notes and descriptions. ')}
      </p>
      <p>
        ${_('All these things are combined in the handy VUtuti system.')}
      </p>
      ${joinlink()}
    </div>
  </div>

  <div class="tour_slide">
    <a name="2" class="anchor">2</a>
    <div class="image">
      ${h.image('/images/tour/%s/2.png' % c.lang, alt='logo')|n}
    </div>
    <div class="text">
      <h2>${_('What groups can do: email')}</h2>
      <p>
        ${_('It is a communication tool for You and Your classmates. '
        'VUtuti groups work just like mailing lists: every member can '
        'receive these messages in their email account and can reply to '
        'them from there (You do not have to log on to VUtuti every time). ')}
      </p>
      <p>
        ${_('You can always choose not to receive these email messages in the group settings.')}
      </p>
      ${joinlink()}
    </div>
  </div>

  <div class="tour_slide">
    <a name="3" class="anchor">3</a>
    <div class="image">
      ${h.image('/images/tour/%s/3.png' % c.lang, alt='logo')|n}
    </div>
    <div class="text">
      <h2>${_('What groups can do: subjects')}</h2>
      <p>
        ${_('Every group studies subjects. VUtuti also has a catalog '
        'of academic subjects. Here the subjects are classified by the '
        'university and faculty. Every group can mark the subjects it is '
        'studying in the "subjects" area.')}
      </p>
      <p>
        ${_('Members of the group receive notifications about the changes '
        'in all watched subjects: what files were uploaded, pages created '
        'or descriptions changed.')}
      </p>
      <br />
      <p>
        ${_('You can find new subjects by using our search and if they do not '
        'exist - create them :)')}
      </p>
      ${joinlink()}
    </div>
  </div>

  <div class="tour_slide">
    <a name="4" class="anchor">4</a>
    <div class="image">
      ${h.image('/images/tour/%s/4.png' % c.lang, alt='logo')|n}
    </div>
    <div class="text">
      <h2>${_('What groups can do: files')}</h2>
      <p>
        ${_('VUtuti makes it easy to share files. In the "files" area '
        'members of the group can see the private files of the group '
        'and all the files of the subjects the group is watching.')}
      </p>
      <br />
      <p>
        ${_('Private files are kept in a separate folder. Their size is '
        'limited to 200 Mb.')}
      </p>
      <br />
      <p>
        ${_('Public files are kept in the folders belonging to the subjects. '
        'The folders are visible in the group when it is watching these subjects. '
        'The size and amount of public files is not limited. What is more, '
        'files can be added to subjects not only by your group, but also by other '
        'groups and VUtuti members. This makes it easy to share information.')}
      </p>
      ${joinlink()}
    </div>
  </div>

  <div class="tour_slide">
    <a name="5" class="anchor">5</a>
    <div class="image">
      ${h.image('/images/tour/%s/5.png' % c.lang, alt='logo')|n}
    </div>
    <div class="text">
      <h2>${_('What groups can do: events')}</h2>
      <p>
        ${_('All the events of a groups: new members, files, subjects '
        'are visible in the "whats new" section.')}
      </p>
      ${joinlink()}
    </div>
  </div>

  <div class="tour_slide">
    <a name="6" class="anchor">6</a>
    <div class="text">
      <h2>${_('What members can do: subjects')}</h2>
      <p>
        ${_('Not only groups, but also single VUtuti members can watch subjects. '
        'You can easily start watching a subject by visiting its page and clicking on '
        'the link "start watching".')}
      </p>
      <br />
      <p>
        ${_('You can view all the subjects You are watching in the "files" area of Your '
        'profile.')}
      </p>
      <br />
      <p>
        ${_('Here You can also choose to ignore the subjects watched by Your group - by '
        'clicking on the "eye" icon next to a subject You will stop receiving notifications about '
        'its events, but other classmates will continue watching it. ')}
      </p>
      <br />
      <p>
        ${_('What is more, You can specify how often You want to receive email notifications about '
        'events in Your watched subjects.')}
      </p>
      ${joinlink()}
    </div>
    <div class="image">
      ${h.image('/images/tour/%s/6_1.png' % c.lang, alt='logo')|n}
    </div>
    <div class="image">
      ${h.image('/images/tour/%s/6_2.png' % c.lang, alt='logo')|n}
    </div>


  </div>

  <div class="tour_slide">
    <a name="7" class="anchor">7</a>
    <div class="image">
      ${h.image('/images/tour/%s/7.png' % c.lang, alt='logo')|n}
    </div>
    <div class="text">
      <h2>${_('What members can do: home')}</h2>
      <p>
        ${_('In Your home area You will see what is happening in Your group and '
        'the subjects either You or Your group are watching.')}
      </p>
      <br />
      <p>
        ${_('From here You can also easily create a subject, upload a file, '
        'invite people to use VUtuti.')}
      </p>
      ${joinlink()}
    </div>
  </div>
</div>

${h.javascript_link('/javascript/jquery.cycle.all.js')|n}
<script type="text/javascript">
  //<![CDATA[
    $('#tour_slides').cycle({
        'fx': 'scrollVertReverse',
        'next': '#tour_next',
        'prev': '#tour_prev',
        'pager': '#pager',
        'timeout': 0,
        'nowrap': 1,
      });
    //]]>
</script>

