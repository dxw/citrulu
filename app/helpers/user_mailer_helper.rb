module UserMailerHelper
  include TestRunsHelper
  
  def failed_groups_header
    "The following #{pluralize(@test_run.number_of_failed_groups, 'page')} could not be retrieved because of errors:"
  end
end
