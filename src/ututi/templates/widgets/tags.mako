<%def name="tags_widget(value='', name='tags', all_tags=False)">
${h.javascript_link('/javascripts/jquery.ui.autobox.js')|n}
${h.javascript_link('/javascripts/jquery.ui.autobox.ext.js')|n}

<div class="tag-widget">
  <form:error name="tags" />
  <input type="text" class="tags line" value="${value}" name="${name}" id="${name}"/>
</div>

<script type="text/javascript">
//<![CDATA[
$(document).ready(function() {
  $('input.tags').each(function() {
    if ($(this).val() != '') {
      values = $(this).val().split(', ');
    } else {
      values = [];
    }

    $(this).val('');

    $(this).autobox({
        %if all_tags:
          ajax: "${url(controller='structure', action='autocomplete_all_tags')}",
        %else:
          ajax: "${url(controller='structure', action='autocomplete_tags')}",
        %endif
        match: function(typed) { return true; },
        insertText: function(obj) { return obj },
        prevals : values
    });

  });
});
//]]>
</script>

</%def>
