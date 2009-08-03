<%def name="tags_widget(value='')">
${h.javascript_link('/javascripts/jquery.ui.autobox.js')|n}
${h.javascript_link('/javascripts/jquery.ui.autobox.ext.js')|n}

<div class="tag-widget">
  <input type="text" class="tags line" value="${value}" name="tags"/>
</div>
${c.tags}

<script type="text/javascript">
//<![CDATA[
$(document).ready(function() {
  $('input.tags').each(function() {
    values = $(this).val().split(', ');
    $(this).val('');


    $(this).autobox({
        ajax: "${url(controller='structure', action='autocomplete_tags')}",
        match: function(typed) { return this.match(new RegExp(typed)); },
        insertText: function(obj) { return obj },
        prevals : values
    });

  });
});
//]]>
</script>

</%def>
