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
$(document).ready ->
  if($('body').hasClass('test_files') && $('body').hasClass('edit'))
    setup_editor()
    # create a placeholder to store a hash of the text:
    window.text_hash = ""
    # save the file for the first time: 
    window.save_file()
    $('.editable').editable({onEdit:setup_file_name_form, onSubmit:submit_file_name, submit:'Save', cancel:'Cancel'})
    # can't get styles to work, so adding in here:
  
setup_file_name_form = ->
  # add classes to buttons:
  $(".editable button").addClass("btn btn-small");
  $(".editable button:eq(0)").addClass("btn-primary");
  # add attributes to the field
  $("#editor_form .editable input").attr("name", "test_file[name]")

submit_file_name = (content) ->
  if content.current isnt content.previous
    $("#editor_form").submit
    

setup_editor = ->
  # API: https://github.com/ajaxorg/ace/wiki/Embedding---API
  window.editor = ace.edit("editor")
  window.editor.setTheme "ace/theme/twilight"
  window.editor.getSession().setTabSize 2
  window.editor.getSession().setUseSoftTabs true 
  window.editor.getSession().setValue $("#editor_content").val()
  window.editor.setShowPrintMargin(false);
  $("#editor_content").hide()
  $("#editor_form").submit ->
    saving_file()
    editor_text = window.editor.getSession().getValue()
    $("#editor_content").val editor_text
    window.text_hash = make_hash(editor_text)
  $("#editor").keydown (event) ->
    window.lastKeyPress = (new Date).getTime()
    
  SafeWTFGrammar = require("ace/mode/safewtf").Mode
  window.editor.getSession().setMode new SafeWTFGrammar()

saving_file = ->
  $("#editor_status").html "Saving..."
  $("#editor_status").addClass "working"
  $("#editor_form input[type='submit']").attr "disabled", true

window.save_file = ->
  new_text_hash = make_hash(window.editor.getSession().getValue())
  if (new_text_hash isnt window.text_hash) and window.editor.getSession().getValue() isnt '' and (new Date).getTime() - window.lastKeyPress > 500
    $("#editor_form input[type='submit']").click()
    saving_file()
  else
    setTimeout("window.save_file()", 1000);

make_hash = (input_text) ->
  shaObj = new jsSHA input_text, "ASCII"
  shaObj.getHash "B64"
  
