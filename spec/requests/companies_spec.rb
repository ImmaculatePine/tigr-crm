require 'spec_helper'

describe "Companies" do
  before(:each) do
    integration_sign_in FactoryGirl.create(:user)
  end
  
  describe "/companies/:id" do
    pending "something for show action"
    pending "adding person to company from here"
  end
end
