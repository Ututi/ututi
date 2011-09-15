jQuery.fn.labelOver = function(overClass) {
    return this.each(function(){
        var label = jQuery(this);
        var input = label.parent().find('input');

        this.hide = function() {
            label.hide();
        }

        this.show = function() {
            if (input.val() == '') label.show()
        }

        // handlers
        input.focus(this.hide);
        input.blur(this.show);
        label.addClass(overClass).click(function(){
            input.focus()
        });
        if (input.val() != '') this.hide();

    })
}

$(document).ready(function() {
    $('form.autosubmit-form').each(function() {
        $(this).find("span.btn").hide();
        $(this).find("input, select").change(function() {
            $(this).addClass("changed");
            $(this).parents("form").submit();
        })
    })
    $('button[name="delete_me_btn"]').click(function(){
        generateModalMessageBlock({
            title:'Warning!',
            text:'Delete account?',
            yesCallBack:function(){$('#delete-my-account-form').submit();},
            noCallBack:function(){}
        });
        return false;
    });
})

/**
 * Create modal Yes/No alert box.
 * {text:String,yesCallBack:function(){},noCallBack:function(){}}
 */
function generateModalMessageBlock(options) {
    
    if ( typeof options == "undefined") { options = Array() }
    if ( typeof options.yesCallBack != "function" ) { options.yesCallBack = function(){}; }
    if ( typeof options.noCallBack != "function" ) { options.noCallBack = function(){}; }
    
    var msg = $('<div style="margin-bottom:10px;"><strong>'+options.text+'</strong></div>');
    var yesBtn = $('<input type="button" id="yesBtn" value="Yes" style="margin-left:10px;" />');
    var noBtn = $('<input type="button" id="noBtn" value="No" />');
    var msgBox = $('<div id="question" style="display:none; cursor: default; text-align:center;">');
    
    msgBox.append(msg);
    msgBox.append(noBtn);
    msgBox.append(yesBtn);
    
    yesBtn.click(function(){
        options.yesCallBack();
        $.unblockUI(); 
        return true;
    });
    noBtn.click(function(){
        options.noCallBack();
        $.unblockUI(); 
        return false;
    });
    
    $.blockUI({
        theme:     true, 
        title:     options.title,
        message: msgBox, 
        css: {
            width: '275px'
        }
    }); 
}

