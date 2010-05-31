$(document).ready(function() {
    $(".click2show .click").each(function() {
        $(this).click(function() {
            var el = $(this).closest('.click2show').toggleClass("open");
            el.find(".show").toggle();
            el.find('.click2show .show').toggle();
            el.find(".hide").toggle();
            el.find('.click2show .hide').toggle();
            el.trigger("expand");
            return false;
        });
    });
});
