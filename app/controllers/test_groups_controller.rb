class TestGroupsController < ApplicationController
  # GET /test_groups
  # GET /test_groups.json
  def index
    @test_groups = TestGroup.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @test_groups }
    end
  end

  # GET /test_groups/1
  # GET /test_groups/1.json
  def show
    @test_group = TestGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @test_group }
    end
  end

  # GET /test_groups/new
  # GET /test_groups/new.json
  def new
    @test_group = TestGroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @test_group }
    end
  end

  # GET /test_groups/1/edit
  def edit
    @test_group = TestGroup.find(params[:id])
  end

  # POST /test_groups
  # POST /test_groups.json
  def create
    @test_group = TestGroup.new(params[:test_group])

    respond_to do |format|
      if @test_group.save
        format.html { redirect_to @test_group, notice: 'Test group was successfully created.' }
        format.json { render json: @test_group, status: :created, location: @test_group }
      else
        format.html { render action: "new" }
        format.json { render json: @test_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /test_groups/1
  # PUT /test_groups/1.json
  def update
    @test_group = TestGroup.find(params[:id])

    respond_to do |format|
      if @test_group.update_attributes(params[:test_group])
        format.html { redirect_to @test_group, notice: 'Test group was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @test_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /test_groups/1
  # DELETE /test_groups/1.json
  def destroy
    @test_group = TestGroup.find(params[:id])
    @test_group.destroy

    respond_to do |format|
      format.html { redirect_to test_groups_url }
      format.json { head :ok }
    end
  end
end
