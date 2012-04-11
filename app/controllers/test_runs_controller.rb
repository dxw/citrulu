class TestRunsController < ApplicationController
  
  layout "logged_in"
  
  before_filter :authenticate_user!
  before_filter :check_ownership!, :only => [:show]
  
  # GET /test_runs
  # GET /test_runs.json
  def index
    @test_files = current_user.test_files
    @test_runs = @test_files.collect{|f| f.test_runs}.flatten.sort{|a,b| b.time_run <=> a.time_run}

    @recent_failed_groups = @test_files.collect{|t| t.last_run.groups_with_failures unless t.last_run.nil?}.flatten.compact
    
    @recent_failed_pages = @test_files.collect{|t| t.last_run.number_of_failed_groups unless t.last_run.nil?}.flatten.compact.sum
    @recent_failed_assertions = @test_files.collect{|t| t.last_run.number_of_failed_tests unless t.last_run.nil?}.flatten.compact.sum

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
    check_ownership(params[:id], TestRun) do
      flash[:error] = "You tried to access a test run which doesn't exist!"
      redirect_to test_runs_path
    end
  end
end
