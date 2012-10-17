ActiveAdmin.register Response do
  filter :test_group_id, :as => :numeric, :label => "Test Group ID"
  filter :test_file_id, :as => :numeric, :label => "Test File ID"
  filter :owner_email, :as => :string
  filter :response_time
  filter :headers
  filter :code
  
  index do
    column "User's Email" do |response|
      response.owner.email
    end
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
