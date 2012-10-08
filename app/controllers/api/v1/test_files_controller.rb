module Api
  module V1
    class TestFilesController < ApplicationController
      respond_to :json

      before_filter :authenticate_user!
      before_filter :check_deleted!, :except => [:create, :index]
      before_filter :check_ownership!, :except => [:create, :index]

      def index
        respond_with current_user.test_files.select([:id, :name]).all
      end

      def show
        respond_with TestFile.where(:id => params[:id]), :only => [:id, :name, :compiled_test_file_text, :test_file_text, :domains, :frequency, :run_tests, :tutorial_id, :updated_at, :created_at]
      end

      def create
        parameters = prepare_params(params)

        test_file = TestFile.create(parameters[:test_file])

        current_user.test_files << test_file

        respond_with test_file
      end

      def compile
        test_file = TestFile.find(params[:id])
        
        begin
          CitruluParser.new.compile_tests(test_file.test_file_text)
        rescue CitruluParser::TestCompileError => e
          respond_with({:error => e.message}, :status => :unprocessable_entity, :location => '')
        else
          respond_with test_file, :only => [:id, :name, :compiled_test_file_text, :test_file_text, :domains, :frequency, :run_tests, :tutorial_id, :updated_at, :created_at]
        end
      end

      def update
        parameters  = prepare_params(params)
        test_file = TestFile.update(params[:id], parameters[:test_file])

        respond_with(test_file, :status => 200) do |format|
          if test_file.save
            format.json { render :json => test_file, :status => 200 }
          else
            format.json { render :json => {:error => test_file.errors}, :status => 422 }
          end
        end
      end

      def destroy
        test_file = TestFile.find(params[:id])

        test_file.delete!

        respond_with("", :status => 204)
      end

      protected

      def prepare_params(parameters)
        # Don't make people put everything in test_file[]
        orig_params = parameters

        parameters = {:auth_token => orig_params[:auth_token], :format => orig_params[:format], :action => orig_params[:action], :controller => orig_params[:controller]}

        # Only keep the things that users are allowed to set
        parameters[:test_file] = {}
        [:name, :run_tests, :test_file_text].each do |allowed|
          if orig_params[allowed]
            parameters[:test_file][allowed] = orig_params[allowed]
          end
        end

        # Some things are not set by users but must be set
        parameters[:test_file][:frequency] = current_user.plan.test_frequency

        parameters
      end
      
      def check_deleted!
        begin
          test_file = TestFile.find(params[:id])
        rescue ActiveRecord::RecordNotFound => e
          test_file = false
        end

        if !test_file || test_file.deleted?
          respond_with do |format|
            format.json { render :json => {:error => 'That file does not exist'}, :status => 404 }
          end
        end
      end

      # If the user tries to access a test file that they don't own or doesn't exist, return them to the index page
      def check_ownership!
        return check_ownership(params[:id], TestFile) do
          respond_with do |format|
            format.json { render :json => {:error => 'You do not own that file.'}, :status => 401 }
          end
        end
      end
    end
  end
end
