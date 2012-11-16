<%namespace file="/elements.mako" import="location_links" />

<%def name="standard_location_widget(read_only=False)">
%if hasattr(c, 'preset_location'):
<div id="location-preview" class="formField" style="display: none">
  <label for="tags">
    <span class="labelText">${_('University and department:')}</span>
  </label>
  ${location_links(c.preset_location)}
  %if not read_only:
  <a id="location-edit-link" href="#">${_("Change")}</a>
  %endif
</div>
<script type="text/javascript">
  $(document).ready(function() {
    $('#location-preview').show();
    $('#location-edit').hide();
    $('#location-edit-link').click(function() {
      $('#location-preview').hide();
      $('#location-edit').show();
      return false;
    });
  })
</script>
%endif
<div id="location-edit">
  ${location_widget(2, titles=(_("University:"), _("Department:")))}
</div>
</%def>

<%def name="hidden_fields(location)">
%for n, tag in enumerate(location.hierarchy()):
  <input type="hidden" name="location-${n}" value="${tag}" />
%endfor
</%def>

<%def name="location_widget(number, values=[], titles=[], add_titles=[], label_class='')">
<%
   if not hasattr(self, 'newlocationwidget_id'):
       self.newlocationwidget_id = 0
   else:
       self.newlocationwidget_id = self.newlocationwidget_id + 1

   if titles == []:
       titles = [_('University'), _('Department'), _('Section')]
   if add_titles == []:
       add_titles = [_('Add university'), _('Add department'), _('Add section')]
%>

<div class="location-tag-widget"
     id="newlocationwidget-${self.newlocationwidget_id}">
  %for i in range(number):
    <div class="location-tag-field form-field formField" id="location-tag-field-${i}">
      <label class="${label_class}">
        %if i < len(titles):
          <span class="labelText">${titles[i]}</span>
        %endif
            <span class="textField">
              %if len(values) > i:
                <input type="text" name="location-${i}" id="location-${self.newlocationwidget_id}-${i}" class="line structure-complete location-${i}" value="${values[i]}"/>
              %else:
                <input type="text" name="location-${i}" id="location-${self.newlocationwidget_id}-${i}" class="line structure-complete location-${i}" value=""/>
              %endif
              <span class="edge"></span>
            </span>
      </label>
    </div>
  %endfor
  <form:error name="location"/>
</div>
</%def>

<%def name="head_tags()">
${h.javascript_link('/javascript/jquery.autocomplete.js')|n}
<script type="text/javascript">
//<![CDATA[
$(document).ready(function() {
  $('.add_subform_switch').click(function() {
    $(this).toggleClass('active');
    $(this).siblings('.location-add-subform').toggle();
    return false;
  });
  $('.location-add-subform button').click(function() {
    errors = false;
    el = $(".location-add-subform button");
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
               $('input.structure-complete', $(target).parent()).val(data.success).change();
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


 $('.location-tag-widget').each(function() {
  $(".structure-complete", this).each(function(i) {
    widget = $(this).parents('.location-tag-widget').eq(0);
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
    parameters['widget_id'] = $(widget).eq(0).attr('id');
    $(this).addClass('preloadData');
    $(".structure-complete", widget).each(function(ii) {
        if (ii < i) {
           parameters['parent-'+ii] = $(this).val();
        }
    });
    if ((i == 0) || ((i >= 1) && (parameters['parent-'+(i-1)] != ''))) {
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
        widget = $(this).parents('.location-tag-widget').eq(0);
        var ind = $(".structure-complete", widget).index(this);
        var next_item = $(".location-tag-field", widget).eq(ind+1);
        if (data.has_children == true) {
          $(next_item).addClass("json-target");
          var parameters = {};
          parameters['widget_id'] = widget.attr('id')

          $(".structure-complete", widget).each(function(i) {
              if (i < ind+1) {
                  parameters['parent-'+i] = $(this).val();
              }
          });
          $(next_item).find("input.structure-complete").setOptions({
                data: []
          });

          jQuery.getJSON("${url(controller='structure', action='completions')}",
                          parameters,
                          function(jdata) {
                              var item = $(".json-target").eq(0);
                              item.find("input.structure-complete").setOptions({
                                  data: jdata.values
                              });
                              item.removeClass("json-target");
                              item.find("input.structure-complete").focus().click();
                   });

          $(next_item).find('input.structure-complete').val('');
        } else {
          $(next_item).find('input.structure-complete').val('');
        }
      }
    });
   });
  });
});
//]]>
</script>
</%def>
