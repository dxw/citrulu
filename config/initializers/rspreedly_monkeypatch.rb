module RSpreedly

  class Subscriber < Base

    def update_attributes(attrs)
      self.attributes= attrs
      update
    end
  
  end
  
end