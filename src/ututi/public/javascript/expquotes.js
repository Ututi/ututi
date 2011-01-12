$(document).ready(function() {
    $('a.expand-quote').click(function(event) {
        event.stopPropagation();
        $(this).next('div').toggle();
        $(this).hide();
        return false;
    });
})
