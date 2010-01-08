<%inherit file="/profile/base.mako" />

<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/home.css')|n}
${h.stylesheet_link('/stylesheets/suggestions.css')|n}
${parent.head_tags()}
</%def>

  <h1>${_('Welcome to Ututi!')}</h1>
  <div class="welcome-message">
    ${_('Ututi is your university online. Here You and Your class mates can create a <em>group</em> with a mailing list.'
    'You will be able to find the subject You are studying here at Ututi and share your study notes and files with others.')|n}
  </div>

  <div id="join-group" class="gray-box">
    <div class="inner">
      <h2>${_('Join your group')}</h2>
      <div class="description">
        ${_('Here You can find Your group or create one if it does not exist.')}
      </div>
      <a class="btn-large" href="${url(controller='group', action='add')}">
        <span>
          ${_('your group')}
        </span>
      </a>
    </div>
  </div>

  <div id="find-subjects" class="gray-box">
    <div class="inner">
      <h2>${_('Find your subjects')}</h2>
      <form method="post" action="${url(controller='profile', action='search')}" id="findsubject-form">
        <div>
          <input type='hidden' name='obj_type' value='subject' />
          ${location_widget(2, add_new=False, live_search=False)}
          ${h.input_submit(_('Search'))}
        </div>
      </form>
    </div>
  </div>

  <div id="update-profile">
    <table>
      <tr>
        <td>
          <h2>${_('Update your profile')}</h2>
          <div class="description">
            ${_('Let Your friends know who You are, so they can trust the information You upload.')}
          </div>
        </td>
        <td class="action">
          <a href="${url(controller='profile', action='edit')}" class="btn">
            <span>${_('edit your profile')}</span>
          </a>
        </td>
      </tr>
    </table>
  </div>

  <div class="tour-link">
    ${_("New to Ututi? Don't know how to use it?")}
    <a class="btn-large tour" href="${url(controller='home', action='tour')}">
      <span>${_('Find out more')}</span>
    </a>
  </div>
