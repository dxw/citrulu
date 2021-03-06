ActiveAdmin.register TestFile do
  filter :id, :as => :numeric
  filter :run_tests, :as => :select, :label => "Set to Run"
  filter :user_email, :as => :string
  filter :frequency
  filter :created_at
  filter :updated_at
  filter :test_file_text
  filter :compiled_test_file_text
  filter :search_test_file_text
  filter :domains
  
  index do
    column :id
    column :name
    column :test_file_text do |file|
      truncate(file.test_file_text)
    end
    # column :compiled_test_file_text do |file|
    #   div truncate(file.compiled_test_file_text)
    # end
    column "Set to Run", :run_tests
    column "Owner's email" do |file| 
      file.user.email
    end
    column :created_at
    column :updated_at
    default_actions
  end
  show do
    h2 "#{test_file.name} (##{test_file.id})"
    para link_to test_file.user.name, admin_user_path(test_file.user)
    h3 "Test File text:"
    div do
      simple_format test_file.test_file_text
    end
    
    attributes_table do
      row :created_at
      row :updated_at
      row :deleted
      row :run_tests
      row :tutorial? do
        !test_file.tutorial_id.nil?
      end
      row :frequency
    end
    
    
    h4 "Compiled text:"
    div do  
      simple_format test_file.compiled_test_file_text
    end  
  end
end
