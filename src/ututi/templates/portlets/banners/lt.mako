%if c.security_context and c.security_context.content_type in ['group', 'subject']:
<div class="bunner">
  <a href="http://dalintis.lt/konspektai" title="dalintis.lt">
    <img src="${url('/images/bunners/dalintis_konspektai.png')}" alt="dalintis.lt" />
  </a>
</div>
%else:
<div class="bunner">
  <a href="http://dalintis.lt/" title="dalintis.lt">
    <img src="${url('/images/bunners/dalintis_generic.png')}" alt="dalintis.lt" />
  </a>
</div>
<div class="bunner">
  <a href="http://aukok.lt" title="aukok.lt">
    <img src="${url('/images/bunners/aukoklogo.png')}" alt="aukok.lt" />
  </a>
</div>
<div class="bunner">
  <a href="http://www.15min.lt/naujienos/ziniosgyvai/studentu-blogas" title="15 min">
    <img src="${url('/images/bunners/15minlogo.jpeg')}" alt="15 min" />
  </a>
</div>
%endif
