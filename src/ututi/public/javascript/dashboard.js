/* Wall dashboard javascript.
 *
 * Current implementation assumes that there's only
 * one dashboard on the page. This is not very hard
 * to fix: see global variable usage.
 */

$(document).ready(function() {

    /* Hide action blocks.
     *
     * Currently they are initially hidden in CSS.
     * It would be nice to fall back if JS not available though.

    $('#dashboard_action_blocks .dashboard_action_block').hide()

     */

    /* Attach dashboard actions.
     */
    $('#dashboard_action_links a.action').filter(':not(.inactive)').click(function(){
        var id = $(this).attr('id');
        if ($(this).hasClass('open')) {
            $(this).removeClass('open');
            $('#' + id + '_block').slideUp(300);
        } else {
            $('#dashboard_action_links a.open').each(function(){
                $(this).removeClass('open');
                var cls_id = $(this).attr('id');
                $('#' + cls_id + '_block').slideUp(300);
            });
            $(this).addClass('open');
            $('#' + id + '_block').slideDown(300);
        }
        return false;
    });

    /* Helper reload function.
     */
    wall_reload_url = $("#wall-reload-url").val();
    function reload_wall() {
        $('#wall').load(wall_reload_url);
    };

});
