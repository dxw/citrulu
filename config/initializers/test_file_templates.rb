DEFAULT_TEST_FILE=%{# Welcome to your first test file!

# This file tests example.com - you should change it so that it checks your 
# own website. we should shortly start running running these tests! You can 
# check the results on the results tab above.

# A test file consists of any number of test groups.
# Each test group contains checks on a specific URL: 
On http://example.com
  # There are a number of different checks you can do. 
  # This one checks for the text "Welcome to this site" anywhere on the page:
  I should see we maintain a number of domains such as EXAMPLE.COM
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
  I should not see =php_errors
  
# That's it! Super simple right?
# Check out the Help section over there => for more details}

# Doing this once on startup should speed things up:
DEFAULT_TEST_FILE_HASH = DEFAULT_TEST_FILE.hash
