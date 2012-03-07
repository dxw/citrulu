class TestRunsController < ApplicationController
  
  layout "logged_in"
  
  before_filter :authenticate_user!
  before_filter :check_ownership!, :only => [:show]
  
  # GET /test_runs
  # GET /test_runs.json
  def index
    #for now, just return the (single) test file associated with the current logged-in user
    test_file = current_user.test_files[0]
    @test_runs = test_file.test_runs

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
