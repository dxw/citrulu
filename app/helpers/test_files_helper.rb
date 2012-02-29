module TestFilesHelper
  
  # a line to be displayed in the console element
  def console_line(content_hash, status = "neutral")
    line_items = []
    

    content_hash.each do |item, content|
      if !item.match(/^text/)
        line_items << content_tag(:span, content, :class => item) 
      else
        line_items << content
      end
    end

    content_tag :div do
      content_tag(:p, "[#{Time.now.to_s(:db)}] ", :class => 'timestamp') +
      content_tag(:p, :escape => false, :class => status) do
        line_items.collect {|item| concat(item)}
      end
    end
  end
end
