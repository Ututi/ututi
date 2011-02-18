<%def name="voting_widget(votes)">
  <%
     percentage = votes * 100 / 500
     offset = round(16.75*(percentage/5))

     right = False
     offset_text = offset + 21
     if percentage > 45:
         right = True
         offset_text = 365 - offset
  %>
  <div id="voting-widget">
    <div id="voting-progress" style="background-position: ${-335+offset}px center;">
      <div id="voting-count" style="${right and 'right' or 'left'}: ${offset_text}px;">
        ${ungettext('%(count)d vote', '%(count)d votes', votes) % dict(count=votes)}
      </div>
    </div>
    <script type="text/javascript">
      $(function(){
          $('#vote-submit').click(function(){
              var form = $(this).closest('form');
              var url = $(form).find('#js_url').val();
              $.post(url,
                     $(form).serialize(),
                     function(data){
                         $('#voting-widget').hide();
                         $('#voting-results').show();
                     });
              return false;
          });
      });
    </script>
    <form id="vote-form" method="post" action="${url(controller='profile', action='transfer_vote')}">
      <div>
        <input type="hidden" id="js_url" name="js_url" value="${url(controller='profile', action='js_transfer_vote')}"/>
        ${h.input_submit(_('I want this!'), class_="btnMedium", id="vote-submit")}
      </div>
    </form>
  </div>
</%def>
