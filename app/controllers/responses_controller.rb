class ResponsesController < ApplicationController
  
  layout "logged_in"
  
  before_filter :authenticate_user!
  before_filter :check_ownership!, :only => [:show]

  def show
    @response = Response.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  protected
  
  # If the user tries to access a response that they don't own or doesn't exist, return them to the index page
  def check_ownership!
    check_ownership(params[:id], Response) do
      flash[:error] = "You tried to access a response which doesn't exist!"
      redirect_to test_runs_path
    end
  end
end
