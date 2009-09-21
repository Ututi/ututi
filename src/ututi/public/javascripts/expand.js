$(document).ready(function() {
    $(".breadcrumb_dropdown .active").click(
        function() {
            $(this).parents('.breadcrumb_dropdown').toggleClass('expanded');
        });

    $(".click2show .click").each(function() {
        $(this).click(function() {
            var el = $(this).parents(".click2show:first").toggleClass("open").find(".show:first");
            el.toggle();
            el.siblings(".show").toggle();
            el.siblings(".hide").toggle();
            return false;
        });
    });
});
