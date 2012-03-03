module TestRunsHelper
  require 'grammar/symbolizer'
  
  def test_class(test_hash)
    "passed_#{test_hash[:passed]}"
  end
  
  def test_text(test_hash)
    text = "#{test_hash[:assertion].to_test_s} \"#{test_hash[:value]}\""
  end
  
end
