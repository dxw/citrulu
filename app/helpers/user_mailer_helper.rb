module UserMailerHelper
  include TestRunsHelper
  
  def failed_groups_header
    "The following #{pluralize(@test_run.number_of_failed_groups, 'page')} could not be retrieved because of errors:"
  end
  
  
  def content_p_styles
    "line-height: 16px; margin: 0 0 10px 0;"
  end
  
  def content_a_styles
    ""
  end
  
  # Buttons are a td with a background colour and coloured borders, containing a link 
  def content_button_td_styles
    "padding: 5px 10px; background: #08C; border: 1px solid #002A80; border-color: #3CF #002A80 #002A80 #3CF;"
  end
  def content_button_a_styles  
    "display: block; text-decoration: none; color: #fff!important; font-weight: bold; font-size: 20px!important; white-space:nowrap;"
  end
  
  def content_pre_styles
    "font-size:0.9em; margin-left:15px; padding: 2px 5px; background: #fff; border:1px solid #000; -webkit-border-radius: 3px; -moz-border-radius-topright: 3px; border-radius: 3px;"
  end  
  
  # Not currently used
  def content_hn_styles 
    "font-size: 18px; font-weight: bold; margin: 10px 0 3px 0;"
  end

  def footer_a_styles
    "color:#fff;"
  end
    
end