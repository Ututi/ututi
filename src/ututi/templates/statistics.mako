<%inherit file="/base.mako" />

<div id="statsContent">

<%def name="title()">
  Statistics
</%def>

<h1>${_('Statistics')}</h1>

<div class="stats">
  <h2>${_('Statistics by Region')}</h2>
  <div class="comment">
      ${_('Here you see information how many people are added information where they are study.')}
  </div>

  <ul id="subject_list">
    %for region, cnt in c.locations:
     <li>
       <a href="/browse?region_id=${region.id}">${region.title}</a> ${cnt}
     </li>
    %endfor
  </ul>
</div>

<div class="stats">
  <h2>${_('Statistics by Geo location')}</h2>
  <div class="comment">
      ${_('Here you see how many people in some cities was logedin more than 2 times.')}
  </div>
  <ul id="subject_list">
    %for city, cnt in c.geo_locations:
     <li>
       ${city} ${cnt}
     </li>
    %endfor
  </ul>
</div>

<div class="stats">
  <h2>${_('Most active user')}</h2>
  <div class="comment">
      ${_('Here you see most altruistic users.')}
  </div>
  <ul id="subject_list">
    %for user, cnt in c.active_users:
     <li>
       <a href="/user/${user.id}">${user.fullname}</a> (${user.location_city}): ${cnt}
     </li>
    %endfor
  </ul>
</div>

</div>
