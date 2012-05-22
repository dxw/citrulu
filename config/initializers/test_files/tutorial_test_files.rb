tutorial_test_files = [
  SITE_IS_UP_TEST_FILE,
  SOURCE_CONTAINS_TEST_FILE,
  
  MULTIPLE_GROUPS_AND_REGEX_TEST_FILE,
  
  # NEGATIONS_TEST_FILE,
  #  PREDEFS_TEST_FILE,
  #  GOTCHAS_TEST_FILE,
  #  BAD_URL_TEST_FILE,
]

# Add in hashes of the file text. Doing this once on startup should speed things up:
TUTORIAL_TEST_FILES = tutorial_test_files.collect{|f| f.merge(hash: f[:text].hash)}


SITE_IS_UP_TEST_FILE={
  text: 
    %{On http://wikipedia.org
  I should see The Free Encyclopedia}
  help: [
    "This is a very simple test file which checks that Wikipedia is up and running by looking for some text that should be visible on that page.",
    "The first thing to notice is the 'Live view' over on the right. This is compiling your tests and checking them against the site. Currently one of the rows in the Live view should be red, indicating that one of the tests isn't passing.",
    "To make the test pass, replace \"Hello World\" with \"The Free Encyclopedia\" (without quotes) and watch that row turn green."
  ]

SOURCE_CONTAINS_TEST_FILE={
  text:
    %{So I know that The site is working
  On http://www.flickr.com
    # The following text is in the alt tag of the flickr logo:
    #   alt="Flickr logo. If you click it, you'll go home"
    I should see Flickr logo}
  help: [
      "You can optionally describe what a block of checks is doing using a \"So I know that\" clause before the URL",
      "You can also add comment lines to remind yourself what a particular step is doing. Comment lines start with a #",
      "Comments and \"So I know that\" clauses are both ignored by Citrulu",
      "Sometimes the thing you want to look for to make sure that a site is up isn't in the text of the page. Citrulu supports a number of different types of checks",
      "To check for strings in the markup of the page you can use the \"Source should contain\""
      "To make the test pass, replace the \"I should see\" with \"Source should contain\""
    ]
}

MULTIPLE_GROUPS_AND_REGEX_TEST_FILE={
  text:
    %{So I know that the site is working
      On http://bbc.co.uk
        Source should contain alt="BBC"

    So I know that the weather feed is working
      On http://bbc.co.uk
        # Should have three temperatures, e.g. 25°C
        I should see /[0-9]+°C/
        Source should contain <div class="weather-icon">
        Source should contain <a href="http://www.bbc.co.uk/weather/

    So I know that the weather page is working
      On http://bbc.co.uk/weather
        I should see /Khazakstan (Today|Overnight)/

    So I know that all the content discovery sections are present
      On http://bbc.co.uk
        I should see Most popular
        I should see What's on
        I should see Explore}
  help: [
      "You can test as many things as you like on each URL",
      "You can also test multiple URLs and perform different groups of checks on the same URL",
      "You can use Regular Expressions to write more flexible tests",
      "Fix the test which is failing by replacing Khazakstan with the location of the Citrulu servers (UK)"
    ]
}





Gotchas:
 Inline comments
 case sensitivity