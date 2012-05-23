SITE_IS_UP_TEST_FILE={
  name: "Tutorial 1: First steps",
  text: 
    %{On http://wikipedia.org
  I should see Hello World},
  help: [
    "This is a very simple test file which checks that Wikipedia is up and running by looking for some text that should be visible on that page.",
    "The first thing to notice is the 'Live view' over on the right. This is compiling your tests and checking them against the site. Currently one of the rows in the Live view should be red, indicating that one of the tests isn't passing.",
    "To make the test pass, replace \"Hello World\" with \"The Free Encyclopedia\" (without quotes) and watch that row turn green."
  ]
}

SOURCE_CONTAINS_TEST_FILE={
  name: "Tutorial 2: Testing source code",
  text:
    %{So I know that The site is working
  On http://www.flickr.com
    # The following text is in the alt tag of the flickr logo:
    #   alt="Flickr logo. If you click it, you'll go home"
    I should see Flickr logo},
  help: [
    # It's good to write tests for specific things, so that you know what broke if 
    # the test fails. You can add "So" clauses to remind you what you're looking for:
    
      "It's good to write tests for specific things, so that you know what broke if the test fails. You can add \"So\" clauses to remind you what you're looking for.",
      "You can also add comment lines to remind yourself what a particular step is doing. Comment lines start with a #",
      "Comments and \"So I know that\" clauses are both ignored by Citrulu",
      "Sometimes the thing you want to look for to make sure that a site is up isn't in the text of the page. Citrulu supports a number of different types of checks",
      "To check for strings in the markup of the page you can use the \"Source should contain\"",
      "To make the test pass, replace the \"I should see\" with \"Source should contain\""
    ]
}

MULTIPLE_GROUPS_AND_REGEX_TEST_FILE={
  name: "Tutorial 3: A more complex test file",
  text:
    %{So I know that the site is working
      On http://bbc.co.uk
        Source should contain alt="BBC"

    So I know that the weather feed is working
      On http://bbc.co.uk
        # Should have three temperatures, e.g. 25\xC2\xB0C
        I should see /[0-9]+\xC2\xB0C/
        Source should contain <div class="weather-icon">
        Source should contain <a href="http://www.bbc.co.uk/weather/

    So I know that the weather page is working
      On http://bbc.co.uk/weather
        I should see /Khazakstan (Today|Overnight)/

    So I know that all the content discovery sections are present
      On http://bbc.co.uk
        I should see Most popular
        I should see What's on
        I should see Explore},
  help: [
      "You can test as many things as you like on each URL",
      "You can also test multiple URLs and perform different groups of checks on the same URL",
      "You can use Regular Expressions to write more flexible tests",
      "Fix the test which is failing by replacing Khazakstan with the location of the Citrulu servers (UK)"
    ]
}


ADVANCED_ASSERTIONS_TEST_FILE={
  name: "Tutorial 4: Testing Headers and Response Codes",
  text:
    %{So I know that caching is working
      On http://www.youtube.com
      Headers should include Expires
      Headers should not include Etag
      Header Cache-Control should contain FOO
      Header Cache-Control should not contain private

    So I know that my content and markup are OK 
      On http://www.youtube.com
      Source should not contain </br>
      I should not see Damn 

    So I know that redirection is working
      On http://www.wikipedia.com
        # Response code should be a redirect - 3xx
        Response code should be /3../
        Response code should be 200 after redirect

    So I know that /nonsense doesn't exist 
      On http://www.amazon.co.uk/nonsense         
        Response code should be 200},
  help: [
      "There are two checks you can perform on HTTP headers: \"Headers should include\" checks for the existence of a header",
      "The other type of header check looks for a particular value in that header. Replace \"FOO\" with \"no-cache\" to make the step pass",
      "All checks support negatives - e.g. \"I should not see\". Try adding some more checks for things which clearly shouldn't be in a page.",
      "All checks that Citrulu runs have an implicit expectation that the HTTP response code should be 200 (OK) unless specified otherwise",
      "www.wikipedia.com returns a 301 redirect - we can check for that with \"Response code should be\"",
      "We can also check that when the redirect is followed, we successfully get the page.",
      "In the amazon.com example, change the expected response code to 400 to make that test pass."
    ]
}

HTTP_METHODS_TEST_FILE={
  name: "Tutorial 5: Testing POSTs and PUTs and all that jazz",
  text:
    %{When I get http://wikipedia.org
      I should see Hello World

    So I know that searches work
      When I post "search_query=kittens" to http://www.youtube.com/results
        I should see Search Results
        I should see Kittens on a Slide

    So I know that searches work
      When I get http://www.youtube.com
        I should not see Search Results

    When I head http://example.com
      Response code should be 302
      Header Server should contain BigIP},
  help: [
    "\"On...\" is really just a shortcut for \"When I get...\"",
    "This syntax lets you use other HTTP methods, and also lets you add data via POST and PUT",
    "HEAD requests are useful when you only want to check headers.",
    "\"When I...\" supports the HEAD, GET, POST, PUT and DELETE methods.",
    ]
}

BROKEN_TEST_FILE={
  name: "Tutorial 6: I'm broken - fix me",
  text:
    %{So I know that The page works
      On www.youtube.com
        I should see YouTube

    So I know that The page works
      On https://www.faycebookz.com/
        I should see Facebook

    So I know that The page works
      On http://youtube.c%m
        Source should contain Broadcast Yourself

    So I know that there are no </br> tags 
      On http://www.facebook.com
      Source Should not contain </br>

    So I know that the site works
    So I know that both sites work
      On http://www.wikipedia.com
      On http://www.wikipedia.org
        Response code should be 200 after redirect

    So I know that the site works
      On http://twitter.com/ 
        I should see Welcome to twitter # this is some text on the homepage},
  help: [
    "This test file isn't compiling: see if you can fix it. We'll give you some hints:",
    "All URLs must be prefixed with http:// or https://",
    "Badly formed or unreachable URLs will show up as errors in the Live View (we're working on making those errors more user-friendly)",
    "Assertions are case-sensitive and only have a capital letter at the beginning",
    "Only one \"So I know that\" line and one \"On\" line are allowed for each block",
    "Most assertions don't support inline comments"
    ]
}


# Setup and Teardown
# ------------------
# For more complicated tests, there might be setup and teardown actions
# that you want to perform. Or, you might want to add something to your 
# site that provides the Citrulu test-runner a logged-in session, so you
# can test things that are only visible to authenticated users.

# You can do this using the First and Finally commands. Citrulu will
# fetch the "First" url, then the test url, and then the "Finally"
# url. These statements must appear at the start of the test group.
#On http://example.com
#  First, fetch http://example.com/example/28268-eba/log-in-citrulu
#  Finally, fetch http://example.com/example/28268-eba/log-out-citrulu
#  I should see "Welcome, Citrulu!"
#  I should see "Log out"
#  I should not see "Log in to continue"


TUTORIAL_TEST_FILES = [
  SITE_IS_UP_TEST_FILE,
  SOURCE_CONTAINS_TEST_FILE,
  MULTIPLE_GROUPS_AND_REGEX_TEST_FILE,
  ADVANCED_ASSERTIONS_TEST_FILE,
  POSTS_FIRST_FINALLY_TEST_FILE,
  BROKEN_TEST_FILE
  # PREDEFS_TEST_FILE,
  # SETUP_TEARDOWN_TEST_FILE,
]