#
# Odds & ends for the index page
#

$(document).ready ->
  $("div.welcome a.dismiss").click ->
    $("div.welcome").fadeOut('fast')
    window.createCookie('hide_welcome', 'true', 999)



#
# Setup the test file editor page:
#

####
# When the window loads, set up the editor and kick off the first autosave
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

####
# Returns a hash of the input text. Used to detect whether the test file has been changed
#
make_hash = (input_text) ->
  shaObj = new jsSHA input_text, "ASCII"
  shaObj.getHash "B64"
  
####
# Returns an object containing the full text of the test group currently under the cursor 
# and the line number of the cursor within that group
#
get_current_group = ->
  cur_line = line = window.editor.getCursor().line

  # Find the start of the group
  while !window.editor.getLine(line).match(/^\s*On/)
    line--
  start = line


  # Find the end of the group
  line++
  while line < window.editor.lineCount() && !window.editor.getLine(line).match(/^\s*On/)
    line++

  end = line

  content = window.editor.getRange({line: start, ch: 0}, {line: end, ch: -1})
 
  {group: content, current_line: cur_line - start }
  
###
# Requests an Ajax update of the live view area
#
update_liveview = -> 
  $("#liveedit div.on").addClass("working");
  jQuery.ajax(url: '/test_files/update_liveview', data: get_current_group(), type: 'POST', dataType: 'script')

###
# Checks whether a live view update is necessary and starts one if so
#
window.check_liveview = ->
  # If the text is different, update
  # If the text is the same but they pressed a cursor key, update
  # Don't update if the last keypress was recent
  
  new_text_hash = make_hash(window.editor.getValue())
  
  if new_text_hash != window.text_hash or window.lastKeyWasCursor
    if(new Date).getTime() - window.lastKeyPress > 150 && window.editor.getCursor().line != window.lastCursorPosition
      window.lastCursorPosition = window.editor.getCursor().line
      update_liveview()

  setTimeout("window.check_liveview()", 150);

####
# Embeds the editor and adds event handlers
#
setup_editor = ->
  window.editor = CodeMirror.fromTextArea($('#editor_content')[0], {
    theme: 'monokai',
    lineNumbers: true,
  });

  setTimeout("window.check_liveview()", 150);
  
  $(window.editor.getWrapperElement()).click (event) ->
    update_liveview()

  $(".CodeMirror").keydown (event) ->
    window.lastKeyPress = (new Date).getTime()

    if event.keyCode >= 37 && event.keyCode <= 40
      window.lastKeyWasCursor = true 

  $("#editor_form").submit ->
    saving_file()
    editor_text = window.editor.getValue()
    window.text_hash = make_hash(editor_text)

####
# Updates the UI to indicate that a save is in progress
#
saving_file = ->
  $("#editor_status").html "Saving..."
  $("#editor_status").addClass "working"
  $("#editor_form input[type='submit']").attr "disabled", true

####
# Initiates an an autosave if the test file text has been modified and the user is not currently typing
#
window.save_file = ->
  new_text_hash = make_hash(window.editor.getValue())
  

  if (new_text_hash isnt window.text_hash) and window.editor.getValue() isnt '' and (new Date).getTime() - window.lastKeyPress > 500
    $("#editor_form input[type='submit']").click()
    update_liveview();
  else
    setTimeout("window.save_file()", 1000);

