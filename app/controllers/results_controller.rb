class ResultsController < ApplicationController
  layout "logged_in"
  
  before_filter :authenticate_user!
  
  
  DUMMY_TEST_RESULT = %{7) ResultsController POST create with valid params assigns a newly created result as @result
   Failure/Error: assigns(:result).should be_a(Result)
     expected nil to be a kind of Result(Table doesn't exist)
   # ./spec/controllers/results_controller_spec.rb:78:in `block (4 levels) in <top (required)>'

8) ResultsController POST create with valid params redirects to the created result
   Failure/Error: response.should redirect_to(Result.last)
   ActiveRecord::StatementInvalid:
     Could not find table 'results'
   # ./spec/controllers/results_controller_spec.rb:84:in `block (4 levels) in <top (required)>'

9) ResultsController POST create with invalid params assigns a newly created but unsaved result as @result
   Failure/Error: assigns(:result).should be_a_new(Result)
     expected nil to be a new Result(Table doesn't exist)
   # ./spec/controllers/results_controller_spec.rb:93:in `block (4 levels) in <top (required)>'

10) ResultsController POST create with invalid params re-renders the 'new' template
   Failure/Error: response.should render_template("new")
     expecting <"new"> but rendering with <"">
   # ./spec/controllers/results_controller_spec.rb:100:in `block (4 levels) in <top (required)>'

11) ResultsController PUT update with valid params updates the requested result
   Failure/Error: result = Result.create! valid_attributes
   ActiveRecord::StatementInvalid:
     Could not find table 'results'
   # ./spec/controllers/results_controller_spec.rb:108:in `block (4 levels) in <top (required)>'

12) ResultsController PUT update with valid params assigns the requested result as @result
   Failure/Error: result = Result.create! valid_attributes
   ActiveRecord::StatementInvalid:
     Could not find table 'results'
   # ./spec/controllers/results_controller_spec.rb:118:in `block (4 levels) in <top (required)>'

13) ResultsController PUT update with valid params redirects to the result
   Failure/Error: result = Result.create! valid_attributes
   ActiveRecord::StatementInvalid:
     Could not find table 'results'
   # ./spec/controllers/results_controller_spec.rb:124:in `block (4 levels) in <top (required)>'

14) ResultsController PUT update with invalid params assigns the result as @result
   Failure/Error: result = Result.create! valid_attributes
   ActiveRecord::StatementInvalid:
     Could not find table 'results'
   # ./spec/controllers/results_controller_spec.rb:132:in `block (4 levels) in <top (required)>'

15) ResultsController PUT update with invalid params re-renders the 'edit' template
   Failure/Error: result = Result.create! valid_attributes
   ActiveRecord::StatementInvalid:
     Could not find table 'results'
   # ./spec/controllers/results_controller_spec.rb:140:in `block (4 levels) in <top (required)>'

16) ResultsController DELETE destroy destroys the requested result
}
  
  
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
      @results << Result.new(:id => offset, :time_run => Time.now - offset, :result => DUMMY_TEST_RESULT)
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
