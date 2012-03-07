class TestRunsController < ApplicationController
  
  layout "logged_in"
  
  before_filter :authenticate_user!
  before_filter :check_ownership!, :only => [:show]
  
  # GET /test_runs
  # GET /test_runs.json
  def index
    @test_files = current_user.test_files
    @recent_failed_groups = current_user.test_files.collect{|t| t.last_run}.select{|r| r.number_of_failures != 0}.collect{|r| r.test_groups.select{|g| g.number_of_failures != 0}}[0]
    
    respond_to do |format|
      format.html # index.html.erb
      # format.json { render json: @test_runs }
    end
  end

  # GET /test_runs/1
  # GET /test_runs/1.json
  def show
    @test_run = TestRun.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @test_run }
    end
  end
  
  protected
  
  # If the user tries to access a test run that they don't own or doesn't exist, return them to the index page
  def check_ownership!
    # If :id is numeric, assume it's an ID, otherwise let the page return a 404
    return if params[:id].to_i == 0
    begin  
      raise ActiveRecord::RecordNotFound unless TestRun.find(params[:id]).test_file.user_id == current_user.id
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "You tried to access a test run which doesn't exist!"
      redirect_to test_runs_path
    end
  end
end
