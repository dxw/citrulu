module ApplicationHelper
  def controller_name
    params[:controller].split("/").join(" ") if params[:controller]
  end
  
  def nav_link(text, path)
    if path == request.fullpath # gives the current uri after the first slash
      content_tag :li, :class => "active" do 
        #EWW! EWW! Bootstrap styles force you to render the current nav as a link instead of text
        link_to text
      end
    else
      content_tag :li do 
        link_to text, path
      end
    end
  end

  def truncated_test_url(url)
    text = url.gsub('http://', '').gsub('https://', '')

    if text.length > 32
      text = text[0..7] + "\u22EF" + text[((text.length/2)-4),8] + "\u22EF" + text[-8,7]
    end

    link_to(text, url, :target => '_blank')
  end

  def unimplemented_popover
    {
      "data-content" => "Sorry, this isn't implemented yet. We'll get to it when we can. If you have a burning need for it, please let us know using the feedback tab!",
      "data-original-title" => "Not implemented yet"
    }
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
