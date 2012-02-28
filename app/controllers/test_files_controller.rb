class TestFilesController < ApplicationController
  
  before_filter :authenticate_user!
  
  # GET /test_files
  # GET /test_files.json
  def index
    @test_file = current_user.test_file

    # redirect_to @test_file
    redirect_to edit_test_file_path(@test_file)
    
    
    # @test_files = TestFile.all
    # 
    #     respond_to do |format|
    #       format.html # index.html.erb
    #       format.json { render json: @test_files }
    #     end
  end

  # GET /test_files/1
  # GET /test_files/1.json
  def show
    @test_file = current_user.test_file
    
    redirect_to edit_test_file_path(@test_file)
    #@test_file = TestFile.find(params[:id])

    # respond_to do |format|
    #   format.html # show.html.erb
    #   format.json { render json: @test_file }
    # end
  end

  # GET /test_files/new
  # GET /test_files/new.json
  def new
    @test_file = TestFile.new
    redirect_to edit_test_file_path(@test_file)

    # respond_to do |format|
    #   format.html # new.html.erb
    #   format.json { render json: @test_file }
    # end
  end

  # GET /test_files/1/edit
  def edit
    # if params[:id].nil?
      @test_file = current_user.test_file
      
      @console_output = "Welcome back!"
    # else
    #   @test_file = TestFile.find(params[:id])
    # end
  end

  # POST /test_files
  # POST /test_files.json
  def create
    @test_file = TestFile.new(params[:test_file])

    respond_to do |format|
      if @test_file.save
        format.html { redirect_to @test_file, notice: 'Test file was successfully created.' }
        format.json { render json: @test_file, status: :created, location: @test_file }
      else
        format.html { render action: "new" }
        format.json { render json: @test_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /test_files/1
  # PUT /test_files/1.json
  def update
    @test_file = TestFile.find(params[:id])
    
    # Stubbed out to simulate random successes and failures:  
    if rand(5) == 0
      @console_msg = %{ Compilation error at line 23:
        # /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/activesupport-3.1.0/lib/active_support/whiny_nil.rb:48:in `method_missing'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/devise-2.0.4/lib/devise/test_helpers.rb:24:in `setup_controller_for_warden'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-rails-2.8.1/lib/rspec/rails/adapters.rb:15:in `block (2 levels) in setup'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/hooks.rb:35:in `instance_eval'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/hooks.rb:35:in `run_in'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/hooks.rb:70:in `block in run_all'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/hooks.rb:70:in `each'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/hooks.rb:70:in `run_all'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/hooks.rb:368:in `run_hook'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/example_group.rb:292:in `block in run_before_each_hooks'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/example_group.rb:292:in `each'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/example_group.rb:292:in `run_before_each_hooks'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/example.rb:217:in `run_before_each'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/example.rb:79:in `block in run'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/example.rb:173:in `with_around_hooks'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/example.rb:77:in `run'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/example_group.rb:355:in `block in run_examples'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/example_group.rb:351:in `map'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/example_group.rb:351:in `run_examples'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/example_group.rb:337:in `run'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/example_group.rb:338:in `block in run'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/example_group.rb:338:in `map'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/example_group.rb:338:in `run'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/command_line.rb:28:in `block (2 levels) in run'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/command_line.rb:28:in `map'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/command_line.rb:28:in `block in run'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/reporter.rb:34:in `report'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/core/command_line.rb:25:in `run'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/rspec-core-2.8.0/lib/rspec/monkey/spork/test_framework/rspec.rb:7:in `run_tests'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/spork-1.0.0rc2/lib/spork/run_strategy/forking.rb:13:in `block in run'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/spork-1.0.0rc2/lib/spork/forker.rb:21:in `block in initialize'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/spork-1.0.0rc2/lib/spork/forker.rb:18:in `fork'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/spork-1.0.0rc2/lib/spork/forker.rb:18:in `initialize'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/spork-1.0.0rc2/lib/spork/run_strategy/forking.rb:9:in `new'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/spork-1.0.0rc2/lib/spork/run_strategy/forking.rb:9:in `run'
# /Users/duncanstuart/.rvm/gems/ruby-1.9.3-p0/gems/spork-1.0.0rc2/lib/spork/server.rb:48:in `run'
# /Users/duncanstuart/.rvm/rubies/ruby-1.9.3-p0/lib/ruby/1.9.1/drb/drb.rb:1548:in `perform_without_block'
# /Users/duncanstuart/.rvm/rubies/ruby-1.9.3-p0/lib/ruby/1.9.1/drb/drb.rb:1508:in `perform'
# /Users/duncanstuart/.rvm/rubies/ruby-1.9.3-p0/lib/ruby/1.9.1/drb/drb.rb:1586:in `block (2 levels) in main_loop'
# /Users/duncanstuart/.rvm/rubies/ruby-1.9.3-p0/lib/ruby/1.9.1/drb/drb.rb:1582:in `loop'
# /Users/duncanstuart/.rvm/rubies/ruby-1.9.3-p0/lib/ruby/1.9.1/drb/drb.rb:1582:in `block in main_loop'}

      @console_msg_type = "error"
    
      @status_msg = "Saved (with errors)"
    else
      @console_msg = "Saved!"
      @console_msg_type = "success"
    
      @status_msg = "Saved!"
    end
    
    respond_to do |format|
      if @test_file.update_attributes(params[:test_file])
        format.html { redirect_to @test_file, notice: 'Test file was successfully updated.' }
        format.js { }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @test_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /test_files/1
  # DELETE /test_files/1.json
  def destroy
    @test_file = TestFile.find(params[:id])
    @test_file.destroy

    respond_to do |format|
      format.html { redirect_to test_files_url }
      format.json { head :ok }
    end
  end
end
