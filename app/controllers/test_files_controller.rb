require 'testrunner.rb'

class TestFilesController < ApplicationController
  layout "logged_in"
  
  before_filter :authenticate_user!
  before_filter :check_ownership!, :only => [:show, :edit, :update, :destroy]
   
  # GET /test_files
  def index
    @test_files = current_user.test_files.not_deleted.sort{ |a,b| b.updated_at <=> a.updated_at}
    @recent_failed_pages = @test_files.collect{|t| t.last_run.number_of_failed_groups unless t.last_run.nil?}.flatten.compact.sum
    @recent_failed_assertions = @test_files.collect{|t| t.last_run.number_of_failed_tests unless t.last_run.nil?}.flatten.compact.sum

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

  # GET /test_files/create
  def create
    @test_file = TestFile.create!(
      user_id: current_user.id,
      name: current_user.new_test_file_name,
      run_tests: true
    )
    # If it doesn't save successfully, it should rightly raise an exception.
    
    redirect_to action: "edit", id: @test_file.id, :new => true
  end


  # GET /test_files/1/edit
  def edit
    @test_file = TestFile.find(params[:id])

    @predefs = Predefs.all

    @console_output = "Welcome to Citrulu"
  end

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

      if !error[:after].empty?
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
    
    # We're either going to get the test_file_text, or the name, but not both together.
    # We only need to try and compile if we have text:
    if params[:test_file][:name].nil? 
      # Then we should expect some code:
      code = params[:test_file][:test_file_text]
      begin
        # If there's no code to complile, don't even try - drop straight through to the 'else' block
        CitruluParser.new.compile_tests(params[:test_file][:test_file_text]) unless code.nil? || code.empty?
  
      rescue CitruluParser::TestPredefError => e
        # Unknown predef:
        @console_msg_hash = { :text0 => e.to_s }
        succeeded = false

      rescue CitruluParser::TestCompileError => e
        # Compile fail:
        begin 
          error = CitruluParser.format_error(e)
        rescue => e
          @console_msg_hash = {
            :text1 => "Something has gone wrong: ",
            :exception_text => e.to_s,
            :text2 => " Sorry! This is a bug. Please let us know."
          }
          succeeded = false
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
          succeeded = false
        end
    
      rescue => e
        # catch-all, including CitruluParser::TestCompileUnknownError
        @console_msg_hash = {
          :text1 => "Something has gone wrong: ",
          :exception_text => e.to_s,
          :text2 => " Sorry! This is a bug. Please let us know."
        }
        succeeded = false
      
      else
        # Compile win!
        @console_msg_hash = { :text0 => "Saved!" }
        succeeded = true

        @test_file.compiled_test_file_text = params[:test_file][:test_file_text]
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
      
      format.html { 
        if request.xhr?
          # if the name has been updated, put its value back to the page
          render :text => params[:test_file].values.first
        else  
          render action: "edit"
        end
      }
      format.js { }
    end
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
    
  # If the user tries to access a test file that they don't own or doesn't exist, return them to the index page
  def check_ownership!
    return check_ownership(params[:id], TestFile) do
      flash[:error] = "You tried to access a test file which doesn't exist!"
      redirect_to test_files_path
    end
  end

end
