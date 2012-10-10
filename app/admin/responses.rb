ActiveAdmin.register Response do
  index do
    column :code
    column :response_time do |response|
      "#{response.response_time}ms"
    end
    column :headers do |response|
      div truncate(response.headers)
    end
    column :content do |response|
      div truncate(response.content)
    end
    default_actions
  end
end
