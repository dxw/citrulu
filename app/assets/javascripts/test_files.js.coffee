#Setup the test file editor page:
$("body.test_files.edit").ready ->
  setup_editor()
  # create a placeholder to store a hash of the text:
  window.text_hash = ""
  # save the file for the first time: 
  window.save_file()

setup_editor = ->
  window.editor = ace.edit("editor")
  window.editor.setTheme "ace/theme/twilight"
  window.editor.getSession().setTabSize 2
  window.editor.getSession().setUseSoftTabs true 
  window.editor.getSession().setValue $("#editor_content").val()
  $("#editor_content").hide()
  $("#editor_form").submit ->
    saving_file()
    editor_text = window.editor.getSession().getValue()
    $("#editor_content").val editor_text
    window.text_hash = make_hash(editor_text)
    
saving_file = ->
  $("#editor_status").html "Saving..."
  $("#editor_status").addClass "working"
  $("#editor_form input[type='submit']").attr "disabled", true
  # $("#editor_form").submit().click(); # doesn't seem to work...

window.save_file = ->
  new_text_hash = make_hash(window.editor.getSession().getValue())
  # new_text_hash = make_hash($("#editor").getSession().getValue())
  if new_text_hash isnt window.text_hash
    $("#editor_form input[type='submit']").click()
    saving_file()
  else
    setTimeout("window.save_file()", 5000);

make_hash = (input_text) ->
  shaObj = new jsSHA input_text, "ASCII"
  shaObj.getHash "B64"
  