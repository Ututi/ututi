<%inherit file="/profile/base.mako" />

<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/home.css')|n}
${h.stylesheet_link('/stylesheets/suggestions.css')|n}
${h.stylesheet_link('/stylesheets/locationwidget.css')|n}
</%def>

<%namespace file="/widgets/locationtag.mako" import="*"/>

  <h1>${_('Welcome to Ututi!')}</h1>
  <div id="add-group">
	<h3>${_('Join a group')}
      <span class="tooltip">
        ?
        <span class="content">${_('Create your group, invite your classmates and use the mailing list, upload private group files')}</span>
      </span>
    </h3>
	<div class="message">${_('You can join your academic group to make communicating and sharing materials with your class mates easier.')}</div>
    <form method="post" action="${url(controller='profile', action='findgroup')}" id="findgroup-form">
      ${location_widget(2)}


      <div class="form-field hidden" id="year-input">
        <label for="year" class="inline-label">${_('entrance year')}</label>
        <div class="input-rounded">
          <div>
            <input type="text" name="year" id="year" value=""/>
          </div>
        </div>

        <script type="text/javascript">
        //<![CDATA[
        var years = [\
        %for year in range(c.current_year - 10, c.current_year+1):
          "${year}",
        %endfor
        ];
        $('#year').autocomplete(years, {\
          cacheLength: 200,
          max: 10,
          matchCase: false,
          minChars: 0,
          matchSubset: true,
          matchContains: false,
          mustMatch: true,
          selectFirst: true,
        });
        //]]>
        </script>
      </div>
      <br style="clear: left; margin: 0; height: 0; padding: 0;"/>
      <div class="form-field">
        <span class="btn">
	      <input type="submit" value="${_('Search')}" name="search" id="search" />
        </span>
      </div>
      <br style="clear: left; margin: 0; height: 0; padding: 0;"/>
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
    <br />
    <a class="btn" href="${url(controller='profile', action='edit')}" title="${_('Edit your profile')}"><span>${_('Edit your profile')}</span></a>
  </div>


