ActiveAdmin.register TestFile do
  index do
    column :name
    column :test_file_text do |file|
      div truncate(file.test_file_text)
    end
    column :compiled_test_file_text do |file|
      div truncate(file.compiled_test_file_text)
    end
    column :run_tests
    column :created_at
    column :updated_at
    default_actions
  end
end
