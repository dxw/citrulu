class Result < ActiveRecord::Base
  belongs_to :test_file
  
  def result_status
    # Simulate random successes and failures:
    if rand(5) == 0
      "alert-error"
    else
      "alert-success"
    end
    # These are twitter bootstrap class names. I tried to define my own classes inheriting from these, but couldn't get it to work...
    
  end
end
