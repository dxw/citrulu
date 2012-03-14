#
# Odds & ends for the index page
#

$(document).ready ->
  $("div.welcome a.dismiss").click ->
    $("div.welcome").fadeOut('fast')
    window.createCookie('hide_welcome', 'true', 999)



#
#Setup the test file editor page:
#
$(window).load ->
  if($('body').hasClass('test_files') && $('body').hasClass('edit'))
    setup_editor()
    # create a placeholder to store a hash of the text:
    window.text_hash = ""
    # initialise the key press tracker so that the file will save straight away:
    window.lastKeyPress = (new Date).getTime()
    # save the file for the first time: 
    window.save_file()
    
setup_editor = ->
  window.editor = CodeMirror.fromTextArea($('#editor_content')[0], {
    theme: 'monokai';
    lineNumbers: true;
  });
  $("#editor_form").submit ->
     saving_file()
     editor_text = window.editor.getValue()
     window.text_hash = make_hash(editor_text)
   $(".CodeMirror").keydown (event) ->
     window.lastKeyPress = (new Date).getTime()


saving_file = ->
  $("#editor_status").html "Saving..."
  $("#editor_status").addClass "working"
  $("#editor_form input[type='submit']").attr "disabled", true

window.save_file = ->
  new_text_hash = make_hash(window.editor.getValue())
  if (new_text_hash isnt window.text_hash) and window.editor.getValue() isnt '' and (new Date).getTime() - window.lastKeyPress > 500
    $("#editor_form input[type='submit']").click()
  else
    setTimeout("window.save_file()", 1000);

make_hash = (input_text) ->
  shaObj = new jsSHA input_text, "ASCII"
  shaObj.getHash "B64"
  
