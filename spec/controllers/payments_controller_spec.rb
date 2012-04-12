require 'spec_helper'

describe PaymentsController do

  describe "GET 'choose_plan'" do
    it "returns http success" do
      get 'choose_plan'
      response.should be_success
    end
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'confirmation'" do
    it "returns http success" do
      get 'confirmation'
      response.should be_success
    end
  end

end
