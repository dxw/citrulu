RailsExceptionHandler.configure do |config|
   config.environments = [:production]
   config.filters = [
     :anon_404s,
  ]
end
