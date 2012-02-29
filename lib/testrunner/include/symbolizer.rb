class String
  def to_test_sym
    self.strip.gsub(/should /, '').gsub(/\s+/, '_').downcase.to_sym
  end
end

class Symbol
  def to_test_s
    self.to_s.sub(/_/," should ").gsub(/_/, ' ').capitalize
  end
end