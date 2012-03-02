$("body.test_runs.index").ready ->
  # setup test_runs_list accordion:    
  $("#test_runs_list .collapse").collapse
    parent: "#test_runs_list"
    toggle: false
  # TODO - not sure this is doing anything
