$(document).ready(function() {
    $(".click2show .click").each(function() {
        $(this).click(function() {
            var el = $(this).closest('.click2show').toggleClass("open");
            el.find(".show").toggle();
            el.find('.click2show .show').toggle();
            el.find(".hide").toggle();
            el.find('.click2show .hide').toggle();
            el.find('.files_more').toggle();
            el.trigger("expand");
            return false;
        });
    });
    $(".click2fade .click").click(function() {
        /* Traversing children explicitly, because
         * .clik2fade blocks may be nested.
         */
        var el = $(this).closest('.click2fade');
        el.children('.hide').hide();
        el.children('.show').fadeIn('slow');
        return false;
    });
});
