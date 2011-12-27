// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(document).ready(function() {
  
  $("div.flash").delay(3000).fadeOut('slow');
  
  $('#identity_nickname').focusout(function(eventObject) {
    value = $('#identity_nickname').val();
    $.ajax({
      url: "/identities/"+value,
      statusCode: {
        200: function() {
          $("#nickname_response").html('already taken').css('color', '#E66');
        },
        404: function() {
          $("#nickname_response").html('ok').css('color', '#6D6');
        }
      }
    })
  });
  
  $('#identity_nickname').focusin(function(eventObject) {
    $("#nickname_response").html('');
  });

});
