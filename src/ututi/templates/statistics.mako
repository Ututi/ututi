<%inherit file="/ubase-width.mako" />

<%def name="title()">
  Statistics
</%def>

<h1>${_('Statistics')}</h1>

<div class="stats">

  <ul id="subject_list">
    %for region, cnt in c.locations:  
     <li>
       ${region.title} ${cnt}
     </li>
    %endfor
  </ul>
</div>
