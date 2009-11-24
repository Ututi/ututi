<%def name="location_add_subform(index)">
<div class="location-add-subform hidden" id="location-add-subform-${index}">
  <div class="error"></div>
  ${h.input_line('newlocation-%d.title' % index, _('Title'), explanation=_('Full title'), class_='title')}
  ${h.input_line('newlocation-%d.title_short' % index, _('Short title'), explanation=_('e.g. LKKA'), class_='title-short')}
  ${h.input_submit('Save')}
</div>
</%def>

<%def name="location_widget(number, values=[], titles=[], add_titles=[], add_new=False, live_search=False)">
<%
   if titles == []:
       titles = [_('University'), _('Department'), _('Section')]
   if add_titles == []:
       add_titles = [_('Add university'), _('Add deparment'), _('Add section')]
%>

<div class="location-tag-widget">
  <div class="form-field">
    <form:error name="location"/>
    <% rng = range(number) %>
    %for i in rng:
      <div class="location-tag-field form-field" id="location-tag-field-${i}">
        %if i < len(titles):
            <label for="location-${i}">${titles[i]}</label>
        %endif
        <div class="input-line">
          <div>
            <%
               cls = ''
               if live_search:
                   cls = 'group_live_search'
            %>
            %if len(values) > i:
              <input type="text" name="location-${i}" id="location-${i}" class="${cls} line structure-complete" value="${values[i]}"/>
            %else:
              <input type="text" name="location-${i}" id="location-${i}" class="${cls} line structure-complete" value=""/>
            %endif
          </div>
        </div>
        %if add_new:
          <span style="margin-left: 5px;">${_('or')}</span> <a style="margin: 0 0 0 5px;" class="btn add_subform_switch" href="#"><span>${add_titles[i]}</span></a>
        %endif

        <div class="explanation">
          %if add_new:
            ${_('enter the name or add a new one')}
          %else:
            ${_('enter the name')}
          %endif
        </div>
        %if add_new:
          ${location_add_subform(i)}
        %endif
      </div>
    %endfor
  </div>
</div>
${h.javascript_link('/javascripts/jquery.autocomplete.js')|n}
<script type="text/javascript">
//<![CDATA[
  $('.add_subform_switch').click(function() {
    $(this).toggleClass('active');
    $(this).siblings('.location-add-subform').toggle();
    return false;
  });
  $('.location-add-subform span.btn input').click(function() {
    errors = false;
    el = $(".location-add-subform span.btn input");
    var ind = el.index(this);
    input = $("input.structure-complete");
    if (ind > 0) {
      if ($.trim(input.eq(ind - 1).val()) == '') {
        input.eq(ind - 1).addClass('error');
        errors = true;
      }
    }

    el = $(this).parents('.location-add-subform').find('.title')[0];
    if (jQuery.trim($(el).val()) == '') {
      $(el).addClass('error');
      errors = true;
    }
    el = $(this).parents('.location-add-subform').find('.title-short')[0];
    if (jQuery.trim($(el).val()) == '') {
      $(el).addClass('error');
      errors = true;
    }

    if (!errors) {
      $(this).parents('.location-add-subform').addClass('js-target');
      url = '${url(controller='structure', action='js_add_tag')}';
      $.post(url,
           $(this).parents('form').serialize(),
           function(data) {
             target = $('.js-target');
             $(target).removeClass('js-target');
             if (data.success != '') {
               $('div.input-line div input.structure-complete', $(target).parent()).val(data.success).change();
               $('input.title', target).val('')
               $('input.title-short', target).val('')
               $(target).toggle();
               $(target).siblings('.add_subform_switch').toggleClass('active');
             } else {
               $('div.error', target).text(data.error);
             }
           },
           'json'
      );
    }
    return false;
 });



  $(".structure-complete").each(function(i) {
    $(this).autocomplete([], {\
      cacheLength: 200,
      dataType:"json",
      max: 100,
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
    if ((i == 0) || ((i > 1) && (parameters['parent-'+(i-1)] != ''))) {
    jQuery.getJSON("${url(controller='structure', action='completions')}",
          parameters,
          function(jdata, status) {
             var item = $(jdata.id);
             item.setOptions({
                 data: jdata.values
             });
             item.removeClass("preloadData");
    });
    };

    $(this).result(function(event, data, formatted) {
      $(this).change();
      if (data) {
        var ind = $(".structure-complete").index(this);
        if (data.has_children == true) {
          var next_item = $(".location-tag-field").eq(ind+1);
          $(next_item).addClass("json-target");
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
        }
      }
    });
   });
//]]>
</script>
</%def>
