<%inherit file="/base.mako" />
<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
</%def>



<%def name="title()">
${_('Search')}
</%def>

<%def name="search_form(text='', obj_type='*', tags='', parts=['obj_type', 'text', 'tags'], target=None)">
${h.javascript_link('/javascripts/js-alternatives.js')|n}
${h.javascript_link('/javascripts/search.js')|n}
<%
   if target is None:
       target = url(controller='search', action='index')
%>
<div class="search-controls">
  <form method="post" action="${target}" id="search_form">
    %if 'obj_type' in parts:
    <%
       types = [('*', _('Everywhere')), ('group', _('Groups')), ('subject', _('Subjects'))]
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
        <select name="obj_type">
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
          <input type="submit" value="${_('Search')}"/>
        </span>
      </div>
      <br style="clear: left;"/>
    </div>
    %if 'tags' in parts:
      <div class="search-tags">
          <label for="tags">${_('Tags')}</label>
          ${tags_widget(tags, all_tags=True)}
      </div>
    %endif

  </form>
</div>
</%def>

<%def name="search_results_item(item)">
  <div class="search-item">
    <a href="${item.object.url()}" title="${item.object.title}" class="item-title larger">${item.object.title}</a>
    <div class="item-tags">
      %for tag in item.object.tags:
      <span class="tag">${tag.title}</span>
      %endfor
    </div>
  </div>
</%def>

<%def name="search_results(results=None, display=None)">
<%
   if display is None:
       display = search_results_item
%>
<h1>Results:</h1>
<div id="search-results">
  %for item in results:
  ${display(item)}
  %endfor
</div>

%if len(results):
<div id="pager">${results.pager(format='~3~') }</div>
%endif
</%def>

<h1>${_('Search')}</h1>
${search_form(c.text, c.obj_type, c.tags, parts=['obj_type', 'text'])}

%if c.results:
${search_results(c.results)}
%endif

%if c.obj_type == 'group':
  <div class="create_item">
    ${_('Did not find what you were looking for?')}
    ${h.button_to(_('Create a new group'), url(controller='group', action='add'))}
  </div>
%elif c.obj_type == 'subject':
  <div class="create_item">
    ${_('Did not find what you were looking for?')}
    ${h.button_to(_('Create a new subject'), url(controller='subject', action='add'))}
  </div>
%endif

