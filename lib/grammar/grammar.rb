# Autogenerated from a Treetop grammar. Edits may be lost.


module TesterGrammar
  include Treetop::Runtime

  def root
    @root ||= :test_file
  end

  module TestFile0
    def space1
      elements[1]
    end

    def space2
      elements[3]
    end
  end

  module TestFile1
    def process
      elements[2].elements.collect{|e| e.process}
    end
  end

  def _nt_test_file
    start_index = index
    if node_cache[:test_file].has_key?(index)
      cached = node_cache[:test_file][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    s1, i1 = [], index
    loop do
      r2 = _nt_comment
      if r2
        s1 << r2
      else
        break
      end
    end
    r1 = instantiate_node(SyntaxNode,input, i1...index, s1)
    s0 << r1
    if r1
      r3 = _nt_space
      s0 << r3
      if r3
        s4, i4 = [], index
        loop do
          r5 = _nt_test_group
          if r5
            s4 << r5
          else
            break
          end
        end
        if s4.empty?
          @index = i4
          r4 = nil
        else
          r4 = instantiate_node(SyntaxNode,input, i4...index, s4)
        end
        s0 << r4
        if r4
          r6 = _nt_space
          s0 << r6
        end
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(TestFile0)
      r0.extend(TestFile1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:test_file][start_index] = r0

    r0
  end

  module TestGroup0
    def page_clause
      elements[1]
    end

    def single_assertion
      elements[3]
    end

  end

  module TestGroup1
    def process
      results = {
        :page => page_clause.process,
        :tests => elements[5].elements.collect{|e| e.process}
      }

      single_assertions = single_assertion.process

      results[:page][:first] = single_assertions[:first]
      results[:page][:finally] = single_assertions[:finally]

      # TODO: only add if there isn't one

      assertions = results[:tests].collect{|x| x[:assertion]}.uniq
      if !assertions.include?(:response_code_be) && !assertions.include?(:response_code_not_be)
        results[:tests].insert(0, {
          :assertion => :response_code_be,
          :value => '200',
          :original_line => 'Response code should be 200'
        })
      end

      results
    end
  end

  def _nt_test_group
    start_index = index
    if node_cache[:test_group].has_key?(index)
      cached = node_cache[:test_group][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    s1, i1 = [], index
    loop do
      r2 = _nt_comment
      if r2
        s1 << r2
      else
        break
      end
    end
    r1 = instantiate_node(SyntaxNode,input, i1...index, s1)
    s0 << r1
    if r1
      r3 = _nt_page_clause
      s0 << r3
      if r3
        s4, i4 = [], index
        loop do
          r5 = _nt_comment
          if r5
            s4 << r5
          else
            break
          end
        end
        r4 = instantiate_node(SyntaxNode,input, i4...index, s4)
        s0 << r4
        if r4
          r6 = _nt_single_assertion
          s0 << r6
          if r6
            s7, i7 = [], index
            loop do
              r8 = _nt_comment
              if r8
                s7 << r8
              else
                break
              end
            end
            r7 = instantiate_node(SyntaxNode,input, i7...index, s7)
            s0 << r7
            if r7
              s9, i9 = [], index
              loop do
                r10 = _nt_test_line
                if r10
                  s9 << r10
                else
                  break
                end
              end
              r9 = instantiate_node(SyntaxNode,input, i9...index, s9)
              s0 << r9
              if r9
                s11, i11 = [], index
                loop do
                  r12 = _nt_comment
                  if r12
                    s11 << r12
                  else
                    break
                  end
                end
                r11 = instantiate_node(SyntaxNode,input, i11...index, s11)
                s0 << r11
              end
            end
          end
        end
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(TestGroup0)
      r0.extend(TestGroup1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:test_group][start_index] = r0

    r0
  end

  module SingleAssertion0
  end

  module SingleAssertion1
    def process
      if elements
        results = {}

        results[:first] = elements[0].url.text_value.strip if !elements[0].empty?
        results[:finally] = elements[2].url.text_value.strip if !elements[2].empty?

        results
      end
    end
  end

  def _nt_single_assertion
    start_index = index
    if node_cache[:single_assertion].has_key?(index)
      cached = node_cache[:single_assertion][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r2 = _nt_first_clause
    if r2
      r1 = r2
    else
      r1 = instantiate_node(SyntaxNode,input, index...index)
    end
    s0 << r1
    if r1
      s3, i3 = [], index
      loop do
        r4 = _nt_comment
        if r4
          s3 << r4
        else
          break
        end
      end
      r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
      s0 << r3
      if r3
        r6 = _nt_finally_clause
        if r6
          r5 = r6
        else
          r5 = instantiate_node(SyntaxNode,input, index...index)
        end
        s0 << r5
        if r5
          s7, i7 = [], index
          loop do
            r8 = _nt_comment
            if r8
              s7 << r8
            else
              break
            end
          end
          r7 = instantiate_node(SyntaxNode,input, i7...index, s7)
          s0 << r7
        end
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(SingleAssertion0)
      r0.extend(SingleAssertion1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:single_assertion][start_index] = r0

    r0
  end

  module OnClause0
    def space1
      elements[0]
    end

    def space2
      elements[2]
    end

    def url
      elements[3]
    end
  end

  module OnClause1
    def process
    {
      :method => :get,
      :data => '',
      :url => url.text_value.strip
    }
    end
  end

  def _nt_on_clause
    start_index = index
    if node_cache[:on_clause].has_key?(index)
      cached = node_cache[:on_clause][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_space
    s0 << r1
    if r1
      if has_terminal?("On", false, index)
        r2 = instantiate_node(SyntaxNode,input, index...(index + 2))
        @index += 2
      else
        terminal_parse_failure("On")
        r2 = nil
      end
      s0 << r2
      if r2
        r3 = _nt_space
        s0 << r3
        if r3
          r4 = _nt_url
          s0 << r4
        end
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(OnClause0)
      r0.extend(OnClause1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:on_clause][start_index] = r0

    r0
  end

  module WhenClause0
    def space1
      elements[0]
    end

    def space2
      elements[3]
    end

    def url
      elements[4]
    end
  end

  module WhenClause1
    def process
      elements[2].process.merge({
        :url => url.text_value.strip
      })
    end
  end

  def _nt_when_clause
    start_index = index
    if node_cache[:when_clause].has_key?(index)
      cached = node_cache[:when_clause][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_space
    s0 << r1
    if r1
      if has_terminal?("When I", false, index)
        r2 = instantiate_node(SyntaxNode,input, index...(index + 6))
        @index += 6
      else
        terminal_parse_failure("When I")
        r2 = nil
      end
      s0 << r2
      if r2
        i3 = index
        r4 = _nt_method_data
        if r4
          r3 = r4
        else
          r5 = _nt_method
          if r5
            r3 = r5
          else
            @index = i3
            r3 = nil
          end
        end
        s0 << r3
        if r3
          r6 = _nt_space
          s0 << r6
          if r6
            r7 = _nt_url
            s0 << r7
          end
        end
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(WhenClause0)
      r0.extend(WhenClause1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:when_clause][start_index] = r0

    r0
  end

  module MethodData0
    def space1
      elements[0]
    end

    def space2
      elements[2]
    end

    def data
      elements[3]
    end

    def space3
      elements[4]
    end

  end

  module MethodData1
    def process
      {
        :method => elements[1].text_value.strip.to_sym,
        :data => data.process
      }
    end
  end

  def _nt_method_data
    start_index = index
    if node_cache[:method_data].has_key?(index)
      cached = node_cache[:method_data][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_space
    s0 << r1
    if r1
      i2 = index
      if has_terminal?("put", false, index)
        r3 = instantiate_node(SyntaxNode,input, index...(index + 3))
        @index += 3
      else
        terminal_parse_failure("put")
        r3 = nil
      end
      if r3
        r2 = r3
      else
        if has_terminal?("post", false, index)
          r4 = instantiate_node(SyntaxNode,input, index...(index + 4))
          @index += 4
        else
          terminal_parse_failure("post")
          r4 = nil
        end
        if r4
          r2 = r4
        else
          @index = i2
          r2 = nil
        end
      end
      s0 << r2
      if r2
        r5 = _nt_space
        s0 << r5
        if r5
          r6 = _nt_data
          s0 << r6
          if r6
            r7 = _nt_space
            s0 << r7
            if r7
              if has_terminal?("to", false, index)
                r8 = instantiate_node(SyntaxNode,input, index...(index + 2))
                @index += 2
              else
                terminal_parse_failure("to")
                r8 = nil
              end
              s0 << r8
            end
          end
        end
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(MethodData0)
      r0.extend(MethodData1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:method_data][start_index] = r0

    r0
  end

  module Method0
    def space
      elements[0]
    end

  end

  module Method1
    def process
      {:method => text_value.strip.to_sym}
    end
  end

  def _nt_method
    start_index = index
    if node_cache[:method].has_key?(index)
      cached = node_cache[:method][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_space
    s0 << r1
    if r1
      i2 = index
      if has_terminal?("head", false, index)
        r3 = instantiate_node(SyntaxNode,input, index...(index + 4))
        @index += 4
      else
        terminal_parse_failure("head")
        r3 = nil
      end
      if r3
        r2 = r3
      else
        if has_terminal?("get", false, index)
          r4 = instantiate_node(SyntaxNode,input, index...(index + 3))
          @index += 3
        else
          terminal_parse_failure("get")
          r4 = nil
        end
        if r4
          r2 = r4
        else
          if has_terminal?("delete", false, index)
            r5 = instantiate_node(SyntaxNode,input, index...(index + 6))
            @index += 6
          else
            terminal_parse_failure("delete")
            r5 = nil
          end
          if r5
            r2 = r5
          else
            @index = i2
            r2 = nil
          end
        end
      end
      s0 << r2
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Method0)
      r0.extend(Method1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:method][start_index] = r0

    r0
  end

  module PageClause0
    def newline
      elements[4]
    end
  end

  module PageClause1
    def process
      elements[2].process.merge({:so => elements[0].text_value.strip})
    end
  end

  def _nt_page_clause
    start_index = index
    if node_cache[:page_clause].has_key?(index)
      cached = node_cache[:page_clause][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r2 = _nt_so_clause
    if r2
      r1 = r2
    else
      r1 = instantiate_node(SyntaxNode,input, index...index)
    end
    s0 << r1
    if r1
      s3, i3 = [], index
      loop do
        r4 = _nt_comment
        if r4
          s3 << r4
        else
          break
        end
      end
      r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
      s0 << r3
      if r3
        i5 = index
        r6 = _nt_on_clause
        if r6
          r5 = r6
        else
          r7 = _nt_when_clause
          if r7
            r5 = r7
          else
            @index = i5
            r5 = nil
          end
        end
        s0 << r5
        if r5
          s8, i8 = [], index
          loop do
            r9 = _nt_comment
            if r9
              s8 << r9
            else
              break
            end
          end
          r8 = instantiate_node(SyntaxNode,input, i8...index, s8)
          s0 << r8
          if r8
            r10 = _nt_newline
            s0 << r10
          end
        end
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(PageClause0)
      r0.extend(PageClause1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:page_clause][start_index] = r0

    r0
  end

  module SoClause0
    def space
      elements[0]
    end

    def value
      elements[2]
    end

    def newline
      elements[3]
    end
  end

  def _nt_so_clause
    start_index = index
    if node_cache[:so_clause].has_key?(index)
      cached = node_cache[:so_clause][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_space
    s0 << r1
    if r1
      if has_terminal?("So", false, index)
        r2 = instantiate_node(SyntaxNode,input, index...(index + 2))
        @index += 2
      else
        terminal_parse_failure("So")
        r2 = nil
      end
      s0 << r2
      if r2
        r3 = _nt_value
        s0 << r3
        if r3
          r4 = _nt_newline
          s0 << r4
        end
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(SoClause0)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:so_clause][start_index] = r0

    r0
  end

  module FirstClause0
    def space
      elements[0]
    end

    def url
      elements[2]
    end
  end

  def _nt_first_clause
    start_index = index
    if node_cache[:first_clause].has_key?(index)
      cached = node_cache[:first_clause][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_space
    s0 << r1
    if r1
      if has_terminal?("First, fetch ", false, index)
        r2 = instantiate_node(SyntaxNode,input, index...(index + 13))
        @index += 13
      else
        terminal_parse_failure("First, fetch ")
        r2 = nil
      end
      s0 << r2
      if r2
        r3 = _nt_url
        s0 << r3
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(FirstClause0)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:first_clause][start_index] = r0

    r0
  end

  module FinallyClause0
    def space
      elements[0]
    end

    def url
      elements[2]
    end

    def newline
      elements[4]
    end
  end

  def _nt_finally_clause
    start_index = index
    if node_cache[:finally_clause].has_key?(index)
      cached = node_cache[:finally_clause][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_space
    s0 << r1
    if r1
      if has_terminal?("Finally, fetch ", false, index)
        r2 = instantiate_node(SyntaxNode,input, index...(index + 15))
        @index += 15
      else
        terminal_parse_failure("Finally, fetch ")
        r2 = nil
      end
      s0 << r2
      if r2
        r3 = _nt_url
        s0 << r3
        if r3
          s4, i4 = [], index
          loop do
            r5 = _nt_comment
            if r5
              s4 << r5
            else
              break
            end
          end
          r4 = instantiate_node(SyntaxNode,input, i4...index, s4)
          s0 << r4
          if r4
            r6 = _nt_newline
            s0 << r6
          end
        end
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(FinallyClause0)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:finally_clause][start_index] = r0

    r0
  end

  module TestLine0
    def space
      elements[1]
    end

    def test
      elements[2]
    end

    def newline
      elements[4]
    end
  end

  module TestLine1
    def process
      test.process
    end
  end

  def _nt_test_line
    start_index = index
    if node_cache[:test_line].has_key?(index)
      cached = node_cache[:test_line][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    s1, i1 = [], index
    loop do
      r2 = _nt_comment
      if r2
        s1 << r2
      else
        break
      end
    end
    r1 = instantiate_node(SyntaxNode,input, i1...index, s1)
    s0 << r1
    if r1
      r3 = _nt_space
      s0 << r3
      if r3
        r4 = _nt_test
        s0 << r4
        if r4
          s5, i5 = [], index
          loop do
            r6 = _nt_comment
            if r6
              s5 << r6
            else
              break
            end
          end
          r5 = instantiate_node(SyntaxNode,input, i5...index, s5)
          s0 << r5
          if r5
            r7 = _nt_newline
            s0 << r7
          end
        end
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(TestLine0)
      r0.extend(TestLine1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:test_line][start_index] = r0

    r0
  end

  module Test0
    def space
      elements[1]
    end

    def parameter
      elements[2]
    end
  end

  module Test1
    def process
      hash = elements[0].process

      hash[:original_line] = text_value

      if parameter.text_value.match(/^:/)
        if parameter.text_value.match(/^::/)
          hash[:value] = parameter.text_value.gsub(/^::/, ':').strip
        else
          hash[:name] = parameter.text_value.strip
        end
      else
        hash[:value] = parameter.text_value.strip

        if matches = hash[:value][0] == '"' && hash[:value][-1] == '"'
          hash[:value] = hash[:value][1..-2]
        end

        if matches = hash[:value][0] == '/' && hash[:value][-1] == '/'
          hash[:value] = Regexp.new(hash[:value][1..-2])
        end
      end

      hash
    end
  end

  def _nt_test
    start_index = index
    if node_cache[:test].has_key?(index)
      cached = node_cache[:test][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    i1 = index
    r2 = _nt_complex_assertion
    if r2
      r1 = r2
    else
      r3 = _nt_simple_assertion
      if r3
        r1 = r3
      else
        @index = i1
        r1 = nil
      end
    end
    s0 << r1
    if r1
      r4 = _nt_space
      s0 << r4
      if r4
        r5 = _nt_parameter
        s0 << r5
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Test0)
      r0.extend(Test1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:test][start_index] = r0

    r0
  end

  module SimpleAssertion0
    def process
    {:assertion => text_value.to_test_sym}
    end
  end

  def _nt_simple_assertion
    start_index = index
    if node_cache[:simple_assertion].has_key?(index)
      cached = node_cache[:simple_assertion][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0 = index
    if has_terminal?("Source should contain", false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 21))
      @index += 21
    else
      terminal_parse_failure("Source should contain")
      r1 = nil
    end
    if r1
      r0 = r1
      r0.extend(SimpleAssertion0)
    else
      if has_terminal?("Source should not contain", false, index)
        r2 = instantiate_node(SyntaxNode,input, index...(index + 25))
        @index += 25
      else
        terminal_parse_failure("Source should not contain")
        r2 = nil
      end
      if r2
        r0 = r2
        r0.extend(SimpleAssertion0)
      else
        if has_terminal?("I should see", false, index)
          r3 = instantiate_node(SyntaxNode,input, index...(index + 12))
          @index += 12
        else
          terminal_parse_failure("I should see")
          r3 = nil
        end
        if r3
          r0 = r3
          r0.extend(SimpleAssertion0)
        else
          if has_terminal?("I should not see", false, index)
            r4 = instantiate_node(SyntaxNode,input, index...(index + 16))
            @index += 16
          else
            terminal_parse_failure("I should not see")
            r4 = nil
          end
          if r4
            r0 = r4
            r0.extend(SimpleAssertion0)
          else
            if has_terminal?("Headers should include", false, index)
              r5 = instantiate_node(SyntaxNode,input, index...(index + 22))
              @index += 22
            else
              terminal_parse_failure("Headers should include")
              r5 = nil
            end
            if r5
              r0 = r5
              r0.extend(SimpleAssertion0)
            else
              if has_terminal?("Headers should not include", false, index)
                r6 = instantiate_node(SyntaxNode,input, index...(index + 26))
                @index += 26
              else
                terminal_parse_failure("Headers should not include")
                r6 = nil
              end
              if r6
                r0 = r6
                r0.extend(SimpleAssertion0)
              else
                if has_terminal?("Response code should be", false, index)
                  r7 = instantiate_node(SyntaxNode,input, index...(index + 23))
                  @index += 23
                else
                  terminal_parse_failure("Response code should be")
                  r7 = nil
                end
                if r7
                  r0 = r7
                  r0.extend(SimpleAssertion0)
                else
                  if has_terminal?("Response code should not be", false, index)
                    r8 = instantiate_node(SyntaxNode,input, index...(index + 27))
                    @index += 27
                  else
                    terminal_parse_failure("Response code should not be")
                    r8 = nil
                  end
                  if r8
                    r0 = r8
                    r0.extend(SimpleAssertion0)
                  else
                    @index = i0
                    r0 = nil
                  end
                end
              end
            end
          end
        end
      end
    end

    node_cache[:simple_assertion][start_index] = r0

    r0
  end

  module ComplexAssertion0
    def space1
      elements[1]
    end

    def identifier
      elements[2]
    end

    def space2
      elements[3]
    end

  end

  module ComplexAssertion1
    def process 
      {
        :header => identifier.text_value.strip,
        :assertion => elements[4].text_value.to_test_sym
      }
    end
  end

  def _nt_complex_assertion
    start_index = index
    if node_cache[:complex_assertion].has_key?(index)
      cached = node_cache[:complex_assertion][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if has_terminal?("Header", false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 6))
      @index += 6
    else
      terminal_parse_failure("Header")
      r1 = nil
    end
    s0 << r1
    if r1
      r2 = _nt_space
      s0 << r2
      if r2
        r3 = _nt_identifier
        s0 << r3
        if r3
          r4 = _nt_space
          s0 << r4
          if r4
            i5 = index
            if has_terminal?("should contain", false, index)
              r6 = instantiate_node(SyntaxNode,input, index...(index + 14))
              @index += 14
            else
              terminal_parse_failure("should contain")
              r6 = nil
            end
            if r6
              r5 = r6
            else
              if has_terminal?("should not contain", false, index)
                r7 = instantiate_node(SyntaxNode,input, index...(index + 18))
                @index += 18
              else
                terminal_parse_failure("should not contain")
                r7 = nil
              end
              if r7
                r5 = r7
              else
                @index = i5
                r5 = nil
              end
            end
            s0 << r5
          end
        end
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(ComplexAssertion0)
      r0.extend(ComplexAssertion1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:complex_assertion][start_index] = r0

    r0
  end

  def _nt_parameter
    start_index = index
    if node_cache[:parameter].has_key?(index)
      cached = node_cache[:parameter][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0 = index
    r1 = _nt_escaped_value
    if r1
      r0 = r1
    else
      r2 = _nt_name
      if r2
        r0 = r2
      else
        r3 = _nt_regex
        if r3
          r0 = r3
        else
          r4 = _nt_value
          if r4
            r0 = r4
          else
            @index = i0
            r0 = nil
          end
        end
      end
    end

    node_cache[:parameter][start_index] = r0

    r0
  end

  def _nt_newline
    start_index = index
    if node_cache[:newline].has_key?(index)
      cached = node_cache[:newline][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    s0, i0 = [], index
    loop do
      if has_terminal?('\G[\\r\\n]', true, index)
        r1 = true
        @index += 1
      else
        r1 = nil
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    if s0.empty?
      @index = i0
      r0 = nil
    else
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
    end

    node_cache[:newline][start_index] = r0

    r0
  end

  def _nt_value
    start_index = index
    if node_cache[:value].has_key?(index)
      cached = node_cache[:value][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    s0, i0 = [], index
    loop do
      if has_terminal?('\G[^\\n]', true, index)
        r1 = true
        @index += 1
      else
        r1 = nil
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    r0 = instantiate_node(SyntaxNode,input, i0...index, s0)

    node_cache[:value][start_index] = r0

    r0
  end

  module Data0
  end

  module Data1
    def process
      text_value[1..-2]
    end
  end

  def _nt_data
    start_index = index
    if node_cache[:data].has_key?(index)
      cached = node_cache[:data][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if has_terminal?('"', false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure('"')
      r1 = nil
    end
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        if has_terminal?('\G[^"]', true, index)
          r3 = true
          @index += 1
        else
          r3 = nil
        end
        if r3
          s2 << r3
        else
          break
        end
      end
      if s2.empty?
        @index = i2
        r2 = nil
      else
        r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
      end
      s0 << r2
      if r2
        if has_terminal?('"', false, index)
          r4 = instantiate_node(SyntaxNode,input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure('"')
          r4 = nil
        end
        s0 << r4
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Data0)
      r0.extend(Data1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:data][start_index] = r0

    r0
  end

  module Regex0
  end

  def _nt_regex
    start_index = index
    if node_cache[:regex].has_key?(index)
      cached = node_cache[:regex][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if has_terminal?('/', false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure('/')
      r1 = nil
    end
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        if has_terminal?('\G[^\\/]', true, index)
          r3 = true
          @index += 1
        else
          r3 = nil
        end
        if r3
          s2 << r3
        else
          break
        end
      end
      if s2.empty?
        @index = i2
        r2 = nil
      else
        r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
      end
      s0 << r2
      if r2
        if has_terminal?('/', false, index)
          r4 = instantiate_node(SyntaxNode,input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure('/')
          r4 = nil
        end
        s0 << r4
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Regex0)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:regex][start_index] = r0

    r0
  end

  module Comment0
    def space
      elements[0]
    end

  end

  def _nt_comment
    start_index = index
    if node_cache[:comment].has_key?(index)
      cached = node_cache[:comment][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_space
    s0 << r1
    if r1
      if has_terminal?('#', false, index)
        r2 = instantiate_node(SyntaxNode,input, index...(index + 1))
        @index += 1
      else
        terminal_parse_failure('#')
        r2 = nil
      end
      s0 << r2
      if r2
        s3, i3 = [], index
        loop do
          if has_terminal?('\G[^\\n]', true, index)
            r4 = true
            @index += 1
          else
            r4 = nil
          end
          if r4
            s3 << r4
          else
            break
          end
        end
        r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
        s0 << r3
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Comment0)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:comment][start_index] = r0

    r0
  end

  module EscapedValue0
  end

  def _nt_escaped_value
    start_index = index
    if node_cache[:escaped_value].has_key?(index)
      cached = node_cache[:escaped_value][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if has_terminal?('::', false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 2))
      @index += 2
    else
      terminal_parse_failure('::')
      r1 = nil
    end
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        if has_terminal?('\G[^\\n]', true, index)
          r3 = true
          @index += 1
        else
          r3 = nil
        end
        if r3
          s2 << r3
        else
          break
        end
      end
      r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
      s0 << r2
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(EscapedValue0)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:escaped_value][start_index] = r0

    r0
  end

  module Name0
    def identifier
      elements[1]
    end
  end

  def _nt_name
    start_index = index
    if node_cache[:name].has_key?(index)
      cached = node_cache[:name][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if has_terminal?(':', false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure(':')
      r1 = nil
    end
    s0 << r1
    if r1
      r2 = _nt_identifier
      s0 << r2
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Name0)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:name][start_index] = r0

    r0
  end

  def _nt_identifier
    start_index = index
    if node_cache[:identifier].has_key?(index)
      cached = node_cache[:identifier][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    s0, i0 = [], index
    loop do
      if has_terminal?('\G[a-zA-Z0-9_-]', true, index)
        r1 = true
        @index += 1
      else
        r1 = nil
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    if s0.empty?
      @index = i0
      r0 = nil
    else
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
    end

    node_cache[:identifier][start_index] = r0

    r0
  end

  module Url0
  end

  module Url1
  end

  def _nt_url
    start_index = index
    if node_cache[:url].has_key?(index)
      cached = node_cache[:url][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    i1 = index
    if has_terminal?('http://', false, index)
      r2 = instantiate_node(SyntaxNode,input, index...(index + 7))
      @index += 7
    else
      terminal_parse_failure('http://')
      r2 = nil
    end
    if r2
      r1 = r2
    else
      if has_terminal?('https://', false, index)
        r3 = instantiate_node(SyntaxNode,input, index...(index + 8))
        @index += 8
      else
        terminal_parse_failure('https://')
        r3 = nil
      end
      if r3
        r1 = r3
      else
        @index = i1
        r1 = nil
      end
    end
    s0 << r1
    if r1
      i4, s4 = index, []
      s5, i5 = [], index
      loop do
        if has_terminal?('\G[a-zA-Z0-9]', true, index)
          r6 = true
          @index += 1
        else
          r6 = nil
        end
        if r6
          s5 << r6
        else
          break
        end
      end
      if s5.empty?
        @index = i5
        r5 = nil
      else
        r5 = instantiate_node(SyntaxNode,input, i5...index, s5)
      end
      s4 << r5
      if r5
        s7, i7 = [], index
        loop do
          if has_terminal?('\G[^\\n\\s]', true, index)
            r8 = true
            @index += 1
          else
            r8 = nil
          end
          if r8
            s7 << r8
          else
            break
          end
        end
        if s7.empty?
          @index = i7
          r7 = nil
        else
          r7 = instantiate_node(SyntaxNode,input, i7...index, s7)
        end
        s4 << r7
      end
      if s4.last
        r4 = instantiate_node(SyntaxNode,input, i4...index, s4)
        r4.extend(Url0)
      else
        @index = i4
        r4 = nil
      end
      s0 << r4
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Url1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:url][start_index] = r0

    r0
  end

  def _nt_space
    start_index = index
    if node_cache[:space].has_key?(index)
      cached = node_cache[:space][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    s0, i0 = [], index
    loop do
      if has_terminal?('\G[\\s\\t]', true, index)
        r1 = true
        @index += 1
      else
        r1 = nil
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    r0 = instantiate_node(SyntaxNode,input, i0...index, s0)

    node_cache[:space][start_index] = r0

    r0
  end

end

class TesterGrammarParser < Treetop::Runtime::CompiledParser
  include TesterGrammar
end


