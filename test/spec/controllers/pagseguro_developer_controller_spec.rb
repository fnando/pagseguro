require File.dirname(__FILE__) + "/../spec_helper"

describe PagseguroDeveloperController do
  it "should redirect to config[:return_to]" do
    post :create
    response.should redirect_to("/cart/success")
  end
  
  it "save sent data to yaml file" do
    request_params = {"ref_transacao" => "ABC", "a" => "1", "b" => "2"}
    
    post :create, request_params.dup
    orders = YAML.load_file(PagseguroDeveloperController::PAGSEGURO_ORDERS_FILE)
    
    orders["ABC"].should == request_params
  end
end
