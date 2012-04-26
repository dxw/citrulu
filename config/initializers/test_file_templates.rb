DEFAULT_TEST_FILE=%{# Welcome to your first test file!

# This file tests example.com - you should change it so that it checks your 
# own website. We will shortly start running these tests.

# After your tests have run, you can check the results by following the link
# in the menu at the top. While you're writing your tests, the results for
# the page that you're on are displayed in the live view, over there --->

# A test file consists of a number of requests for pages, followed by 
# assertions that check what the request returned.
On http://example.com
  # There are a number of different checks you can do. 
  # This one checks for the text "we maintain a number of domains" anywhere
  # on the page:
  I should see we maintain a number of domains 

  # Citrulu's green keywords are case sensitive, but the values you specify
  # aren't (unless you're using a regular expression).
  
  # You can also check for the absence of text:
  I should not see A horrible error has occurred!
  
  # This assertion looks for specific text in your source code:
  Source should contain <img src="/_img/iana-logo-pageheader.png
  Source should not contain <img src="images/failwhale.gif 

  # You can also write assertions that use regular expressions. You can use a
  # regular expression anywhere where you're specifying a value
  I should see /EXAMPLE\.(COM|ORG)/

  # And if your fingers type quotes without your brain noticing, you can 
  # use those too:
  I should see "EXAMPLE.COM"
  
  # This assertion retrieves the headers of a page and looks for a header with
  # the name you specify:
  Headers should include server
  Headers should not include X-Varnish

  # You can also check the contents of headers:
  Header Server should contain Apache
  Header Content-Type should contain /UTF-8$/
  
# It's good to write tests for specific things, so that you know what broke if 
# the test fails. You can add "So" clauses to remind you what you're looking for:
So I know that the page menu is being displayed
On http://www.iana.org/domains/example/
  Source should contain <div id="header-nav">

# "On..." is really just a shortcut for "When I get...". This syntax lets you use
# other HTTP methods, and also lets you add data:
So I know that the server will respond to POSTs
When I post "variable=value" to http://www.iana.org/domains/example/
  I should see "Example Domains"

# HEAD requests are useful when you only want to check headers. DELETE and GET have
# the same syntax:
When I head http://example.com
  Response code should be 302
  Header Server should contain BigIP

# "When I..." supports the HEAD, GET, POST, PUT and DELETE methods.

# You can also check what response code was returned. If you don't add a
# check like this, Citrulu will assume that you want a 200 response, and
# will add a check for you. But you can specify them yourself:
So I know that custom 404s work
When I get http://www.iana.org/domains/example/this-page-no-existy
  Response code should be 404

# The next bit is for complicated tests, so you might not need to read it 
# now. You can remind yourself about anything you've read by using the Help
# section on the right-hand side.

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
  
# That's it! Super simple right?
# Check out the Help section over there => for more details}

# Doing this once on startup should speed things up:
DEFAULT_TEST_FILE_HASH = DEFAULT_TEST_FILE.hash
