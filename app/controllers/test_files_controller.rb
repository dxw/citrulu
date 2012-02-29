class TestFilesController < ApplicationController
  layout "logged_in"
  
  before_filter :authenticate_user!
  
  require 'test_grammar_compiler'
  
  # require "#{Rails.root}/lib/testrunner/test_grammar_compiler.rb"
  # include TestGrammarCompiler

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
    begin
      Compiler.new.compile_tests(params[:test_file][:test_file_text])
    rescue Compiler::TestCompileError => e
      @console_msg = "Failed to compile: #{e.message}" #strip removes the annoying newline on the console message
      @console_msg_type = "error"
      @status_msg = "Saved (with errors)"
    else
      # Compiled successfully: 
      @console_msg = "Saved!"
      @console_msg_type = "success"
      @status_msg = "Saved!"
      
      @test_file.compiled_test_file_text = params[:test_file][:test_file_text]
    end

    respond_to do |format|
      @test_file.update_attributes(params[:test_file])

      # TODO: is there a case where the test_file can't be updated? What on earth would we do then??
      
      format.html { render action: "edit" }
      format.js { }
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
