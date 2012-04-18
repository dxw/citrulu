# Monkey Patch to address the fact that the Spreedly API is broken (sometimes returns messages with a content-type of text/xml, but a body containing only plain text), and RSpreedly doesn't handle it.

module HTTParty
  class Request
    def parse_response(body)
      if format == :xml && !body.match(/^</)       
        # It's not actually xml! 
        parser.call(body, :plain)
      else
        parser.call(body, format)
      end
    end
  end
end