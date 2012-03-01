$("body.test_runs.index").ready ->
  # setup results list accordion:    
  $("#test_runs_list .collapse").collapse
    parent: "#test_runs_list"
    toggle: false
  #TODO - not sure id this is doing anything
