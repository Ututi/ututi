jQuery.fn.labelOver = function(overClass) {
    return this.each(function(){
 	var label = jQuery(this);
 	var f = label.attr('for');
 	if (f) {
 		var input = jQuery('#' + f);

 		this.hide = function() {
 		  label.hide()
 		}

 		this.show = function() {
 		  if (input.val() == '') label.show()
 		}

 		// handlers
 		input.focus(this.hide);
 		input.blur(this.show);
 	  label.addClass(overClass).click(function(){ input.focus() });

 		if (input.val() != '') this.hide();
 	}
 })
 }

 jq(".overlay_label").labelOver('');
