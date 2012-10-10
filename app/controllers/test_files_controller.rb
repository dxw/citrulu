require 'testrunner.rb'

class TestFilesController < ApplicationController
  layout "logged_in"
  
  before_filter :authenticate_user!
  before_filter :check_ownership!, :only => [:show, :edit, :update, :destroy]
  before_filter :check_deleted, :only => [:show, :edit, :destroy, :update]
   
  # GET /test_files
  def index
    @test_files = current_user.test_files.not_deleted.order("tutorial_id, updated_at desc")
    @recent_failed_pages = @test_files.collect{|t| t.last_run.number_of_failed_groups unless t.last_run.nil?}.flatten.compact.sum
    @recent_failed_assertions = @test_files.collect{|t| t.last_run.number_of_failed_tests unless t.last_run.nil?}.flatten.compact.sum
    
    # Stats:
    @urls_with_failures_in_past_week  = current_user.urls_with_failures_in_past_week
    @number_of_test_runs              = current_user.number_of_test_runs_in_past_week
    @number_of_urls                   = current_user.number_of_urls_in_past_week
    
    if @number_of_urls > 10
      @fastest_page_response_times = current_user.fastest_n_pages_average_times_in_past_week
      @slowest_page_response_times = current_user.slowest_n_pages_average_times_in_past_week
    else
      @page_response_times = current_user.pages_average_times_in_past_week
    end
    
    @domains_list = current_user.domains_list
    
    respond_to do |format|
      format.html 
      format.json { render json: @test_files }
    end
  end

  # GET /test_files/1
  # GET /test_files/1.json
#def show
#    @test_file = TestFile.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.json { render json: @test_file }
#    end
#  end

  # POST /test_files/create
  def create
    @test_file = current_user.create_new_test_file
    
    log_event("file_created", {:test_file_id => @test_file.id, content_type: "new test file"})
    
    redirect_to action: "edit", id: @test_file, :new => true
  end
  
  # POST /test_files/create_first_test_file
  def create_first_test_file
    @test_file = current_user.create_first_test_file
    
    log_event("file_created", {:test_file_id => @test_file.id, content_type: "new test file after tutorials"})
    log_event("file_created_after_tutorial", {:test_file_id => @test_file.id, content_type: "new test file after tutorials"})
    
    redirect_to action: "edit", id: @test_file, :new => true
  end
  


  # GET /test_files/1/edit
  def edit
    @test_file = TestFile.find(params[:id])

    @predefs = Predefs.all

    @console_output = "Welcome to Citrulu"
    
    unless @test_file.tutorial_id.nil?
      log_event("tutorial opened", { test_file_id: @test_file.id, content_type: "tutorial test file", tutorial_id: @test_file.tutorial_id })
      log_event("tutorial #{@test_file.tutorial_id} opened", { test_file_id: @test_file.id, content_type: "tutorial test file", tutorial_id: @test_file.tutorial_id })
      @help_texts = TUTORIAL_TEST_FILES.select{|t| t[:id] == @test_file.tutorial_id}.first[:help]
      
      @help_shown = params[:help_text].to_i
      @help_shown = 0 if @help_shown < 0 || @help_shown >= @help_texts.length
      
      render action: "edit", help_text: @help_shown 
    end
  end


  # POST /test_files/update_liveview
  def update_liveview
    begin
      @current_line = params[:current_line]

      if params[:group].blank?
        render :text => "$('#liveview h2').removeClass('working');"
        return
      end

      group = CitruluParser.new.compile_tests(params[:group])
      @results = TestRunner.execute_tests(group)[0]

    rescue CitruluParser::TestCompileError => e
      error = CitruluParser.format_error(e)
      
      @error = {}

      if error[:expected_arr].size == 1
        @error[:text0] = "Expected: " 
      else
        @error[:text0] = "Expected one of: " 
      end
      
      error[:expected_arr].each_with_index do |e, i|
        @error["expected#{i}".to_sym] = e
      end

      @error.merge({
        :text2 => " at line ",
        :line => error[:line],
        :text3 => ", column ",
        :column => error[:column],
        :text4 => " of the current group",
      })

      if !error[:after].blank?
        @error[:text4] = " after "
        @error[:after] = error[:after]
      end
    rescue Exception => e
      @error = {}
      @error[:text0] = e.to_s
    end

    respond_to do |format|
      format.js { }
    end
  end

  # PUT /test_files/1
  def update
    @test_file = TestFile.find(params[:id])
    code = params[:test_file][:test_file_text]
    begin
      # If there's no code to complile, don't even try - drop straight through to the 'else' block
      compiled_object = CitruluParser.new.compile_tests(params[:test_file][:test_file_text]) unless code.blank?

    rescue CitruluParser::TestPredefError => e
      # Unknown predef:
      @console_msg_hash = { :text0 => e.to_s }
      succeeded = false

      log_event("compile_fail", {:type => :pebkac})
      
    rescue CitruluParser::TestCompileError => e
      succeeded = false
      
      log_event("compile_fail", {:type => :pebkac})

      # Compile fail:
      begin 
        error = CitruluParser.format_error(e)
      rescue => e
        @console_msg_hash = {
          :text1 => "Something has gone wrong: ",
          :exception_text => e.to_s,
          :text2 => " Sorry! This is a bug. Please let us know."
        }
      else
        @console_msg_hash = {
          :text1 => "Compilation failed! Expected: ",
          :expected => error[:expected],
          :text2 => " at line ",
          :line => error[:line],
          :text3 => ", column ",
          :column => error[:column],
        }

        if !error[:after].empty?
          @console_msg_hash[:text4] = " after "
          @console_msg_hash[:after] = error[:after]
        end
      end
  
    rescue => e
      # catch-all, including CitruluParser::TestCompileUnknownError
      @console_msg_hash = {
        :text1 => "Something has gone wrong: ",
        :exception_text => e.to_s,
        :text2 => " Sorry! This is a bug. Please let us know."
      }
      succeeded = false

      log_event("compile_fail", {:type => :bug})
    
    else
      # Compile win!
      @console_msg_hash = { :text0 => "Saved!" }
      succeeded = true

      @test_file.compiled_test_file_text = code
      
      if code.blank? # and therefore compiled_object.blank?
        @test_file.domains = 0
        number_of_checks = 0
      else  
        # Get the list of domains checked by this file and store them so we can work out if a user is hitting their limits:
        @test_file.domains = CitruluParser.domains(compiled_object)
        number_of_checks = CitruluParser.count_checks(compiled_object)
      end  
      
      if @test_file.is_a_tutorial
        log_event("compile_win", { test_file_id: @test_file.id, content_type: "tutorial test file", tutorial_id: @test_file.tutorial_id, checks: number_of_checks })
      else
        log_event("compile_win", { test_file_id: @test_file.id, content_type: "user test file", checks: number_of_checks })
      end
    end
    
    if succeeded
      @console_msg_type = "success"
      @status_msg = "Saved!"
    else
      @console_msg_type = "error"
      @status_msg = "Saved (with errors)"
    end
    
    respond_to do |format|
      @test_file.update_attributes(params[:test_file])

      # TODO: is there a case where the test_file can't be updated? What on earth would we do then??
      
      format.html { render action: "edit" }
      format.js { }
    end
  end
  
  # PUT /test_files/update_name/1
  def update_name
    @test_file = TestFile.find(params[:id])
    new_name = params[:test_file][:name]
    
    @test_file.name = new_name
    if !@test_file.save
      # Assume it was because the name was taken
      @test_file.name = current_user.generate_name(new_name)
      @test_file.save!
    end

    render :text => @test_file.name
  end
  
  # PUT /test_files/update_run_status/1
  def update_run_status
    test_file = TestFile.find(params[:id])
    
    # Whatever happens, render nothing 
    
    response.headers['Cache-Control'] = 'no-cache' 
    if test_file.update_attributes(run_tests: params[:test_file][:run_tests])
      # Just send back a 200 header:
      render text: ''
      # A couple of ways to do this, but both "render nothing: true" and "head :ok" return a non-empty response body.
    else
      head :unprocessable_entity #422. Maybe not appropriate, but it seems sensible to return SOMETHING to indicate that the save failed...
    end
  end
  
  # DELETE /test_files/1
  def destroy
    @test_file = TestFile.find(params[:id])
    # Don't actually destroy - just mark as deleted
    @test_file.delete!
  end
    
  protected
    
  def check_deleted
    test_file = TestFile.find(params[:id])

    if !test_file || test_file.deleted?
      flash[:error] = "You tried to access a test file which doesn't exist!"
      redirect_to test_files_path
    end
  end

  # If the user tries to access a test file that they don't own or doesn't exist, return them to the index page
  def check_ownership!
    return check_ownership(params[:id], TestFile) do
      flash[:error] = "You tried to access a test file which doesn't exist!"
      redirect_to test_files_path
    end
  end

end
