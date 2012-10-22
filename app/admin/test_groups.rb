ActiveAdmin.register TestGroup do
  index do
    column :time_run
    column :so
    column :test_url
    column :method

    column :message do |file|
      truncate(file.message)
    end

    column :data do |group|
      truncate(group.data)
    end

    column :test_run do |group|
      "#{group.test_run.test_file.name} / #{group.test_run.time_run}"
    end
  
    column :created_at
    column :updated_at

    default_actions
  end
end
