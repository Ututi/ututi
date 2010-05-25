jQuery.fn.labelOver = function(overClass) {
    return this.each(function(){
 	var label = jQuery(this);
    var input = label.parent().find('input');

 	this.hide = function() {
	  label.hide();
	}

	this.show = function() {
	  if (input.val() == '') label.show()
	}

	// handlers
	input.focus(this.hide);
	input.blur(this.show);
 	label.addClass(overClass).click(function(){ input.focus() });
        if (input.val() != '') this.hide();

 })
 }

$(document).ready(function() {
  $('form.autosubmit-form').each(function() {
    $(this).find("span.btn").hide();
    $(this).find("input, select").change(function() {
      $(this).addClass("changed");
      $(this).parents("form").submit();
    })
  })
})
