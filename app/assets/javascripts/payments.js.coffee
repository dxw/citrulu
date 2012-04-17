$(window).load ->
  if($('body').hasClass('payments') && ( $('body').hasClass('new') || $('body').hasClass('create') ))
    
    # When the form gets submitted, replace the submit button with a styled div:
    $('#credit_card_form').submit -> 
      classes = $('input[type=submit]').attr('class') 
      $('#credit_card_form input[type=submit]').replaceWith("<div id='submit' class='disabled " + classes + "'>Submitting...</div>")
      $('#submit').append("<span class='working'/>")