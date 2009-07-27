<%def name="location_widget(number)">

<div class="location-tag-widget">
<form:error name="schoolsearch">
  <% rng = range(number) %>
  %for i in rng:
    <% cls = i > 0 and 'hidden' or '' %>
    <div class="location-tag-field ${cls}">
      <input type="text" name="schoolsearch-${i}" id="schoolsearch-${i}" class="line structure-complete"/>
    </div>
  %endfor
</div>
${h.javascript_link('/javascripts/jquery.autocomplete.js')|n}
<script type="text/javascript">
//<![CDATA[
  var paths = []
  var top_path = 0
  $(".structure-complete").each(function(i) {
    paths[i] = '';
    $(this).autocomplete("${url(controller='structure', action='completions')}", {
      dataType:"json",
      highlight: null,
      max: 10,
      selectFirst: true,
      formatItem: function(data,i,value,result){
        return data.title;
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
        parent: function(input) {
          return paths[top_path];
        }
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

        paths[ind] = data.path
        top_path = ind
        if (data.has_children) {
          $(".location-tag-field").eq(ind+1).removeClass("hidden");
        } else {
          $(".form-field.hidden:first").removeClass("hidden");
        }
      }
    });
  });
//]]>
</script>
</%def>
