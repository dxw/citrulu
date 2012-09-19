module TesterGrammar
  module TestFile
    def process
      elements.collect {|group| group.process}
    end
  end

  module TestGroup
    def process
      results = {
        :page => page_clause.process,
        :tests => elements[2].elements.collect{|e| e.process}
      }

      single_assertions = single_assertion.process
      results[:page][:first] = single_assertions[:first]
      results[:page][:finally] = single_assertions[:finally]

      found_response_assertion = false

      results[:tests].each do |test|
        if test[:assertion] == :response_code_be || test[:assertion] == :response_code_not_be
          found_response_assertion = true

          results[:page][:redirect] = test[:redirect]
          test.delete(:redirect)

          break
        end
      end
      
      if !found_response_assertion
        results[:tests].insert(0, {
          :assertion => :response_code_be,
          :value => '200',
          :original_line => 'Response code should be 200 after redirects',
        })
        
        results[:page][:redirect] = true
      end

      results
    end
  end

  module PageClause
    def process
      hash = elements[2].process
      hash[:so] = elements[1].text_value.strip if elements[0]

      hash
    end
  end

  module SoClause
  end

  module OnClause
    def process
      {
        :method => :get,
        :data => '',
        :url => url.process
      }
    end
  end

  module WhenClause
    def process
      elements[3].process.merge({
        :url => url.process
      })
    end
  end

  module MethodData
    def process
      {
        :method => elements[1].text_value.strip.to_sym,
        :data => quoted_value.process
      }
    end
  end

  module Method
    def process
      {:method => text_value.strip.to_sym}
    end
  end

  module SingleAssertion
    def process
      if elements
        results = {}

        results[:first] = elements[0].url.text_value.strip if !elements[0].empty?
        results[:finally] = elements[1].url.text_value.strip if !elements[1].empty?

        results
      end
    end
  end

  module FirstClause
  end

  module FinallyClause
  end

  module TestLine
    def process
      test.process
    end
  end

  module Test
    def process
      hash = elements[2].process

      hash[:original_line] = elements[2].text_value.strip

      # Horrid hack, really
      if hash[:value].class != Regexp && !hash[:value].nil? && hash[:value].match(/^:[^\s]+/) && !hash[:value].match(/^::/)
        hash[:name] = hash[:value]
        hash[:value] = nil
      end
      
      hash
    end
  end

  module SimpleAssertion
    def process
      {
        :assertion => elements[0].text_value.to_test_sym,
        :value => parameter.process,
      }
    end
  end

  module ComplexAssertion
  end

  module ResponseCode 
    def process
      {
        :assertion => elements[0].text_value.to_test_sym,
        :value => elements[2].process,
        :redirect => !elements[4].empty?
      }
    end
  end

  module HeaderContents
    def process 
      {
        :header => identifier.text_value.strip,
        :assertion => elements[3].text_value.to_test_sym,
        :value => parameter.process
      }
    end
  end

  module Param
  end

  module Value
    def process
      text_value.strip
    end
  end

  module RequiredValue
    def process
      text_value.strip
    end
  end

  module QuotedValue
    def process
      text_value[1..-2]
    end
  end

  module HttpCode 
    def process
      text_value.strip
    end
  end

  module Regex
    def process 
      Regexp.new(text_value[1..-2])
    end
  end

  module Comment
  end

  module EscapedValue
    def process
      text_value.gsub(/^::/, ':').strip
    end
  end

  module Name
    def process
      text_value.strip
    end
  end

  module Identifier
  end

  module Url
    def process
      text_value.strip
    end
  end

  module Space
  end
end
