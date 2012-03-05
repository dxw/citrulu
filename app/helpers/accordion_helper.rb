# Creates a TwitterBootstrap accordion form: http://twitter.github.com/bootstrap/javascript.html#collapse 
module AccordionHelper
  
  # Creates the enclosing accordion element and sets an instance variable containing values relevant to the accordion
  def accordion(accordion_id, accordion_header_content_tag=:div, &block) 
    @accordion = AccordionRenderer.new(self,accordion_id, accordion_header_content_tag)
    @accordion.accordion &block
  end
  
  # Creates the element enclosing one row of the accordion and sets an instance variable containing values relevant to that row
  def accordion_group(group_id, default_open=false, &block)
    @group = @accordion.group(group_id, default_open)
    @group.accordion_group &block
  end
  
  def accordion_heading(options=nil, &block)
    @group.accordion_heading(options, &block)
  end
  
  def accordion_body(&block)
    @group.accordion_body &block
  end
  
  private
  
  # http://railscasts.com/episodes/101-refactoring-out-helper-object

  # Contains attributes relevant to the whole Accordion
  class AccordionRenderer
    def initialize(template, accordion_id, accordion_heading_content_tag=:div)
      @accordion_id = accordion_id
      @accordion_heading_content_tag = accordion_heading_content_tag
      @template = template # so that we can use the view helpers
    end

    # Creates the Accordion element (a ul)
    def accordion(&block) 
      @template.content_tag :ul, :class => "unstyled accordion", :id => @accordion_id, &block
    end

    def group(group_id, default_open=false)
      AccordionGroupRenderer.new(@template, @accordion_id, @accordion_heading_content_tag, group_id, default_open )
    end
  end  
  
  # Contains attributes relevant to a single row in the accordion
  class AccordionGroupRenderer
    def initialize(template, accordion_id, accordion_heading_content_tag, group_id, default_open )
      @accordion_id = accordion_id
      @accordion_heading_content_tag = accordion_heading_content_tag
      @template = template
      @group_id = group_id
      @default_open = default_open
    end

    # Enclosing element for an accordion row
    def accordion_group(&block)
      @template.content_tag :li, :class => "accordion-group", &block
    end
    
    # The heading comprises a "toggle" element which actually enables the accordion functionality,
    # enclosed within a heading element which doesn't seem to have a purpose, but is required to make the 
    # Twitter Bootstrap styles work.
    def accordion_heading(opts = nil, &block)
      # passing in "opts" allows us to set a class on the header from outside.
      options = {:class => "accordion-heading"}
      options = options.merge(opts){|k, x, y| [x,y].join(" ") if k == :class} unless opts.nil?
      
      @template.content_tag :header, options do 
        # The toggle references both the corresponding body element (data-target) 
        # and the whole accordion element (data-parent)
        @template.content_tag @accordion_heading_content_tag, :class => "accordion-toggle", 
          "data-parent" => "##{@accordion_id}",
          "data-target"=>  "##{@group_id}",
          "data-toggle" => "collapse",
          &block
      end
    end

    # The body comprises a body element which is hidden or expanded (and can be set to be either as a default with @default_open)
    # and an inner element which sees to be just for styling
    def accordion_body(&block)
      @template.content_tag :div, :class => "accordion-body collapse#{" in" if @default_open}", :id => @group_id do
        @template.content_tag :section, :class => "accordion-inner", &block 
      end
    end
  end
end
