<%inherit file="/base.mako" />
<%namespace file="/widgets/tags.mako" import="*"/>
<%namespace file="/portlets/anonymous.mako" import="*"/>

<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
${h.stylesheet_link('/stylesheets/anonymous.css')|n}
</%def>

<%def name="portlets()">
<div id="sidebar">
  ${ututi_join_portlet()}
</div>
</%def>


<%def name="title()">
${_('Search')}
</%def>

<%def name="search_form(text='', obj_type='*', tags='', parts=['obj_type', 'text', 'tags'], target=None, js_target=None, js=False)">
${h.javascript_link('/javascripts/js-alternatives.js')|n}
${h.javascript_link('/javascripts/search.js')|n}
<%
   if js and js_target is None:
       js = False

   if target is None:
       target = url(controller='search', action='index')
%>
<div class="search-controls">
  <form method="get" action="${target}" id="search_form">
    %if 'obj_type' in parts:
    <%
       types = [('*', _('Everywhere')), ('group', _('Groups')), ('subject', _('in-Subjects'))]
    %>
    <div class="search-type js-alternatives">
      <div class="js">
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
    %endif
    <div class="search-text-submit">
      %if 'text' in parts:
        <div class="search-text">
          <div>
            <input type="text" name="text" id="text" value="${text}" size="60"/>
          </div>
        </div>
      %endif
      <div class="search-submit">
        <span class="btn-large">
          <input type="submit" id="search-btn" value="${_('Search-btn')}"/>
        </span>
      </div>
      <br style="clear: left;"/>
    </div>
    %if 'tags' in parts:
      <div class="search-tags">
          <label for="tags">${_('Filter by school:')}</label>
          ${tags_widget(tags, all_tags=True)}
      </div>
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
<div id="search-results-container">
  <h3 class="underline search-results-title">
    <span>${_('results')}:</span>
    <span class="result-count">(${ungettext("found %(count)s result", "found %(count)s results", results.item_count) % dict(count = results.item_count)})</span>
  </h3>
  %if c.results.item_count > 0:
    <div id="search-results">
      %for item in results:
        ${display(item)}
      %endfor
    </div>
  %else:
    <div class="notice">${_('No results found.')}</div>
    <br />
  %endif

  %if len(results):
    %if controller is not None and action is not None:
    <div id="pager">${results.pager(format='~3~', controller=controller, action=action) }</div>
    %else:
    <div id="pager">${results.pager(format='~3~') }</div>
    %endif
  %endif
</div>
%else:
<div id="search-results-container"></div>
%endif
</%def>

<h1>${_('Search')}</h1>
${search_form(c.text, c.obj_type, c.tags, parts=['obj_type', 'text', 'tags'], js=True,  js_target=url(controller='search', action='search_js'))}

${search_results(c.results)}


