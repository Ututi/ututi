<%def name="location_widget(number, values=[], titles=[])">
<%
   if titles == []:
       titles = [_('University'), _('Department'), _('Section')]
%>

<div class="location-tag-widget">
  <div class="form-field">
    <form:error name="location"/>
    <% rng = range(number) %>
    %for i in rng:
      <div class="location-tag-field" id="location-tag-field-${i}">
        %if i < len(titles):
            <label for="location-${i}" class="inline-label">${titles[i]}</label>
        %endif
        <div class="input-line">
          <div>
            %if len(values) > i:
              <input type="text" name="location-${i}" id="location-${i}" class="line structure-complete" value="${values[i]}"/>
            %else:
              <input type="text" name="location-${i}" id="location-${i}" class="line structure-complete" value=""/>
            %endif
          </div>
        </div>
      </div>
    %endfor
  </div>
</div>
${h.javascript_link('/javascripts/jquery.autocomplete.js')|n}
<script type="text/javascript">
//<![CDATA[
  /* hide extra inputs */
  var flr = 0;
  $(".location-tag-field").each(function(i) {
    if ($(this).find('input').val() != '') {
      flr = flr + 1;
    }
    if (i > flr) {
      $(this).addClass("hidden");
    }
  });

  $(".structure-complete").each(function(i) {
    $(this).autocomplete([], {\
      cacheLength: 200,
      dataType:"json",
      max: 10,
      minChars: 0,
      matchCase: false,
      matchSubset: true,
      matchContains: true,
      mustMatch: false,
      selectFirst: true,
      formatItem: function(data,i,value,result){
        return data.title;
      },
      before: function(input) {
        var ind = $(".structure-complete").index(input);
        var options = this.extraParams;
        $(".structure-complete").each(function(i) {
          if (i < ind) {
            options['parent-'+i] = $(this).val();
          }
        });
      },
      parse: function(data){
        var alts = new Array();
        var vals = data['values']
        for(var i=0;i < vals.length;i++){
          alts[alts.length] = { data:vals[i], value:vals[i].id, result:vals[i].title };
        }
        return alts;
      },
      extraParams: {
      }
    });

    var parameters = {};
    $(this).addClass('preloadData');
    $(".structure-complete").each(function(ii) {
        if (ii < i) {
           parameters['parent-'+ii] = $(this).val();
        }
    });
    jQuery.getJSON("${url(controller='structure', action='completions')}",
          parameters,
          function(jdata, status) {
             var item = $(jdata.id);
             item.setOptions({
                 data: jdata.values
             });
             item.removeClass("preloadData");
    });


    $(this).result(function(event, data, formatted) {
      if (data) {
        var ind = $(".structure-complete").index(this);

        $(".location-tag-field").each(function(pos) {
          //alert($(this).val());
          if ((pos > ind) && !($(this).hasClass("hidden"))) {
            $(this).addClass("hidden");
          }
        });

        if (data.has_children == true) {
          var next_item = $(".location-tag-field").eq(ind+1);
          $(next_item).removeClass("hidden").addClass("json-target");
          var parameters = {};

          $(".structure-complete").each(function(i) {
              if (i < ind+1) {
                  parameters['parent-'+i] = $(this).val();
              }
          });
          $(next_item).find("input").setOptions({
                data: []
          });

          jQuery.getJSON("${url(controller='structure', action='completions')}",
                          parameters,
                          function(jdata) {
                              var item = $(".json-target").eq(0);
                              item.find("input").setOptions({
                                  data: jdata.values
                              });
                              item.removeClass("json-target");
                              item.find("input").focus().click();
                   });

          $(next_item).find('input').val('');
        } else {
          $(this).parents('form').find(".form-field.hidden:first").removeClass("hidden").find('input:first').focus().click();
          // show the next form element if there was one hidden
        }
      }
    });
   });
/*
   jQuery.getJSON("${url(controller='structure', action='completions')}",
                   function(jdata) {
                     var item = $(".structure-complete").eq(0);
                     item.setOptions({
                       data: jdata.values
                     });
                   });
*/
//]]>
</script>
</%def>
