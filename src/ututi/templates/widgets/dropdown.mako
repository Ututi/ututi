<%def name="js()">
<script type="text/javascript">
  $(function(){
    $('.dropdown-widget').each(function(index, dropdown){
      var dd = $('.dropdown .current', dropdown);
      $(dd).text($('#'+$('.dropdown', dropdown).attr('id')+'-select :selected').text());
      $('.dropdown', dropdown).toggle(function() {
          $(this).addClass('expanded').find('div:last-child ul').show();
      }, function(){
          $(this).removeClass('expanded').find('div:last-child ul').hide();
      }).click(function(){ // remove selection
          if(document.selection && document.selection.empty) {
              document.selection.empty() ;
          } else if(window.getSelection) {
              var s = window.getSelection();
              if(s && s.removeAllRanges)
                  s.removeAllRanges();
          }
      }).find('li a').click(function(ev){
          ev.preventDefault();
          $(this).closest('.dropdown').removeClass('expanded');
          id = $(this).attr('id')
          $(this).closest('.dropdown-widget').find('select').val(id);
          $(this).closest('.dropdown-widget').find('.current').text($(this).text());
      });
    });
  });
</script>
</%def>

<%def name="head_tags()">
  ${h.stylesheet_link(h.path_with_hash('/widgets.css'))}
  ${h.javascript_link('/javascript/js-alternatives.js')}
  ${self.js()}
</%def>

<%def name="dropdown(id, label, items)">
<div class="dropdown-widget js-alternatives">
  <label>${label}</label>
  <div class="dropdown js" id="${id}">
    <div class="current">${items[0][1]}</div>
    <div class="items">
      <ul>
        %for key, item in items:
        <li class="action">
          <a id="${key}"
             href="#"
             class='item'>
            ${item}
          </a>
        </li>
        %endfor
      </ul>
    </div>
  </div>
  <div id="${id}-element" class="non-js">
    ${h.select(id,
               items[0][0],
               items,
               id='%s-select' % id)}
  </div>
</div>
</%def>
