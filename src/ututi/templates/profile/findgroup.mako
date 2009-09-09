 <%inherit file="/profile/base.mako" />
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
       target = url(controller='profile', action='findgroup')
%>
<div class="search-controls">
  <form method="post" action="${target}" id="search_form">
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
          <label for="tags">${_('Filter by school:')}</label>
          ${tags_widget(tags, all_tags=True)}
      </div>
    %endif
    <div class="form-field">
      <label for="year">${_("Year")}</label>
      <select name="year" id="year">
        %for year in c.years:
        %if year == c.year:
        <option value="${year}" selected="selected">${year}</option>
        %else:
        <option value="${year}">${year}</option>
        %endif
        %endfor
      </select>
    </div>

  </form>
</div>
</%def>

<%def name="search_results(results=None)">
<h1>Results:</h1>
<div id="search-results">
  %for item in results:
  <div class="search-item group-item">
    <a href="${item.object.url()}" title="${item.object.title}" class="item-title larger">${item.object.title}</a>
    <span class="small">(${item.object.year.year})</span>
    <div class="description small">
      ${item.object.description}
    </div>
    <div class="item-tags">
      %for tag in item.object.tags:
      <span class="tag">${tag.title}</span>
      %endfor
      %for tag in item.object.location.hierarchy():
      <span class="tag">${tag}</span>
      %endfor

    </div>
  </div>
  %endfor
</div>

%if len(results):
<div id="pager">${results.pager(format='~3~') }</div>
%endif
</%def>

<h1>${_('Search')}</h1>
${search_form(c.text, c.obj_type, c.tags, parts=['text', 'tags'])}

%if c.results:
<br />
${search_results(c.results)}
%endif
<br />
${_('Did not find the group you were looking for?')}
<a class="btn" href="${url(controller='group', action='add')}" title="${_('New group')}"><span>${_('Create your group!')}</span></a>
