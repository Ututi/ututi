<%def name="voting_bar(votes, large=True, total=500)">
  <%
     width = large and 335 or 168
     step = large and 16.75 or 8.375
     percentage = votes * 100 / total
     offset = round(step*(percentage/5))

     right = False
     offset_text = offset + 21
     if percentage > 45:
         right = True
         offset_text = width + 30 - offset
     cls = large and 'voting-progress' or 'voting-progress voting-progress-small'
  %>
  <div class="${cls}" style="background-position: ${-width + offset}px bottom;">
    %if large:
    <div class="voting-count" style="${right and 'right' or 'left'}: ${offset_text}px;">
      ${ungettext('%(count)d vote', '%(count)d votes', votes) % dict(count=votes)}
    </div>
    %endif
  </div>
  %if not large:
    <div class="voting-count-small">
      ${ungettext('%(count)d vote', '%(count)d votes', votes) % dict(count=votes)}
    </div>
  %endif

</%def>

<%def name="voting_widget(votes)">
  <div id="voting-widget">
    ${voting_bar(votes)}
    <script type="text/javascript">
      $(function(){
          $('#vote-submit').click(function(){
              var form = $(this).closest('form');
              var url = $(form).find('#js_url').val();
              $.post(url,
                     $(form).serialize(),
                     function(data){
                         $('#vote-form').hide();
                         $('#voting-results').show();
                     });
              return false;
          });
      });
    </script>
    <form id="vote-form" method="post" action="${url(controller='profile', action='transfer_vote')}">
      <div>
        <input type="hidden" id="js_url" name="js_url" value="${url(controller='profile', action='js_transfer_vote')}"/>
        ${h.input_submit(_('Vote!'), class_="btnMedium", id="vote-submit")}
      </div>
    </form>
  </div>
</%def>
