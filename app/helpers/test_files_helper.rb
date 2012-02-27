module TestFilesHelper
  
  # a line to be displayed in the console element
  def console_line(content, status = "neutral")
    line_items = []
    # line_items << content_tag(:span, "[#{Time.now}]", :class => "date")
    line_items << "[#{Time.now}] "
    line_items << content_tag(:span, content, :class => status)
    content_tag :p, :escape => false do
      # line_items.join(" ")
      line_items.collect {|item| concat(item)}
    end
  end
  
  # # the message to be displayed when the file is saving
  # def editor_status_message(content)
  #   content_tag :div, content
  # end  
end
