require File.dirname(__FILE__) + '/../spec_helper'

describe PagSeguro::Rake do
  before(:each) do
    # First, copy file from spec/fixtures/pagseguro-test.yml 
    # to tmp/pagseguro-test.yml
    @origin = File.expand_path(File.dirname(__FILE__) + "/../fixtures/pagseguro-test.yml")
    @destiny = Rails.root + "/tmp/pagseguro-test.yml"
    
    FileUtils.cp @origin, @destiny

    # Stub Digest::MD5#hexdigest to always return THEHASH  
    Digest::MD5.stub!(:hexdigest).and_return("THEHASH")
    
    # Stub the URI#parse to return a mock
    @uri = mock("URI").as_null_object
    URI.stub!(:parse).and_return(@uri)
    
    # Load the pagseguro-test.yml file to
    # set some variables in order to compare it
    @orders = YAML.load_file(@origin)
    @order = @orders["ABC"]
    @order["TransacaoID"] = "THEHASH"
    @order["NumItens"] = 3
    
    # Set the order id
    ENV["ID"] = "ABC"
  end
  
  it "should ping return URL with default arguments" do
    @order["StatusTransacao"] = "Completo"
    @order["TipoPagamento"] = "Cartão de Crédito"
    
    Net::HTTP.should_receive(:post_form).with(@uri, @order)
    PagSeguro::Rake.run
  end
  
  it "should ping return URL with provided arguments" do
    ENV["STATUS"] = "canceled"
    ENV["PAYMENT_METHOD"] = "invoice"
    
    @order["StatusTransacao"] = "Cancelado"
    @order["TipoPagamento"] = "Boleto"

    Net::HTTP.should_receive(:post_form).with(@uri, @order)
    PagSeguro::Rake.run
  end
  
  it "should be test environment" do
    PagseguroDeveloperController::PAGSEGURO_ORDERS_FILE.should == File.join(Rails.root, "tmp", "pagseguro-test.yml")
  end
end
