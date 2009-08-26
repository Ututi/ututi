/*
 * bind search type selects to the input
 */

$(document).ready(function() {
  $('#search-type-any').click(function() {
    $(this).parents('.search-type').find('select').val('*');
    $(this).addClass('active');
    $(this).siblings('.search-type-item').removeClass('active');
  });

  $('#search-type-subject').click(function() {
    $(this).parents('.search-type').find('select').val('subject');
    $(this).addClass('active');
    $(this).siblings('.search-type-item').removeClass('active');
  });

  $('#search-type-group').click(function() {
    $(this).parents('.search-type').find('select').val('group');
    $(this).addClass('active');
    $(this).siblings('.search-type-item').removeClass('active');
  });
});
