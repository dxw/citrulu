Dir[Rails.root.join('lib', 'jobs', '*.rb')].each do |f|
  require f
end
