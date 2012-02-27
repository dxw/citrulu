#Setup the test file editor page:
$("body.test_files.edit").ready ->
  setup_editor()
  # save the file for the first time: 
  window.save_file()

setup_editor = ->
  editor = ace.edit("editor")
  editor.setTheme "ace/theme/twilight"
  editor.getSession().setTabSize 4
  editor.getSession().setUseSoftTabs true 
  editor.getSession().setValue $("#editor_content").val()

  $("#editor_content").hide()
  $("#editor_form").submit ->
    window.save_file()
    $("#editor_content").val editor.getSession().getValue()


window.save_file = ->
  $("#editor_status").html("Saving...");
  $("#editor_status").addClass("working");
  $("#editor_form input[type='submit']").click();
  $("#editor_form input[type='submit']").attr("disabled", true);
  # $("#editor_form").submit().click(); # doesn't seem to work...
  