ActiveAdmin.register TestGroup do
  index do
    column :time_run
    column :so
    column :test_url
    column :method

    column :message do |file|
      div truncate(file.message)
    end

    column :data do |group|
      div truncate(group.data)
    end

    column :test_run do |group|
      div "#{group.test_run.test_file.name} / #{group.test_run.time_run}"
    end
  
    column :created_at
    column :updated_at

    default_actions
  end
end