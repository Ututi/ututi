<%inherit file="/portlets/base.mako"/>
<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="search_portlet(text='', obj_type='*', tags='', parts=['text', 'tags'], target=None)">
  <%
     if target is None:
         target = url(controller='search', action='index')
  %>
  <%self:portlet id="search_portlet">
    <%def name="header()">
      ${_('Search')}
    </%def>
    <div class="search-controls">
      <form method="post" action="${target}" id="search_form_portlet">
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
            <div id="portlet-search-type-${id}" class="search-type-item ${cls}">${title}</div>
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
              <input type="text" name="text" id="search-text" value="${text}" size="60"/>
            </div>
          </div>
          %endif
          <div class="search-submit">
            <span class="btn">
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
  </%self:portlet>
</%def>
