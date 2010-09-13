<%inherit file="/ubase-width.mako" />

<%def name="title()">
  Statistics
</%def>

<h1>${_('Statistics')}</h1>

<div class="stats">
  <h2>${_('Statistics by Region')}</h2>
  <ul id="subject_list">
    %for region, cnt in c.locations:  
     <li>
       ${region.title} ${cnt}
     </li>
    %endfor
  </ul>
</div>

<div class="stats">
  <h2>${_('Statistics by Geo location')}</h2>
  <ul id="subject_list">
    %for city, cnt in c.geo_locations:  
     <li>
       ${city} ${cnt}
     </li>
    %endfor
  </ul>
</div>
