require 'spec_helper'

#
# These specs are deliberately lightweight and intended only to ensure
# that these helpers do not throw exceptions or return something odd
#

describe AccordionHelper do
  it "Returns a non-empty string and doesn't throw an exception" do
    accordion = helper.accordion('test') do
      group = helper.accordion_group('test_group') do
        heading = helper.accordion_heading do
          'Heading'
        end

        heading.should be_a(String)
        heading.should_not be_empty

        body = helper.accordion_body do
          'Body'
        end

        body.should be_a(String)
        body.should_not be_empty
      end

      group.should be_a(String)
      group.should_not be_empty
    end

    accordion.should be_a(String)
    accordion.should_not be_empty
  end
end
