class ResultsController < ApplicationController
  layout "logged_in"
  
  before_filter :authenticate_user!
  
  # GET /results
  # GET /results.json
  def index
    #for now, just return the (single) test file associated with the current logged-in user
    test_file = current_user.test_files[0]
    
    # @results = test_file.results
    
##TEMPORARY CODE
    @results = []
    offset = 0
    while @results.length < 10
      offset += rand(100)
      
      
      result_object = []
      number_of_pages = rand(3) + 5
      while result_object.length < number_of_pages
        steps = []
        number_of_steps = rand(3) + 3
        while steps.length < number_of_steps
          step = "This is a result" 
          steps << step
        end
        result_object << ["http://thisisapage#{Time.now.to_i}", steps]
      end
      
      @results << Result.new(:id => offset, :time_run => Time.now - offset, :result => result_object)
    end
##END TEMPORARY CODE

    respond_to do |format|
      format.html # index.html.erb
      # format.json { render json: @results }
    end
  end

  # GET /results/1
  # GET /results/1.json
  def show
    @result = Result.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @result }
    end
  end

  # GET /results/new
  # GET /results/new.json
  def new
    @result = Result.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @result }
    end
  end

  # GET /results/1/edit
  def edit
    @result = Result.find(params[:id])
  end

  # POST /results
  # POST /results.json
  def create
    @result = Result.new(params[:result])

    respond_to do |format|
      if @result.save
        format.html { redirect_to @result, notice: 'Result was successfully created.' }
        format.json { render json: @result, status: :created, location: @result }
      else
        format.html { render action: "new" }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /results/1
  # PUT /results/1.json
  def update
    @result = Result.find(params[:id])

    respond_to do |format|
      if @result.update_attributes(params[:result])
        format.html { redirect_to @result, notice: 'Result was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /results/1
  # DELETE /results/1.json
  def destroy
    @result = Result.find(params[:id])
    @result.destroy

    respond_to do |format|
      format.html { redirect_to results_url }
      format.json { head :ok }
    end
  end
end
