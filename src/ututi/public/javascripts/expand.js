$(document).ready(function() {
    $(".breadcrumb_dropdown .active").click(
        function() {
            $(this).parents('.breadcrumb_dropdown').toggleClass('expanded');
        });

    $(".click2show .click").each(function() {
        $(this).click(function() {
            $(this).parents(".click2show").toggleClass("open").find(".show").toggle();
        });
    });
});
