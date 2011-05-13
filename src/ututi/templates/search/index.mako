<%inherit file="/base.mako" />
<%namespace file="/widgets/tags.mako" import="*"/>
<%namespace file="/portlets/facebook.mako" import="*"/>

<%def name="body_class()">anonymous_index</%def>

<%def name="portlets()">
  ${facebook_likebox_portlet()}
</%def>

<%def name="title()">
${_('Search')}
</%def>

<%def name="search_location_tag(tag)">
<div class="location_block">
  %if tag.logo is not None:
  <div class="logo">
    <img src="${url(controller='structure', action='logo', id=tag.id, width=26, height=26)}" alt="logo" />
  </div>
  %elif tag.parent is not None and tag.parent.logo is not None:
  <div class="logo">
    <img src="${url(controller='structure', action='logo', id=tag.parent.id, width=26, height=26)}" alt="logo" />
  </div>
  %endif
  <div class="title">
    %if tag.parent is not None:
    <a href="${tag.parent.url()}" title="${tag.parent.title}">${h.ellipsis(tag.parent.title, 70)}</a> ∘
    %endif
    <a href="${tag.url()}" title="${tag.title}">${h.ellipsis(tag.title, 70)}</a>
  </div>
  <div class="stats">
    <span>
        <%
           cnt = tag.count('subject')
        %>
        ${ungettext("%(count)s subject", "%(count)s subjects", cnt) % dict(count = cnt)|n}
    </span>
    <span>
        <%
           cnt = tag.count('group')
        %>
        ${ungettext("%(count)s group", "%(count)s groups", cnt) % dict(count = cnt)|n}
    </span>
    <span>
        <%
           cnt = tag.count('file')
        %>
        ${ungettext("%(count)s file", "%(count)s files", cnt) % dict(count = cnt)|n}
    </span>
  </div>
</div>
</%def>

<%def name="location_tag_results(results=None)">
<%
   if results is None:
       results = getattr(c, 'tag_search', [])
%>
%if results:
<div id="location-search" class="rounded">
  <div class="block-title">${_('Were you looking for a university or department?')}</div>
  %for result in results:
    ${search_location_tag(result.tag)}
  %endfor
<br />
</div>
%endif
</%def>

<%def name="search_form(text='', obj_type='*', tags='', parts=['obj_type', 'text'], target=None, js_target=None, js=False)">
${h.javascript_link('/javascript/js-alternatives.js')|n}
${h.javascript_link('/javascript/search.js')|n}
<%
   if js and js_target is None:
       js = False

   if target is None:
       target = url(controller='search', action='index')
%>
<div class="search-controls">
  <form method="get" action="${target}" id="search_form">
    <div class="search-text-submit">
      %if 'text' in parts:
        <input type="text" name="text" id="text" value="${text}" size="60"/>
      %endif
      <button type="submit" value="${_('Search-btn')}" id="search-btn">
        ${_('Search-btn')}
      </button>
    </div>
    %if 'obj_type' in parts:
    <%
       types = [('subject', _('show-subjects')), ('file', _('show-files')), ('page', _('show-pages')), ('group', _('show-groups')), ('forum_post', _('show-posts')), ('*', _('show-everything'))]
    %>
    <div class="search-type js-alternatives">
      <div class="js">
        <div class="search-type-label">${_('Show only:')}</div>
        %for value, title in types:
          <%
             cls = value == obj_type and 'active' or ''
             id = value == '*' and 'any' or value
          %>
          <div id="search-type-${id}" class="search-type-item ${cls}">${title}</div>
        %endfor
      </div>
      <div class="non-js">
        <select name="obj_type" id="obj_type">
          %for value, title in types:
            %if value == obj_type:
              <option value="${value}" selected="selected">${title}</option>
            %else:
              <option value="${value}">${title}</option>
            %endif
          %endfor
        </select>
      </div>
    </div>
    %else:
      <input type="hidden" name="obj_type" value="${obj_type}" />
    %endif

  </form>
  %if js:
  <script type="text/javascript">
  //<![CDATA[
    function submit_search(element) {
         $(element).parents('.search-controls').addClass('loading');
         $.post("${js_target}", $(element).parents('form').serialize(), function(data) {
                $('#search-results-container').replaceWith(data);
                $('.search-controls').removeClass('loading');
         });
    };

    $(document).ready(function() {
      %if 'tags' in parts:
      $('#tags').change(function() {submit_search(this);});
      %endif
      %if 'obj_type' in parts:
      $('#obj_type').change(function() {submit_search(this);});
      %endif
      $('#search-btn').click(function() {
        submit_search(this);
        return false;
      });
    });
  //]]>
  </script>
  %endif
</div>
</%def>

<%def name="search_results_item(item)">
  ${item.object.snippet()}
</%def>

<%def name="search_results(results=None, display=None, controller=None, action=None)">
<%
   if display is None:
       display = search_results_item
   if results == '':
       results = None
%>
%if results is not None:
<div id="search-results-container" class="search-results-container">
  %if getattr(c, 'page', 1) == 1:
    ${location_tag_results()}
  %endif
    %if hasattr(caller, 'header'):
      <div class="search-results-header">
        ${caller.header()}
      </div>
    %else:
    <h3 class="underline search-results-title">
      <span>${_('search results')}:</span>
      <span class="result-count">(${ungettext("found %(count)s result", "found %(count)s results", results.item_count) % dict(count = results.item_count)})</span>
    </h3>
    %endif
  %if results.item_count > 0:
    <div id="search-results">
      %for item in results:
        ${display(item)}
      %endfor
    </div>
  %else:
    <div class="notice">${_('No results found.')}</div>
    <br />
  %endif

  %if len(results) and results.page_count > 1:
    %if controller is not None and action is not None:
    <div id="pager">${results.pager(format='~3~', controller=controller, action=action, onclick='$("#pager").addClass("loading"); $("#search-results-container").load("%s", function () { $(document).scrollTop($("#search-results-container").scrollTop()); }); return false;') }</div>
    %else:
    <div id="pager">${results.pager(format='~3~')}</div>
    %endif
  %endif
</div>
%else:
<div id="search-results-container"></div>
%endif
</%def>

<h1>${_('Search')}</h1>
${search_form(c.text, c.obj_type, c.tags, parts=['obj_type', 'text', 'tags'], js=True,  js_target=url(controller='search', action='search_js'))}

${search_results(c.results, controller='search', action='search_js')}


