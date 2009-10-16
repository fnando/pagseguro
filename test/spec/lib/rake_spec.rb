require File.dirname(__FILE__) + '/../spec_helper'

class Net::HTTP
  def self.post_form(uri, params)
    $HTTP_URI = uri
    $HTTP_PARAMS = params
  end
end

describe PagSeguro::Rake do
  before(:each) do
    # First, copy file from spec/fixtures/pagseguro-test.yml 
    # to tmp/pagseguro-test.yml
    @origin = File.expand_path(File.dirname(__FILE__) + "/../fixtures/pagseguro-test.yml")
    @destiny = RAILS_ROOT + "/tmp/pagseguro-test.yml"
    
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
    
    # Set the order id
    ENV["ID"] = "ABC"
    
    PagSeguro::Rake.run
  end
  
  it "should ping return URL with default arguments" do
    data["StatusTransacao"].should == "Completo"
    data["TipoPagamento"].should == "Cartão de Crédito"
  end
  
  it "should ping return URL with provided arguments" do
    ENV["STATUS"] = "canceled"
    ENV["PAYMENT_METHOD"] = "invoice"
    
    PagSeguro::Rake.run
    
    data["StatusTransacao"].should == "Cancelado"
    data["TipoPagamento"].should == "Boleto"
  end
  
  it "should set order id" do
    data["Referencia"].should == "ABC"
  end
  
  it "should set number of items" do
    data["NumItens"].should == 3
  end
  
  it "should set note" do
    ENV["NOTE"] = "Deliver ASAP"
    
    PagSeguro::Rake.run
    
    data["Anotacao"].should == "Deliver ASAP"
  end
  
  it "should set client's name" do
    ENV["NAME"] = "Rafael Mendonça França"
    
    PagSeguro::Rake.run
    
    data["CliNome"].should == "Rafael Mendonça França"
  end
  
  it "should set transaction date" do
    now = Time.now
    Time.stub!(:now).and_return(now)
    
    PagSeguro::Rake.run
    
    data["DataTransacao"].should == now.strftime("%d/%m/%Y %H:%M:%S")
  end
  
  it "should set transaction id" do
    data["TransacaoID"].should == "THEHASH"
  end
  
  it "should set products" do
    data["ProdID_1"].should == "1"
    data["ProdDescricao_1"].should == "Ruby 1.9 PDF"
    data["ProdValor_1"].should == "9,00"
    data["ProdQuantidade_1"].should == "1"
    data["ProdExtras_1"].should == "0,00"
    data["ProdFrete_1"].should == "0,00"
    
    data["ProdID_2"].should == "2"
    data["ProdDescricao_2"].should == "Ruby 1.9 Screencast"
    data["ProdValor_2"].should == "12,50"
    data["ProdQuantidade_2"].should == "1"
    data["ProdExtras_2"].should == "0,00"
    data["ProdFrete_2"].should == "0,00"
    
    data["ProdID_3"].should == "3"
    data["ProdDescricao_3"].should == "Ruby T-Shirt"
    data["ProdValor_3"].should == "19,89"
    data["ProdQuantidade_3"].should == "2"
    data["ProdExtras_3"].should == "0,00"
    data["ProdFrete_3"].should == "2,50"
  end
  
  it "should set client's info" do
    data["CliNome"].should_not be_blank
    data["CliEmail"].should_not be_blank
    data["CliEndereco"].should_not be_blank
    data["CliNumero"].should_not be_blank
    data["CliComplemento"].should_not be_blank
    data["CliBairro"].should_not be_blank
    data["CliCidade"].should_not be_blank
    data["CliCEP"].should == "12345678"
    data["CliTelefone"].should == "11 12345678"
  end
  
  it "should be test environment" do
    PagseguroDeveloperController::PAGSEGURO_ORDERS_FILE.should == File.join(Rails.root, "tmp", "pagseguro-test.yml")
  end
  
  private
    def data
      $HTTP_PARAMS
    end
end
