<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

%if c.cities:
  <table id="cities_list" style="width: 100%;">
    <tr>
      <th>${_('City')}</th>
    </tr>

    %for city in c.cities:
    <tr>
      <td>${city.name}</td>
      <td>${h.link_to(_('Edit'), url(controller="admin", action="edit_city", id=city.id)) }</td>
    </tr>
    %endfor
  </table>
  <div id="pager">${c.cities.pager(format='~3~') }</div>
%endif


<h1>${_('Cities')}</h1>
<h2>${_('Add')}</h2>
<form method="post" action="${url(controller='admin', action='create_city')}"
      name="city_form" id="city_form" class="fullForm">
  ${h.input_line('name', _('Name'))}
  <br />
  ${h.input_submit(_('Save'))}
</form>

