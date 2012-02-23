class TestFilesController < ApplicationController
  
  before_filter :authenticate_user!
  
  # GET /test_files
  # GET /test_files.json
  def index
    @test_file = current_user.test_file
    render :edit
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
    render :edit
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
    render :edit

    # respond_to do |format|
    #   format.html # new.html.erb
    #   format.json { render json: @test_file }
    # end
  end

  # GET /test_files/1/edit
  def edit
    # if params[:id].nil?
      @test_file = current_user.test_file
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

    respond_to do |format|
      if @test_file.update_attributes(params[:test_file])
        format.html { redirect_to @test_file, notice: 'Test file was successfully updated.' }
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
