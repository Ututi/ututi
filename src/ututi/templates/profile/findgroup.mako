<%inherit file="/profile/base.mako" />
<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
</%def>



<%def name="title()">
${_('Search')}
</%def>

<%def name="search_form(text='', obj_type='*', tags='', parts=['obj_type', 'text', 'tags'])">
<div id="search-controls">
  <form method="post" action="${url(controller='profile', action='findgroup')}" id="search_form">
    <div class="form-field">
      %if 'obj_type' in parts:
      <select name="obj_type">
        %for value, title in [(u'*', _('Everywhere')), (u'group', _('Groups')), (u'subject', _('Subjects')), (u'page', _('Pages'))]:
        %if value == obj_type:
        <option value="${value}" selected="selected">${title}</option>
        %else:
        <option value="${value}">${title}</option>
        %endif
        %endfor
      </select>
      %endif
      %if 'text' in parts:
      <input type="text" name="text" id="text" value="${text}"/>
      %endif
    </div>
    %if 'tags' in parts:
    <div id="search-tags" class="form-field">
      <label for="tags">${_('Filter by tags')}</label>
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
    <div class="form-field">
      <span class="btn">
        <input type="submit" value="${_('Search')}"/>
      </span>
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
${search_form(c.text, c.obj_type, c.tags)}

%if c.results:
${search_results(c.results)}
%endif
<br/>
${_('Did not find the group you were looking for?')}
<a href="${url(controller='group', action='add')}" title="${_('New group')}">${_('Create your group!')}</a>
