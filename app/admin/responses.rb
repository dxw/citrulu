ActiveAdmin.register Response do
  index do
    column :code
    column :response_time
    column :headers do |response|
      div truncate(response.headers)
    end
    column :content do |response|
      div truncate(response.content)
    end
    column :created_at
    column :updated_at
    default_actions
  end
end
