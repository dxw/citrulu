# Autogenerated from a Treetop grammar. Edits may be lost.


module TesterGrammar
  include Treetop::Runtime

  def root
    @root ||= :test_file
  end

  module TestFile0
    def process
      elements.collect{|e| e.process}
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

    s0, i0 = [], index
    loop do
      r1 = _nt_test_group
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
      r0.extend(TestFile0)
    end

    node_cache[:test_file][start_index] = r0

    r0
  end

  module TestGroup0
    def on_clause
      elements[0]
    end

  end

  module TestGroup1
    def process
      {
        :test_url => on_clause.url.text_value, 
        :tests => elements[1].elements.collect{|e| e.process}
      }
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
    r1 = _nt_on_clause
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        r3 = _nt_test
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

  module OnClause0
    def url
      elements[1]
    end

    def newline
      elements[2]
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
    if has_terminal?("On ", false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 3))
      @index += 3
    else
      terminal_parse_failure("On ")
      r1 = nil
    end
    s0 << r1
    if r1
      r2 = _nt_url
      s0 << r2
      if r2
        r3 = _nt_newline
        s0 << r3
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(OnClause0)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:on_clause][start_index] = r0

    r0
  end

  module Test0
    def space1
      elements[0]
    end

    def assertion
      elements[1]
    end

    def space2
      elements[2]
    end

    def value
      elements[3]
    end

    def newline
      elements[4]
    end
  end

  module Test1
    def process
      {
        :assertion => assertion.text_value.strip.gsub(/should /, '').gsub(/\s+/, '_').downcase.to_sym,
        :value => value.text_value
      }
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
    r1 = _nt_space
    s0 << r1
    if r1
      r2 = _nt_assertion
      s0 << r2
      if r2
        r3 = _nt_space
        s0 << r3
        if r3
          r4 = _nt_value
          s0 << r4
          if r4
            r5 = _nt_newline
            s0 << r5
          end
        end
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

  def _nt_assertion
    start_index = index
    if node_cache[:assertion].has_key?(index)
      cached = node_cache[:assertion][index]
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
              else
                @index = i0
                r0 = nil
              end
            end
          end
        end
      end
    end

    node_cache[:assertion][start_index] = r0

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
      if has_terminal?('\G[\\n]', true, index)
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
    if s0.empty?
      @index = i0
      r0 = nil
    else
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
    end

    node_cache[:value][start_index] = r0

    r0
  end

  module Url0
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
      s4, i4 = [], index
      loop do
        if has_terminal?('\G[^\\n]', true, index)
          r5 = true
          @index += 1
        else
          r5 = nil
        end
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
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Url0)
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


