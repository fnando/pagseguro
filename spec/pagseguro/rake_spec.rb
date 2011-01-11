# encoding: utf-8
require "spec_helper"

class Net::HTTP
  def self.post_form(uri, params)
    $HTTP_URI = uri
    $HTTP_PARAMS = params
  end
end

describe PagSeguro::Rake do
  before do
    # First, copy file from spec/support/pagseguro-test.yml
    # to tmp/pagseguro-test.yml
    @origin = File.dirname(__FILE__) + "/../support/pagseguro-test.yml"
    @destiny = Rails.root.join("tmp/pagseguro-test.yml")

    FileUtils.cp @origin, @destiny

    # Stub Digest::MD5#hexdigest to always return THEHASH
    Digest::MD5.stub :hexdigest => "THEHASH"

    # Stub the URI#parse to return a mock
    @uri = mock("URI").as_null_object
    URI.stub :parse => @uri

    # Load the pagseguro-test.yml file to
    # set some variables in order to compare it
    @orders = YAML.load_file(@origin)
    @order = @orders["ABC"]

    # Set the order id
    ENV["ID"] = "ABC"

    PagSeguro::Rake.run
  end

  it "should ping return URL with default arguments" do
    params["StatusTransacao"].should == "Completo"
    params["TipoPagamento"].should == "Cartão de Crédito"
  end

  it "should ping return URL with provided arguments" do
    ENV["STATUS"] = "canceled"
    ENV["PAYMENT_METHOD"] = "invoice"

    PagSeguro::Rake.run

    params["StatusTransacao"].should == "Cancelado"
    params["TipoPagamento"].should == "Boleto"
  end

  it "should set order id" do
    params["Referencia"].should == "ABC"
  end

  it "should set number of items" do
    params["NumItens"].should == 4
  end

  it "should set note" do
    ENV["NOTE"] = "Deliver ASAP"
    PagSeguro::Rake.run
    params["Anotacao"].should == "Deliver ASAP"
  end

  it "should set client's name" do
    ENV["NAME"] = "Rafael Mendonça França"
    PagSeguro::Rake.run
    params["CliNome"].should == "Rafael Mendonça França"
  end

  it "should set transaction date" do
    now = Time.now
    Time.stub :now => now

    PagSeguro::Rake.run
    params["DataTransacao"].should == now.strftime("%d/%m/%Y %H:%M:%S")
  end

  it "should set transaction id" do
    params["TransacaoID"].should == "THEHASH"
  end

  it "should set products" do
    params["ProdID_1"].should == "1"
    params["ProdDescricao_1"].should == "Ruby 1.9 PDF"
    params["ProdValor_1"].should == "9,00"
    params["ProdQuantidade_1"].should == "1"
    params["ProdExtras_1"].should == "0,00"
    params["ProdFrete_1"].should == "0,00"

    params["ProdID_2"].should == "2"
    params["ProdDescricao_2"].should == "Ruby 1.9 Screencast"
    params["ProdValor_2"].should == "12,50"
    params["ProdQuantidade_2"].should == "1"
    params["ProdExtras_2"].should == "0,00"
    params["ProdFrete_2"].should == "0,00"

    params["ProdID_3"].should == "3"
    params["ProdDescricao_3"].should == "Ruby T-Shirt"
    params["ProdValor_3"].should == "19,89"
    params["ProdQuantidade_3"].should == "2"
    params["ProdExtras_3"].should == "0,00"
    params["ProdFrete_3"].should == "2,50"

    params["ProdID_4"].should == "4"
    params["ProdDescricao_4"].should == "Ruby Mug"
    params["ProdValor_4"].should == "15,99"
    params["ProdQuantidade_4"].should == "1"
    params["ProdExtras_4"].should == "0,00"
    params["ProdFrete_4"].should == "0,00"
  end

  it "should set client info" do
    params["CliNome"].should_not be_blank
    params["CliEmail"].should_not be_blank
    params["CliEndereco"].should_not be_blank
    params["CliNumero"].should_not be_blank
    params["CliComplemento"].should_not be_blank
    params["CliBairro"].should_not be_blank
    params["CliCidade"].should_not be_blank
    params["CliCEP"].should match(/\d{5}-\d{3}/)
    params["CliTelefone"].should match(/\(\d{2}\) \d{4}-\d{4}/)
  end

  it "should set client e-mail" do
    ENV["EMAIL"] = "john@doe.com"
    PagSeguro::Rake.run
    params["CliEmail"].should == "john@doe.com"
  end

  it "should be test environment" do
    PagSeguro::DeveloperController::PAGSEGURO_ORDERS_FILE.should == File.join(Rails.root, "tmp", "pagseguro-test.yml")
  end

  private
  def params
    $HTTP_PARAMS
  end
end
