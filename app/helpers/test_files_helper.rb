module TestFilesHelper
  
  # a line to be displayed in the console element
  def console_line(content_hash, status = "neutral", timestamp = true)
    line_items = []

    line_items << content_tag(:span, "[#{Time.now.to_s(:db)}] ", :class => 'timestamp' ) if timestamp

    content_hash.each do |item, content|
      if !item.match(/^text/)
        item = item.to_s.gsub!(/\d+$/, '')
        line_items << content_tag(:span, content, :class => item) 
      else
        line_items << content
      end
    end

    content_tag(:div) do
      content_tag(:p, :class => status) do
        line_items.collect {|item| concat(item)}
      end
    end
  end
end
