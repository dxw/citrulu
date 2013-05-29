ActiveAdmin.register TestGroup do
  filter :id, :as => :numeric
  filter :test_url
  filter :message
  filter :test_run_id, :as => :numeric
  filter :time_run
  filter :created_at
  filter :updated_at
 
  index do
    column :time_run
    column :so
    column :test_url
    column :method

    column :message do |group|
      truncate(group.message) unless group.message.nil?
    end

    column :data do |group|
      truncate(group.data) unless group.data.nil?
    end

    # column :test_run do |group|
    #       "#{group.test_run.test_file.name} / #{group.test_run.time_run}"
    #     end
  
    column :created_at
    column :updated_at

    default_actions
  end
end
