<%inherit file="/base.mako" />

<%def name="head_tags()">
<title>UTUTI – student information online</title>
</%def>

<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/home.css')|n}
${h.stylesheet_link('/stylesheets/suggestions.css')|n}

</%def>

<%namespace file="/widgets/locationtag.mako" import="*"/>

<fieldset>
  <legend>${_('Welcome to Ututi!')}</legend>
  <div id="add-group">
	<h3>${_('Join a group')}</h3>
	<div class="message">${_('You can join your academic group to make communicating and sharing materials with your class mates easier.')}</div>
    <form method="post" action="${url(controller='search', action='search')}">
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

  <div id="edit-profile">
	<h3>${_('Review and edit your profile')}</h3>
	<div class="message">${_('Fill in your information, upload your photo so that others can recognize you.')}</div>
    <br/>
    <a class="btn" href="${url(controller='profile', action='edit')}" title="${_('Edit your profile')}"><span>${_('Edit your profile')}</span></a>
  </div>

</fieldset>


