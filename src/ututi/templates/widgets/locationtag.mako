<%def name="location_widget(number, values=[])">

<div class="location-tag-widget">
<form:error name="location">
  <% rng = range(number) %>
  %for i in rng:
    <div class="location-tag-field">
      %if len(values) > i:
        <input type="text" name="location-${i}" id="location-${i}" class="line structure-complete" value="${values[i]}"/>
      %else:
        <input type="text" name="location-${i}" id="location-${i}" class="line structure-complete" value=""/>
      %endif
    </div>
  %endfor
</div>
${h.javascript_link('/javascripts/jquery.autocomplete.js')|n}
<script type="text/javascript">
//<![CDATA[
  /* hide extra inputs */
  var flr = 0;
  $(".location-tag-field").each(function(i) {
    if ($(this).children('input').val() != '') {
      flr = flr + 1;
    }
    if (i > flr) {
      $(this).addClass("hidden");
    }
  });

  $(".structure-complete").each(function(i) {
    $(this).autocomplete("${url(controller='structure', action='completions')}", {\
      cacheLength: 0,
      dataType:"json",
      highlight: false,
      max: 10,
      matchCase: false,
      matchSubset: false,
      matchContains: false,
      mustMatch: true,
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
          $(next_item).removeClass("hidden");
          $(next_item).children('input').val('').focus();
        } else {
          $(".form-field.hidden:first").removeClass("hidden");
        }
      }
    });
  });
//]]>
</script>
</%def>
