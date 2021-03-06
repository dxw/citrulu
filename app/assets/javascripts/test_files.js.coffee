#
# Odds & ends for the index page
#

$(document).ready ->
  if($('body').hasClass('test_files') && $('body').hasClass('index'))
    $("div.welcome a.dismiss").click ->
      $("div.welcome").fadeOut('fast')
      id = $('div.welcome').attr('id')
      window.createCookie("hide_#{id}", 'true', 999)
    window.show_no_test_files()
  
window.show_no_test_files = ->
  # Show it if it's the only thing in the list:
  if $("#test_files li").length == 1
    $("#no_test_files").show('bounce')

#
# Setup the test file editor page:
#

##
# When the window loads, set up the editor and kick off the first autosave
#
$(window).load ->
  if($('body').hasClass('test_files') && ($('body').hasClass('edit') || $('body').hasClass('new') ))
    setup_editor()
    
    setup_title()
    
    setup_run_status_toggle()
    
    setup_tutorial_help()
    
    highlight_help_text_code()
    
    # create a placeholder to store a hash of the text:
    window.text_hash = ""
    # initialise the key press tracker so that the file will save straight away:
    window.lastKeyPress = (new Date).getTime()
    
    # Set the current group
    window.lastGroup = get_current_group()

    # No keypresses have yet happened
    window.keyPressHasHappened = false

    # save the file for the first time: 
    window.save_file()

    # Add the update liveview button
    $('#liveview div.buttons').append("<a class='btn' id='refresh_liveview'><i class='icon-refresh'></i> Refresh liveview</a>")
    $('#refresh_liveview').click ->
      update_liveview()
    

setup_title = ->
  insert_edit_icon()
  
  # Config for jeditable:
  args = {    
    data: (value, settings) ->
      # Unescape HTML
      retval = value
        .replace(/&amp;/gi, '&')
        .replace(/&gt;/gi, '>')
        .replace(/&lt;/gi, '<')
        .replace(/&quot;/gi, "\"");
      return retval
   
    method:"PUT", 
    name:"test_file[name]",
    
    onblur: "submit", 
    
    # When the form is reset or submitted, show the icon again
    "onreset": -> insert_edit_icon()
    "onsubmit": -> insert_edit_icon()
    
  }
    
  test_file_id = $(".editable").attr("data-id")
  $(".editable").editable("/test_files/update_name/"+test_file_id, args)
  
  $(".editable").click( (e) -> 
    $("#edit_icon").remove()
    $(".editable input").css("width","100%")
  )
  
  title_editable_if_new()


insert_edit_icon = ->
  # Insert an icon after the field if one doesn't already exist:
  if $("#edit_icon").length == 0
    $(".editable").after("<i id='edit_icon' class='icon-pencil'/>")
    # Clicking on the icon acts like clicking on the field
    $("#edit_icon").click( -> $(".editable").click() )
  
  # # Check to see if there is enough room to fit the icon on the same line as the content:  
  # icon_width = 
  #   $("#edit_icon").width() + 
  #   parseInt($("#edit_icon").css('marginLeft')) + 
  #   parseInt($("#edit_icon").css('marginRight'))
  # 
  # # HACK?: if there isn't enough room for the icon, put some padding on the parent to force the line to wrap
  # if $(".editable").parent().width() - $(".editable").width()  < icon_width
  #   $(".editable").parent().css('margin-right',icon_width + 10)
  # else
  #   $(".editable").parent().css('margin-right','0')

# When the user has created a new test file we want the title to be editable and the focus to be in the field
title_editable_if_new = ->
  # Get the param value using the BBQ jquery plugin:
  if $.deparam.querystring()['new']
    $(".editable").click()

# Set up the toggle button used to set the run status
setup_run_status_toggle = ->
  toggle_button = $("#run_status_toggle_form input[type=submit]")
  toggle_button.click ->
    # Set the value explicitly in case the browser and db drift out of sync
    if $("#test_file_run_tests").val() == "t" || $("#test_file_run_tests").val() == "true"
      $("#test_file_run_tests").val(false)
      toggle_button.val('Start')
      toggle_button.removeClass("btn-success").removeClass("btn-danger")
    else
      $("#test_file_run_tests").val(true)
      toggle_button.val('On')
      toggle_button.addClass("btn-success")
    
  toggle_button.hover(
    -> (
      if toggle_button.hasClass("btn-success")
        toggle_button.val('Stop')
        toggle_button.removeClass("btn-success")
        toggle_button.addClass("btn-danger")
    ),
    -> (
      if toggle_button.hasClass("btn-danger")
        # Then the button wasn't clicked
        toggle_button.val('On')
        toggle_button.removeClass("btn-danger")
        toggle_button.addClass("btn-success")
    )
  )
    
# Set up the help text carousel for tutorial files:
setup_tutorial_help = ->
  $('.carousel').carousel()
  $('.carousel').carousel('pause')



##
# Returns a hash of the input text. Used to detect whether the test file has been changed
#
window.make_hash = (input_text) ->
  $.md5(input_text);
  
##
# Returns an object containing the full text of the test group currently under the cursor 
# and the line number of the cursor within that group
#
get_current_group = ->
  cur_line = line = window.editor.getCursor().line

# console.log "Started on #{cur_line}"

  # Find the start of the group
  while line > 0 && !window.editor.getLine(line).match(/^\s*(On|When|So I know that)\s/)
    line--

#  console.log "First thing is at line #{line}"

  # We've found a starting thing. Now make sure we're on the first one
  while line > 0 && window.editor.getLine(line).match(/^\s*(On|When|So I know that)\s/)
    line--

  if line != 0 
    line++

  start = line
#  console.log "Found the start at #{start}"

  # Now move out of the starting lines for this group
  while line < window.editor.lineCount() && window.editor.getLine(line).match(/^\s*(On|When|So I know that)\s/)
    line++

#  console.log "Moved back out of starting lines, now at #{line}"

  # Now find the start of the next group
  while line < window.editor.lineCount()  && !window.editor.getLine(line).match(/^\s*(On|When|So I know that)\s/)
    line++

#  console.log "Found the next group at #{line}"

  if line == window.editor.lineCount()
    end = line
  else
    end = line-1

#  console.log "This group: #{start} .. #{end}\n\n"

  content = window.editor.getRange({line: start, ch: 0}, {line: end, ch: -1})

  return {group: '', current_line: 0} if !content.match(/^\s*(On|When|So)\s/)
 
  {group: content, current_line: cur_line - start }
  
##
# Requests an Ajax update of the live view area
#
update_liveview = -> 
  window.lastGroup = get_current_group()

  group_data = get_current_group()

  return if group_data.group == ''

  $("#liveview h2").addClass("working");
  jQuery.ajax(url: '/test_files/update_liveview', data: group_data, type: 'POST', dataType: 'script', complete: (xhr, status) -> 
    update_selected_test(get_current_group())
    $('#liveview h2').removeClass('working');
    $('#liveview .group').effect('highlight', {color: '#8f8'}, 1000)
  )

##
# Moves the .current style in the live view to the currently selected group
#
update_selected_test = (current_group) ->

  selected_test = current_group.group.split("\n")[current_group.current_line].trim()

  $("#liveview div.group div").removeClass("current")

  return if selected_test == '' 

  $("#liveview div.group div." + window.make_hash( selected_test)).addClass('current')


##
# Checks whether a live view update is necessary and starts one if so
#
# A better way to do this would be to:
#  - set a timeout whenever a key is pressed
#  - if another key is pressed before the timeout fires, cancel the timeout
#  - When the user stops typing, the timeout will fire. This is something like an 
#    onUserStopsTyping event, which is what we really want
window.check_liveview = ->
  setTimeout("window.check_liveview()", 150);

#  console.info( "#{window.keyPressHasHappened} and #{(new Date).getTime()- window.lastKeyPress} < 150")
 
  # If there has been no input since we last run, bail out
  return if !window.keyPressHasHappened or (new Date).getTime()- window.lastKeyPress < 150

#  console.info "#{window.editor.getCursor().line} != #{window.lastCursorPosition}"

  # Has the cursor moved?
  if window.editor.getCursor().line != window.lastCursorPosition
   
    # Check what group we're now in, and update the cursor
    current_group = get_current_group()
    update_selected_test(current_group)

    # Has the current group been changed?
    if window.make_hash(current_group.group) != window.make_hash(window.lastGroup.group)
      
      # Is the group big enough to be a valid group?

      # Get an array with trimmed lines and comments removed
      group = jQuery.map(current_group.group.split("\n"), (n) ->  n = $.trim(n); n = n.replace(/^# [^\n]*/, ''); return n; )

      # Zap the empty lines
      group = jQuery.grep(group, (n) -> return n;)

#      console.info group

      if group.length > 1
#        console.info "I'm updating now"
        update_liveview()

  window.keyPressHasHappened = false
  window.lastCursorPosition = window.editor.getCursor().line

##
# Embeds the editor and adds event handlers
#
setup_editor = ->
  window.editor = CodeMirror.fromTextArea($('#editor_content')[0], {
    theme: 'monokai',
    lineNumbers: true,
  });

  setTimeout("window.check_liveview()", 150);
  $('.CodeMirror').click (event) ->
    window.keyPressHasHappened = false
    update_liveview()

  $(".CodeMirror").keydown (event) ->
    window.lastKeyPress = (new Date).getTime()
    window.keyPressHasHappened = true

    if event.keyCode >= 37 && event.keyCode <= 40
      window.lastKeyWasCursor = true 

  $("#editor_form").submit ->
    saving_file()
    editor_text = window.editor.getValue()
    window.text_hash = window.make_hash(editor_text)

##
# Updates the UI to indicate that a save is in progress
#
saving_file = ->
  $("#editor_status").html "Saving..."
  $("#editor_status").addClass "working"
  $("#editor_form input[type='submit']").attr "disabled", true

##
# Initiates an an autosave if the test file text has been modified and the user is not currently typing
#
window.save_file = ->
  new_text_hash = window.make_hash(window.editor.getValue())
  

  if (new_text_hash isnt window.text_hash) and window.editor.getValue() isnt '' and (new Date).getTime() - window.lastKeyPress > 500
    $("#editor_form input[type='submit']").click()
    window.keyPressHasHappened = false
    update_liveview();
  else
    setTimeout("window.save_file()", 1000);

##
# Highlights the code fragments in the help text
#

highlight_help_text_code = ->
  $("pre.editor-code").each (i) ->
    # Apply the mode:
    CodeMirror.runMode( $(this).html(), "text/citrulu-tests", this, {escapeHtml: false})
    # Apply the theme:
    $(this).addClass("cm-s-monokai")
    
##
# When the window loads, set up the editor and kick off the first autosave
#
$(window).load ->
  if $('body').hasClass('info')
    highlight_help_text_code()