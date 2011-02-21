<%inherit file="/ubase-nomenu.mako" />

<%def name="location_tag(uni)">
<div class="university_block">
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
	<a href="${uni['url']}" title="${uni['title']}">${h.ellipsis(uni['title'], 36)}</a>
  </div>
  <div class="stats">
	<span>
	  ${ungettext("%(count)s subject", "%(count)s subjects", uni['n_subjects']) % dict(count=uni['n_subjects'])|n}
	</span>
	<span>
	  ${ungettext("%(count)s group", "%(count)s groups", uni['n_groups']) % dict(count=uni['n_groups'])|n}
	</span>
	<span>
	  ${ungettext("%(count)s file", "%(count)s files", uni['n_files']) % dict(count=uni['n_files'])|n}
	</span>
  </div>
</div>
</%def>

<%def name="universities(unis, ajax_url)">
	%for uni in unis:
	  ${location_tag(uni)}
	%endfor
	<div id="pager">
	  ${unis.pager(format='~3~',
					 partial_param='js',
					 onclick="$('#pager').addClass('loading'); $('#university-list').load('%s'); return false;") }
	</div>
	<div id="sorting">
	  ${_('Sort by:')}
	  <%
		 url_args_alpha = dict(sort='alpha')
		 url_args_pop = dict(sort='popular')
		 if request.params.get('region_id'):
			 url_args_alpha['region_id'] = request.params.get('region_id')
			 url_args_pop['region_id'] = request.params.get('region_id')
	  %>
	  <a id="sort-alpha" class="${c.sort == 'alpha' and 'active' or ''}" href="${url(ajax_url, **url_args_alpha)}">${_('name')}</a>
	  <input type="hidden" id="sort-alpha-url" name="sort-alpha-url" value="${url(ajax_url, js=True, **url_args_alpha)}" />
	  <a id="sort-popular" class="${c.sort == 'popular' and 'active' or ''}" href="${url(ajax_url, **url_args_pop)}">${_('popularity')}</a>
	  <input type="hidden" id="sort-popular-url" name="sort-popular-url" value="${url(ajax_url, js=True, **url_args_pop)}" />
	</div>
</%def>

<%def name="universities_section(unis, ajax_url, collapse=True, collapse_text=None)">
  <%
	 if collapse_text is None:
	   collapse_text = _('More universities')
  %>
  %if unis:
  <div id="university-list" class="${c.teaser and 'collapsed_list' or ''}">
	${universities(unis, ajax_url)}
  </div>
  %if collapse and len(unis) > 6:
	%if c.teaser:
	  <div id="teaser_switch" style="display: none;">
		<span class="files_more">
		  <a class="green verysmall">
			${collapse_text}
		  </a>
		</span>
	  </div>
	%endif
	<script type="text/javascript">
	//<![CDATA[
	  $(document).ready(function() {
		$('#university-list.collapsed_list').data("preheight", $('#university-list.collapsed_list').height()).css('height', '115px');
		$('#teaser_switch').show();
		$('#teaser_switch a').click(function() {
		  $('#teaser_switch').hide();
		  $('#university-list').animate({
			height: $('#university-list').data("preheight")},
			200, "linear",
			function() {
			  $('#university-list').css('height', 'auto');
			});
		  return false;
		});
	  });
	//]]>
	</script>
  %endif
  <script type="text/javascript">
  //<![CDATA[
	$(document).ready(function() {
	  $('#sort-alpha,#sort-popular').live("click", function() {
		var url = $('#'+$(this).attr('id')+'-url').val();
		$('#sorting').addClass('loading');
		$('#university-list').load(url);
		return false;
	  });
	});
  //]]>
  </script>
  %endif
</%def>


<div id="sign-in-area">
  <h1>${_("Sign up to join your university's social network or create it yourself")}</h1>
  <form id="sign-up-form" method="POST" action="${url('start_registration')}">
	<div class="error"><span>${_("Your email adress is not valid")}</span></div>
	<fieldset id="register-fieldset">
      <input type="text" value="" name="email" id="email" class="email-input" />
      ${h.input_submit(_('Sign Up'))}
	</fieldset>
	<div class="notice">${_("Only people with a verified university / college email address can join your network.")}</div>
  </form>
</div>
<div id="feature-area">
  <div class="column" id="social-discussions">
	<h1>${_("Social discussions between students and teachers")}</h1>
	<p>${_("On Ututi students and teachers can discuss course material, academical matters and university life in a modern way.")}</p>
  </div>
  <div class="column" id="network">
	<h1>${_("Private social network for your university or college")}</h1>
	<p>${_("Ututi lets You create a social network for Your university. Here You will find online groups, teachers profiles and course pages - a tool to share information and build your online community.")}</p>
  </div>
  <div class="column" id="teachers-profile">
	<h1>${_("Easy to use teachers accounts")}</h1>
	<p>${_("Teachers can create their website, share course materials and communicate with their students at Ututi. And they can do it easily.")}</p>
  </div>
</div>
<div class="center">
  <button id="learn-more" name="about">Learn more about Ututi</button>
</div>
