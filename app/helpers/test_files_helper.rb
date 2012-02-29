module TestFilesHelper
  
  # a line to be displayed in the console element
  def console_line(content, status = "neutral")
    line_items = []
    
    line_items << "[#{Time.now.to_s(:db)}] "
    line_items << content_tag(:span, content, :class => status)

    content_tag :p, :escape => false do
      line_items.collect {|item| concat(item)}
    end
  end
end
