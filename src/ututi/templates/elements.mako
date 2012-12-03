<%doc>
Various reusable elements.
</%doc>

<%def name="location_links(location, full_title=False, external=False, sub_department=None)">
  <%doc>
    Prints hierarchy of location tag with links.
    - full_title -- use full titles instead of short ones,
    - external -- use external site urls for links.
  </%doc>
  <ul class="location-links ${'full' if full_title else 'short'}">
  %for index, tag in enumerate(location.hierarchy(True)):
    <li class="${'first' if index == 0 else ''}">
    %if external:
      %if tag.site_url:
        <a href="${tag.site_url}" class="external">
          ${tag.title if full_title else tag.title_short}
        </a>
      %else:
        ${tag.title if full_title else tag.title_short}
      %endif
    %else:
      <a href="${tag.url()}">
        ${tag.title if full_title else tag.title_short}
      </a>
    %endif
    </li>
  %endfor
  %if sub_department is not None:
    <li>
    %if external:
      %if sub_department.site_url:
        <a href="${sub_department.site_url}" class="external">${sub_department.title}</a>
      %else:
        ${sub_department.title}
      %endif
    %else:
      <a href="${sub_department.url()}">${sub_department.title}</a>
    %endif
    </li>
  %endif
  </ul>
</%def>

<%def name="item_box(items, with_titles=False, per_row=None)">
  <%doc>
  Renders a box of item logos and optionally titles.
  Items are given as dicts, see helpers group_members or location_members
  for reference.
  </%doc>
  <%
  if per_row is None:
    per_row = 3 if with_titles else 4
  rows = [items[i:i + per_row] for i in range(0, len(items), per_row)]
  %>
  <div class="item-box ${'with-titles' if with_titles else ''}">
  %for row in rows:
    <div class="item-row clearfix">
      %for item in row:
      <div class="item">
        <a href="${item['url']}">
          <% logo_url = item['logo_url'] if with_titles else item['logo_small_url'] %>
          <img src="${logo_url}"
               class="item-logo"
               alt="${item['title']}"
               title="${item['title']}" />
          %if with_titles:
          <div class="item-title">
            ${item['title']}
          </div>
          %endif
        </a>
      </div>
      %endfor
    </div>
  %endfor
  </div>
</%def>

<%def name="tabs(tabs=None, current=None)">
<%
  if tabs == None:
    tabs = getattr(c, 'tabs', None)
  if current == None:
    current = getattr(c, 'current_tab', None)
%>
%if tabs:
<ul class="tabs clearfix">
    %for tab in tabs:
      <li class="${'current' if tab['name'] == current else ''}">
        <a href="${tab['link']}">${tab['title']}</a>
      </li>
    %endfor
</ul>
%endif
</%def>

<%def name="tooltip(text, style=None, img=None)">
  <% if img is None: img = '/images/details/icon_question.png' %>
  ${h.image(img, alt=text, class_='tooltip', style=style)}
</%def>
