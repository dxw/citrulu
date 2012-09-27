module WebsiteHelper
  def often_ness(frequency)
    case frequency*100
    when 0
      'never'
    when 0..5
      'very rarely'
    when 5..45
      'occasionally'
    when 45..55
      'about half the time'
    when 55..95
      'quite often'
    when 100
      'every time it is run'
    when 95..100
      'all the time'
    end
  end
end
