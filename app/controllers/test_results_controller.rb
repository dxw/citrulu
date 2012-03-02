class TestResultsController < ApplicationController
  # GET /test_results
  # GET /test_results.json
  def index
    @test_results = TestResult.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @test_results }
    end
  end

  # GET /test_results/1
  # GET /test_results/1.json
  def show
    @test_result = TestResult.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @test_result }
    end
  end

  # GET /test_results/new
  # GET /test_results/new.json
  def new
    @test_result = TestResult.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @test_result }
    end
  end

  # GET /test_results/1/edit
  def edit
    @test_result = TestResult.find(params[:id])
  end

  # POST /test_results
  # POST /test_results.json
  def create
    @test_result = TestResult.new(params[:test_result])

    respond_to do |format|
      if @test_result.save
        format.html { redirect_to @test_result, notice: 'Test result was successfully created.' }
        format.json { render json: @test_result, status: :created, location: @test_result }
      else
        format.html { render action: "new" }
        format.json { render json: @test_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /test_results/1
  # PUT /test_results/1.json
  def update
    @test_result = TestResult.find(params[:id])

    respond_to do |format|
      if @test_result.update_attributes(params[:test_result])
        format.html { redirect_to @test_result, notice: 'Test result was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @test_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /test_results/1
  # DELETE /test_results/1.json
  def destroy
    @test_result = TestResult.find(params[:id])
    @test_result.destroy

    respond_to do |format|
      format.html { redirect_to test_results_url }
      format.json { head :ok }
    end
  end
end
