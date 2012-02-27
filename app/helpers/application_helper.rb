module ApplicationHelper
  
  def flash_message(name, message)
    cl = 'alert'
    case name
      when :alert
        cl += ' alert-error'
      when :notice then 
        cl += ' alert-success'
    end
    
    #TODO - this is a horrible way of doing this! Need to do this to make sure it can be safely passed to js  
    "<div class='#{cl}'>#{message}</div>"  
    # content_tag :div, message, :class => cl
  end
  
  # See here: https://github.com/plataformatec/devise/wiki/How-To:-Display-a-custom-sign_in-form-anywhere-in-your-app
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
  
end
