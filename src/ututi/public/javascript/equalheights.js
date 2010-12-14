/*-------------------------------------------------------------------- 
 * JQuery Plugin: "EqualHeights"
 * by:	Scott Jehl, Todd Parker, Maggie Costello Wachs (http://www.filamentgroup.com)
 *
 * Copyright (c) 2008 Filament Group
 * Licensed under GPL (http://www.opensource.org/licenses/gpl-license.php)
 *
 * Description: Compares the heights or widths of the top-level children of a provided element 
 		and sets their min-height to the tallest height (or width to widest width). Sets in em units 
 		by default if pxToEm() method is available.
 * Dependencies: jQuery library, pxToEm method	(article: 
		http://www.filamentgroup.com/lab/retaining_scalable_interfaces_with_pixel_to_em_conversion/)							  
 * Usage Example: $(element).equalHeights();
  		Optional: to set min-height in px, pass a true argument: $(element).equalHeights(true);
 * Version: 2.0, 08.01.2008
 *
 * Modified by Linas: throw away the px stuff and no height setting for IE6, and made possible for dynamic use.
--------------------------------------------------------------------*/

$.fn.equalHeights = function() {
	$(this).each(function(){
		var currentTallest = 0;
		$(this).children().css({'min-height': '0px'}); // unset min-height to evaluate heights by content
		$(this).children().each(function(i){
			if ($(this).height() > currentTallest) { currentTallest = $(this).height(); }
		});
		if (!($.browser.msie && $.browser.version == 6.0))
                    $(this).children().css({'min-height': currentTallest}); 
	});
	return this;
};

