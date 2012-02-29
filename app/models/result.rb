class Result < ActiveRecord::Base
  require 'psych'
  
  belongs_to :test_file
  
  # parse the YAML which is stored in the database...
  def result_object
    Psych.load(result)
  end
  
  #TODO should be in the helper? Didn't put it there initially on the assumption that this is useful in logic as well...
  def result_status
    if failures > 0
      "alert-error"
    else
      "alert-success"
    end
    # These are twitter bootstrap class names. I tried to define my own classes inheriting from these, but couldn't get it to work...
  end
  
  def failures
    # Simulate random successes and failures:
    
    unless time_run.to_i.modulo(5)==0
      0
    else
      rand(20) + 1
    end
  end
end
