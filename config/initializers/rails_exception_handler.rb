RailsExceptionHandler.configure do |config|
   config.environments = [:production, :development]
   config.filters = [
     :anon_404s,
  ]
end
