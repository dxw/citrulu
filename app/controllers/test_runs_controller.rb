class TestRunsController < ApplicationController
  
  layout "logged_in"
  
  before_filter :authenticate_user!
  
  # GET /test_runs
  # GET /test_runs.json
  def index
    #for now, just return the (single) test file associated with the current logged-in user
    # test_file = current_user.test_files[0]
    # @test_runs = test_file.test_runs
    
##TEMPORARY CODE
    @test_runs = []
    offset = 0
    while @test_runs.length < 10      
      @test_runs << TestRun.new(:id => offset, :time_run => Time.new(2012,03,20) +offset.hours)
      offset += 1
    end
##END TEMPORARY CODE

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

  # GET /test_runs/new
  # GET /test_runs/new.json
  def new
    @test_run = TestRun.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @test_run }
    end
  end

  # GET /test_runs/1/edit
  def edit
    @test_run = TestRun.find(params[:id])
  end

  # POST /test_runs
  # POST /test_runs.json
  def create
    @test_run = TestRun.new(params[:test_run])

    respond_to do |format|
      if @test_run.save
        format.html { redirect_to @test_run, notice: 'Test run was successfully created.' }
        format.json { render json: @test_run, status: :created, location: @test_run }
      else
        format.html { render action: "new" }
        format.json { render json: @test_run.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /test_runs/1
  # PUT /test_runs/1.json
  def update
    @test_run = TestRun.find(params[:id])

    respond_to do |format|
      if @test_run.update_attributes(params[:test_run])
        format.html { redirect_to @test_run, notice: 'Test run was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @test_run.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /test_runs/1
  # DELETE /test_runs/1.json
  def destroy
    @test_run = TestRun.find(params[:id])
    @test_run.destroy

    respond_to do |format|
      format.html { redirect_to test_runs_url }
      format.json { head :ok }
    end
  end
end
