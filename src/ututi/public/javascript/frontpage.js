$(document).ready(function() {
    $(".add_university_button").colorbox({inline:true, height: '450px'});
    var errors = 0;

    // POP-UP starts
    // Create user form validation
    $('#create-account-form').submit(function() {
        if ($('#create-account-form input[name="name"]').val().length == 0) {
            $('#create-account-form input[name="name"]').css('border', '1px solid red');
            errors += 1;
        } else {
            $('#create-account-form input[name="name"]').css('border', '1px solid black');
        }

        if ($('#create-account-form input[name="email"]').val().length == 0) {
            $('#create-account-form input[name="email"]').css('border', '1px solid red');
            errors += 1;
        } else {
            $('#create-account-form input[name="email"]').css('border', '1px solid black');
        }

        if ($('#pp_accept-terms-checkbox').is(':checked')) {
            $('#pp_accept-terms span').remove();
        } else {
            errors += 1;
            $('#pp_accept-terms span').remove();
            $('#pp_accept-terms').prepend('<span class="error-message">' + agreement + '<br /></span>');
        }

        if (errors !== 0) {
            return false;
        }

        errors = 0;
    });
    // POP-UP ends

    // if user clicks "I'm student" or "I'm a teacher"
    $('.login-box-content button').click(function() {
        var type = $(this).attr('class');

        $('#person').val(type);

        $('.login-box-content-buttons').hide();
        $('.login-box-content-registerform').show();
    });

    // if user clicks on slide's button "Register as a teacher"
    $('.register-as-a-teacher').click(function() {
        $('.login-box-content-buttons').hide();
        $('.login-box-content-registerform').show();

        $('#person').val('teacher');
    });

    // let's check validation of registration form:
    // if user is clicked on checkbox, enable submitting
    $('#accept-terms-checkbox').click(function() {
        if (this.checked) {
            $('#accept-terms span').remove();
        }
    });

    $('#pp_accept-terms-checkbox').click(function() {
        if (this.checked) {
            $('#pp_accept-terms span').remove();
        }
    });

    $('#sign-up-form').submit(function() {
        if ($('#university-you-belong-to option:selected').val() == -1) {
            $('#university-you-belong-to').css('border', '1px solid red');
            $('#location_id_errors').empty().append(required);

            return false;
        }

        if ($('#accept-terms-checkbox').is(':checked')) {
            // everything is ok, continue
        } else {
            $('#accept-terms span').remove();
            $('#accept-terms').prepend('<span class="error-message">' + agreement + '<br /></span>');
            return false;
        }
    });

    // checks if exists any error
    if ($('#sign-up-form .error-container').length > 0) {
        $('.login-box-content-buttons').hide();
        $('.login-box-content-registerform').show();
    }

    $('#university-you-belong-to').change(function() {
        if ($('#university-you-belong-to option:selected').val() == '') {
            $('#university-you-belong-to').css('border', '1px solid red');
            $('#location_id_errors').empty().append(required);
        } else {
            $('#university-you-belong-to').css('border', 'none');
            $('#location_id_errors').empty();
        }
    });

    $('#new_university_form').submit(function() {
        $.ajax({
            type: 'POST',
            url: '/structure/create_university',
            data: $(this).serialize(),
            success: function(data) {
                if (data) {
                    var errors = jQuery.parseJSON(data);

                    $('.errors-box').empty();

                    $.each(errors, function(field, value) {
                        $('#' + field + '-errors-box').append('<span class="error-message">' + value + '</span>');
                    });
                } else {
                    $('#add_university_form').hide();
                    $('#add_university_create_account').show();
                    $('#university_name').text($('#title').val());
                    $('#pp_location_id').val($('#title_short').val());
                    $('#pp_person').val('student');
                }
            }
        });

        return false;
    });

    // gets faculties of selected university and generates list of them
    $('#university-you-belong-to').change(function() {
        var location = $('#university-you-belong-to option:selected').attr('id');
        var location_id = location.split('_')[1]

        // removes old list of departments
        $('#departments').remove();

        if (location_id !== undefined) {
            $.ajax({
                type: 'POST',
                url: '/home/js_get_departments',
                data: 'location_id=' + location_id,
                success: function(data) {
                    if (data.length !== 0) {
                        $('#university-you-belong-to').after('<select id="departments" name="location_id"></select>');

                        for (var i = 0; i < data.length; i++) {
                            $('#departments').append('<option value="' + data[i][1] + '">' + data[i][0] + '</option>');
                        }
                    }
                }
            });
        }
    });
});
