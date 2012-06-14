$(document).ready ->
  if($('body').hasClass('test_runs') && $('body').hasClass('index'))
    $("body.test_runs .group").equalHeights()
