$(document).ready(function() {
        $(".breadcrumb_dropdown .active").click(
            function() {
                $(this).parents('.breadcrumb_dropdown').toggleClass('expanded');
            });
    });
