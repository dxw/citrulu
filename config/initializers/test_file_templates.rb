DEFAULT_TEST_FILE=%{# Welcome to your first test file!

# This file tests example.com - you should change it so that it checks your 
# own website. We should shortly start running these tests! You can 
# check the results on the results tab above.

# A test file consists of any number of test groups.
# Each test group contains checks on a specific URL: 
On http://example.com
  # There are a number of different checks you can do. 
  # This one checks for the text "we maintain a number of domains" 
  # anywhere on the page:
  I should see we maintain a number of domains 
  # N.B. Citrulu is case sensitive, so make sure your text matches exactly!
  
  # You can also check for the absence of text:
  I should not see A horrible error has occurred!
  
  # This check looks for specific text in your source code:
  Source should contain <img src="/_img/iana-logo-pageheader.png
  Source should not contain <img src="images/failwhale.gif 
  
  # This check retrieves the headers of a page and looks for a header with
  # the name you specify:
  Headers should include server
  Headers should not include X-Varnish
  
  # Predefines are lists of common values which you may want to check for.
  # You can see a list of these at the bottom of the help section:
  I should not see :php_errors

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
