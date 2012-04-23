$(document).ready(function() {
  var tooltips = [
  /* TestFile#Index
   */
  {
    element: '#test_files',
    content: '<h3>Test Files</h3><p>This is your list of test files. Putting tests i' +
             'into more than one file helps to keep things organised. There\'s no limit' + 
             ' to how many tests can be in a file, though.</p>',
    position: {
      edge: 'top'
    }
  },
  {
    element: '#recent_results',
    content: '<h3>Recent Results</h3><p>After your tests start running, their status gets' +
             ' displayed here.</p>'
  },
  

  /* TestFile#Edit
   */
  {
    element: '#liveview',
    content: '<h3>Live View</h3><p>As you type tests, we\'ll run them and display the results here.</p>'
  },
  {
    element: '#test_suite',
    content: '<h3>The Editor</h3><p>This is where you type your tests. Start with something simple like:</p><pre class="editor-code cm-s-monokai ">On http://www.wikipedia.org\n  Source should contain The Free Encyclopedia</pre>',
    position: {
      edge: 'right'
    }
  }
  ];

  $(tooltips).each(function(i, tt) {
    var e = $(tt.element);

    if (e.length == 0 || window.readCookie("tooltip_" + $(e).attr('id')))
      return;

    options = {
      content: tt.content,
      
      position: {
        edge: "left",
        align: "center"
      },

      close: function() {
        window.createCookie("tooltip_" + $(e).attr('id'), true, 99999);
      }
    }

    options = $(options).extend(options, tt);

    $(e).pointer( options ).pointer("open");
  });
});
