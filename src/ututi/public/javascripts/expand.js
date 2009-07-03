$(document).ready(function() {
        $(".breadcrumb_dropdown .active span").click(
            function() {
                $(this).parents('.breadcrumb_dropdown').toggleClass('expanded');
            });
    });
