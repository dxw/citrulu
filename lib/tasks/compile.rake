require 'grammar/symbolizer'
require 'grammar/parser'
require 'awesome_print'

default_source = %{# I should see
On http://example.com/1
  I should see x

# I should not see
On http://example.com/2
  I should not see x

# Source should contain
On http://example.com/3
  Source should contain x

# Source should not contain
On http://example.com/4
  Source should not contain x

# Headers should include
On http://example.com/5
  Headers should include x

# Headers should not include
On http://example.com/6
  Headers should not include x

# Values with quotes
On http://example.com/6a
  Headers should not include "x"

# First, fetch
On http://example.com/7
  First, fetch http://example.com/
  I should see x

# Finally, fetch
On http://example.com/8
  Finally, fetch http://example.com/
  I should see x

# Names
On http://example.com/8
  I should see :php_errors

# Header should contain
On http://example.com/9
  Header X-Varnish should contain foo
  
# Header should not contain
On http://example.com/9a
  Header X-Varnish should not contain foo

# Match page to regex
On http://example.com/11
  I should see /abc/

# Match source to regex
On http://example.com/12
  Source should contain /abc/

# Match header to regex
On http://example.com/13
  Headers should include /abc/

# Match header contents to regex
On http://example.com/14
  Header X-Varnish should contain /abc/

# So clauses work
So I know that santa-clause is a pixie
On http://example.com/14
  Header X-Varnish should contain /abc/

# Response codes
On http://example.com/15
  Response code should be 200

# Response codes
On http://example.com/15
  Response code should be 200 after redirect

# Space doesn't matter
     So I know that foo
  On http://example.com/16
       I should see x

     So I know that foo
  When I post "a=b" to http://example.com/16
       I should see x

# Comments don't matter
So I know that foo 
# comment 1
# comment 2
When I post "a=b" to http://example.com/17 
# comment 3
I should see X 
# comment 4
# comment 5
# comment 6 
# comment 7
I should not see Y 
# comment 8

# When I head
When I head http://example.com/10
  I should see x

# When I get
When I get http://example.com/10
  I should see x

# When I delete
When I delete http://example.com/10
  I should see x

# When I put
When I post "a=b&c=d" to http://example.com/10
  I should see x

# When I put
When I put "a=b&c=d" to http://example.com/10
  I should see x

# Regexes with escaped slashes
On http://example.com
  I should see /<h3>Bloobidiblahya<\\\/h3>/

# Values in quotes with escaped quotes
On http://example.com
  I should see "I should see \\\"I should see\\\""

}


desc "Compileae test file"
task(:compile, [:testfile]) do |t, args|
  args.with_defaults(:testfile => nil)

  if args.testfile.nil?
    source = default_source
  else
    source = File.read(args.testfile)
  end

  puts "Compiling:"
  source.split("\n").each_with_index do |line, index|
    puts "#{"%03d" % index} | #{line}"
  end

  x = CitruluParser.new
  puts "\n\nParser says:"
  begin
    ap x.compile_tests(source)
  rescue Exception => e
    puts "#{e}"
    puts e.backtrace.join("\n")
  end
end
