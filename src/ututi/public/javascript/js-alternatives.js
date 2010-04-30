/* Hide elements that are meant for users without javascript
 * and show elements that are meant for js.
 *
 * This applies to containers .js-alternatives with two
 * sub-containers: .js and .non-js.
 */

$(document).ready(function() {
  $(".js-alternatives .js").show();
  $(".js-alternatives .non-js").hide();
});
