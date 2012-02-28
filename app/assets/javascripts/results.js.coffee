$("body.results.index").ready ->
  # setup results list accordion:    
  $("#results List .collapse").collapse
    parent: "#results List"
    toggle: false
