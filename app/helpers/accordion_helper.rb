module AccordionHelper
  
  # Creates a TwitterBootstrap accordion form: http://twitter.github.com/bootstrap/javascript.html#collapse 
  def accordion(accordion_id, &block) 
    content_tag :ul, :class => "unstyled accordion", :id => accordion_id, &block
  end
  
  def accordion_group(accordion_id, heading, heading_content_tag, default_open, &block)
    group_id = "##{heading.downcase.gsub(/\s+/, '_')}"
    
    heading = content_tag :heading, :class => "accordion-heading" do 
                content_tag heading_content_tag, heading, :class => "accordion-toggle", 
                  "data-parent" => "##{accordion_id}",
                  "data-target"=> group_id,
                  "data-toggle" => "collapse"
              end
    
    body =  content_tag :div, :class => "accordion-body collapse#{" in" if default_open}", :id => group_id do
              content_tag :section, :class => "accordion-inner", &block 
            end

    content_tag :li, :class => "accordion-group" do
      heading << body
    end
  end
end