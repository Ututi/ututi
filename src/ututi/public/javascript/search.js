/*
 * bind search type selects to the input
 */

$(document).ready(function() {
  $('#search-type-any').click(function() {
    $(this).parents('.search-type').find('select').val('*').change();
    $(this).addClass('active');
    $(this).siblings('.search-type-item').removeClass('active');
  });

  $('#search-type-subject').click(function() {
    $(this).parents('.search-type').find('select').val('subject').change();
    $(this).addClass('active');
    $(this).siblings('.search-type-item').removeClass('active');
  });

  $('#search-type-group').click(function() {
    $(this).parents('.search-type').find('select').val('group').change();
    $(this).addClass('active');
    $(this).siblings('.search-type-item').removeClass('active');
  });
});
