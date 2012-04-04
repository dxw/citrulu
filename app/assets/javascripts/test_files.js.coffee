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

##
# When the window loads, set up the editor and kick off the first autosave
#
$(window).load ->
  if($('body').hasClass('test_files') && $('body').hasClass('edit'))
    setup_editor()
    
    setup_title()
    
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
    
    # When the form is reset or submitted, show the icon again
    "onreset": -> insert_edit_icon()
    "onsubmit": -> insert_edit_icon()
  }
    
  test_file_id = $(".editable").attr("data-id")
  $(".editable").editable("/test_files/"+test_file_id, args)
  
  $(".editable").click( (e) -> 
    $("#edit_icon").remove()
    $(".editable input").css("width","100%")
  )

insert_edit_icon = ->
  # Insert an icon after the field
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

##
# Returns a hash of the input text. Used to detect whether the test file has been changed
#
make_hash = (input_text) ->
  shaObj = new jsSHA input_text, "ASCII"
  shaObj.getHash "B64"
  
##
# Returns an object containing the full text of the test group currently under the cursor 
# and the line number of the cursor within that group
#
get_current_group = ->
  cur_line = line = window.editor.getCursor().line

  # Find the start of the group
  while line > 0 && !window.editor.getLine(line).match(/^\s*On/)
    line--
  start = line


  # Find the end of the group
  line++
  while line < window.editor.lineCount() && !window.editor.getLine(line).match(/^\s*On/)
    line++

  end = line

  content = window.editor.getRange({line: start, ch: 0}, {line: end, ch: -1})

  return {group: '', current_line: 0} if !content.match(/^\s*On/)
  
 
  {group: content, current_line: cur_line - start }
  
##
# Requests an Ajax update of the live view area
#
update_liveview = -> 
  window.lastGroup = get_current_group()

  $("#liveview div.on").addClass("working");
  jQuery.ajax(url: '/test_files/update_liveview', data: get_current_group(), type: 'POST', dataType: 'script', complete: (xhr, status) -> 
    update_selected_test(get_current_group())
  )

##
# Moves the .current style in the live view to the currently selected group
#
update_selected_test = (current_group) ->
  selected_test = current_group.group.split("\n")[current_group.current_line].trim()

  $("#liveview div.group div").removeClass("current")

  return if selected_test == '' 

  $("#liveview div.group div:contains('" + selected_test + "')").addClass('current')


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
    if make_hash(current_group.group) != make_hash(window.lastGroup.group)
      
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
    window.text_hash = make_hash(editor_text)

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
  new_text_hash = make_hash(window.editor.getValue())
  

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
  $("#help_sections pre.editor-code").each (i) ->
    # Apply the mode:
    CodeMirror.runMode( $(this).html(), "text/citrulu-tests", this, {escapeHtml: false})
    # Apply the theme:
    $(this).addClass("cm-s-monokai")
