module ApplicationHelper
  def controller_name
    params[:controller].split("/")[0]
  end
  
  def nav_link(text, controller)
    if params[:controller] == controller
      content_tag :li do 
        #EWW! EWW! Bootstrap styles force you to render the current nav as a link instead of text
        link_to text
      end
    else
      content_tag :li, :class => "active" do 
        link_to text, :controller => controller
      end
    end
  end
  
  def flash_message(name, message)
    cl = 'alert'
    case name
      when :alert
        cl += " alert-error"
      when :notice then 
        cl += " alert-success"
    end
    
    content_tag :div, message, :class => cl
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
