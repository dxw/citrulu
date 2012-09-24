module Api
  module V1
    class TestFilesController < ApplicationController
      respond_to :json

      before_filter :authenticate_user!
      before_filter :check_deleted!, :except => [:create]
      before_filter :check_ownership!, :except => [:create]


      def index
        # TODO - Do we want to display all of everything here, or just links/summaries?
        respond_with current_user.test_files.all
      end

      def show
        # TODO - Are there fields we should hide?
        respond_with TestFile.find(params[:id])
      end

      def create
        test_file = TestFile.create(params[:test_file])

        current_user.test_files << test_file

        # TODO - Don't let API users set all the fields.

        respond_with test_file
      end

      def update
        # TODO - Don't let API users update all the fields
        respond_with TestFile.update(params[:id], params[:test_file])
      end

      def destroy
        test_file = TestFile.find(params[:id])

        test_file.delete!

        respond_with("", :status => 204)
      end

      protected
      
      def check_deleted!
        begin
          test_file = TestFile.find(params[:id])
        rescue ActiveRecord::RecordNotFound => e
          test_file = nil
        end

        if !test_file || test_file.deleted?
          respond_with({:error => 'That file has been deleted or does not exist'}, :status => 404)
        end
      end

      # If the user tries to access a test file that they don't own or doesn't exist, return them to the index page
      def check_ownership!
        return check_ownership(params[:id], TestFile) do
          respond_with({:error => 'You do not own that file.'}, :status => 401)
        end
      end
    end
  end
end
