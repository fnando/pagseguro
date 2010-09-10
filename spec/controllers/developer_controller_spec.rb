require "spec_helper"

describe PagSeguro::DeveloperController do
  let(:file_path) { PagSeguro::DeveloperController::PAGSEGURO_ORDERS_FILE }
  let(:orders) { YAML.load_file(file_path) }

  before do
    File.unlink(file_path) if File.exist?(file_path)
  end

  it "should create file when it doesn't exist" do
    post :create
    File.should be_file(file_path)
  end

  it "should save sent params" do
    post :create, :email_cobranca => "john@doe.com", :ref_transacao => "I1001"
    orders["I1001"]["email_cobranca"].should == "john@doe.com"
    orders["I1001"]["ref_transacao"].should == "I1001"
  end

  it "should redirect to the return url" do
    post :create, :ref_transacao => "I1001"
    response.should redirect_to("/invoices/confirmation")
  end
end
