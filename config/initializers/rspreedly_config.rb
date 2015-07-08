# Cornichon ID = 18462 
# Gherkin ID = 18464

RSpreedly::Config.setup do |config|
  
  if Rails.env == 'production'
    config.api_key    = "XXXXX"
    config.site_name  = "Citrulu"
  else
    config.api_key        = "XXXXXX"
    config.site_name      = "dgmstuart-test"
  end
end
