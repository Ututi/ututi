$(document).ready(function() {
    $(".click2show > .click").each(function() {
        $(this).click(function() {
            var el = $(this).parents(".click2show:first").toggleClass("open").find(".show:first");
            el.toggle();
            el.siblings(".show").toggle();
            el.siblings(".hide").toggle();
            el.trigger("expand");
            return false;
        });
    });
});
