<%inherit file="/profile/base.mako" />

<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/home.css')|n}
${h.stylesheet_link('/stylesheets/suggestions.css')|n}
${h.stylesheet_link('/stylesheets/locationwidget.css')|n}
</%def>

<%namespace file="/widgets/locationtag.mako" import="*"/>

<fieldset>
  <legend>${_('Welcome to Ututi!')}</legend>
  <div id="add-group">
	<h3>${_('Join a group')}</h3>
	<div class="message">${_('You can join your academic group to make communicating and sharing materials with your class mates easier.')}</div>
    <form method="post" action="${url(controller='profile', action='findgroup')}">
      ${location_widget(3)}


      <div class="form-field hidden">
        <label style="display: inline;" for="year">${_("Year of entry:")}</label>
        <select name="year" id="year">
          %for year in c.years:
          %if year == c.current_year:
          <option value="${year}" selected="selected">${year}</option>
          %else:
          <option value="${year}">${year}</option>
          %endif
          %endfor
        </select>
      </div>

      <div class="form-field">
        <span class="btn">
	      <input type="submit" value="${_('Search')}" name="search" id="search" />
        </span>
      </div>
    </form>
  </div>

  <div id="browse-subjects">
	<h3>${_('Browse subjects')}</h3>
	<div class="message">
      ${_('You can browse the %(link_to_list_of_subjects)s, look for information and share coursework. Also you can %(link_to_subject_watching_view)s, so you would not miss anything.') % dict(
           link_to_list_of_subjects=h.link_to(_("list of subjects"), url(controller='search', action='index', obj_type='subject')),
           link_to_subject_watching_view=h.link_to(_("select watched subjects"), url(controller='profile', action='subjects')))|n}
    </div>
  </div>

  <div id="edit-profile">
	<h3>${_('Review and edit your profile')}</h3>
	<div class="message">${_('Fill in your information, upload your photo so that others can recognize you.')}</div>
    <br/>
    <a class="btn" href="${url(controller='profile', action='edit')}" title="${_('Edit your profile')}"><span>${_('Edit your profile')}</span></a>
  </div>

</fieldset>


