class Predefs
  class PredefNotFoundError < StandardError
  end

  def self.predefs 
    {
      :php_errors => [
        'PHP Error',
        'PHP Warning',
        'PHP Notice',
        'PHP Fatal'
      ]
    }
  end

  def self.find(name)
    
    name.gsub!(/^:/, '')

    if predefs[name.to_sym].blank?
      raise PredefNotFoundError.new("Predef #{name} not found")
    end

    predefs[name]
  end

  def self.all
    predefs
  end
end

